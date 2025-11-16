*** Settings ***
Resource    ../../resources/imports.robot
Resource    ../../keywords/common/cubankCommonKeywords.robot
Resource    ../../keywords/common/mongoDatabaseKeywords.robot

Variables    ../../resources/testdata/scenario/s4.yml

Suite Setup       Run Keywords  Delete Account By Id    ${ACCOUNT_ID}
                  ...   AND   Create New User    ${NAME}    ${ACCOUNT_ID}    ${PASSWORD}  
                  ...   AND   Open Browser First
Suite Teardown    Run Keywords  Close Browser
                  ...   AND    Delete Account By Id    ${ACCOUNT_ID}

*** Variables ***
${ACCOUNT_ID}       1234567890
${NAME}           Litle Chacoal
${PASSWORD}       1111

${BALANCE_BASE}       1500
${WITHDRAW_OVER_AMOUNT}      2000

${MSG_INSUFFICIENT}   Your balance is not enough to complete the withdrawal.

*** Test Cases ***
TC12 เข้าสู่ระบบผ่าน 
    Login with account number and password  accountNumber=${ACCOUNT_ID}  password=${PASSWORD}

TC21 ฝากเงินสำเร็จ
    [Setup]   Run Keywords    Delete Transactions On Account  ${ACCOUNT_ID}
    ...       AND   Update Balance To Zero  ${ACCOUNT_ID}
    Reload Page
    Make deposit transaction success   depositAmount=1500
    Verify Balance On Title  balance=1500
    Verify History transaction should correct   expected_data=${s4.TC_001.expected_history}

TC25 ถอนเงินไม่สำเร็จ (Amount > balance) 
    Reload Page
    Verify Balance On Title  balance=1500
    Submit Withdraw      ${WITHDRAW_OVER_AMOUNT}
    Validate Withdraw Error      ${MSG_INSUFFICIENT}
    Verify History transaction should correct   expected_data=${s4.TC_001.expected_history}