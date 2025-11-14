*** Settings ***
Resource    ../../resources/imports.robot
Resource    ../../keywords/common/cubankCommonKeywords.robot
Resource    ../../keywords/common/mongoDatabaseKeywords.robot

Variables    ../../resources/testdata/scenerio3.yml

Suite Setup       Run Keywords  Delete Account By Id  ${ACCOUNT_ID}
                  ...   AND   Create New User  ${NAME}   ${ACCOUNT_ID}  ${PASSWORD}
                  ...   AND   Open Browser First
                  ...   AND   Login with account number and password  accountNumber=${ACCOUNT_ID}  password=${PASSWORD}
Suite Teardown    Run Keywords  Close Browser
                  ...   AND    Delete Account By Id  ${ACCOUNT_ID}

*** Variables ***
${ACCOUNT_ID}       1234567890
${NAME}           Litle Chacoal
${PASSWORD}       1111

*** Test Cases ***
TC22 ฝากเงินไม่สำเร็จ จำนวนเงินติดลบ 
    [Setup]   Run Keywords    Delete Transactions On Account  ${ACCOUNT_ID}
    ...       AND   Update Balance To Zero  ${ACCOUNT_ID}
    Reload Page
    Make deposit transaction   depositAmount=-1
    Validate Error Message  msg=The amount must be greater than 0. Please enter a positive number.
    Verify History transaction should empty

TC23 ฝากเงินไม่สำเร็จ จำนวนเงินไม่ใช่จำนวนเต็ม 
    [Setup]   Run Keywords    Delete Transactions On Account  ${ACCOUNT_ID}
    ...       AND   Update Balance To Zero  ${ACCOUNT_ID}
    Reload Page
    Make deposit transaction   depositAmount=0.01
    Validate Error Message  msg=The balance amount must be a whole number with no decimals.
    Verify History transaction should empty

TC24 ฝากเงินไม่สำเร็จ จำนวนเงินไม่ใช่ตัวเลข 
    [Setup]   Run Keywords    Delete Transactions On Account  ${ACCOUNT_ID}
    ...       AND   Update Balance To Zero  ${ACCOUNT_ID}
    Reload Page
    Make deposit transaction   depositAmount=e1
    Validate Error Message  msg=Invalid balance amount. Please enter a valid number.
    Verify History transaction should empty
