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
${WITHDRAW_AMOUNT}    200
${TRANSFER_AMOUNT}    200

${TARGET_NOTFOUND}    5555555555       
${TARGET_SHORT}   12345           
${TARGET_LONG}    123451234512345   
${TARGET_TEXT}    ABCD      

${MSG_INSUFFICIENT}   Your balance is not enough to complete the withdrawal.

*** Keywords ***
Go To Transfer
    Go To    http://localhost:3000/account
    Wait Until Page Contains Element    xpath=//h2[text()="Transfer"]
    Scroll Element Into View            xpath=//h2[text()="Transfer"]

Submit Transfer
    [Arguments]    ${acc}    ${amount}
    Input Text     xpath=//h2[text()="Transfer"]/following::input[@cid="t1"][1]    ${acc}
    Input Text     xpath=//h2[text()="Transfer"]/following::input[@cid="t2"][1]    ${amount}
    Execute JavaScript    document.querySelector('button[cid="tc"]').click()
    Sleep    1s

Submit Withdraw
    [Arguments]    ${amount}
    Go To Withdraw
    Wait Until Page Contains Element    xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]    10s
    Clear Element Text                  xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]
    Input Text                          xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]    ${amount}
    Click Button                        css:[cid="wc"]
    Sleep    200ms

Validate Error
    [Arguments]    ${msg}
    Wait Until Element Is Visible    css:[cid="transfer-error-mes"]    timeout=5s
    ${txt}=    Get Text    css:[cid="transfer-error-mes"]
    Should Be Equal As Strings    ${txt}    ${msg}

*** Test Cases ***
TC12 เข้าสู่ระบบผ่าน 
    Login with account number and password  accountNumber=${ACCOUNT_ID}  password=${PASSWORD}

TC21 ฝากเงินสำเร็จ
    [Setup]   Run Keywords    Delete Transactions On Account  ${ACCOUNT_ID}
    ...       AND   Update Balance To Zero  ${ACCOUNT_ID}
    Reload Page
    Make deposit transaction success   depositAmount=1500
    Verify Balance On Title  balance=1500
    Verify History transaction should correct   expected_data=${s4.TC_002.expected_history}

TC26 ถอนเงินสำเร็จ (Amount < balance) 
    Reload Page
    Verify Balance On Title  balance=1500
    Submit Withdraw      ${WITHDRAW_AMOUNT}
    Verify History transaction should correct   expected_data=${s4.TC_002.expected_history}

TC35 โอนเงินไม่สำเร็จ - บัญชีไม่พบในระบบ 
    Go To Transfer
    Submit Transfer    ${TARGET_NOTFOUND}    ${TRANSFER_AMOUNT}
    Validate Error    We couldn't find the recipient's account. Please double-check the account ID.

TC36 โอนเงินไม่สำเร็จ - เลขบัญชีไม่ครบ 10 หลัก 
    Go To Transfer
    Submit Transfer    ${TARGET_SHORT}    ${TRANSFER_AMOUNT}
    Validate Error    The account number must be exactly 10 digits long.

TC37 โอนเงินไม่สำเร็จ - เลขบัญชีเกิน 10 หลัก 
    Go To Transfer
    Submit Transfer    ${TARGET_LONG}    ${TRANSFER_AMOUNT}
    Validate Error    Your account ID must be exactly 10 digits long.

TC38 โอนเงินไม่สำเร็จ - เลขบัญชีต้องเป็นตัวเลขเท่านั้น 
    Go To Transfer
    Submit Transfer    ${TARGET_TEXT}    ${TRANSFER_AMOUNT}
    Validate Error    Your account ID should contain numbers only.

TC39 โอนเงินไม่สำเร็จ - โอนเข้าบัญชีตัวเองไม่ได้ 
    Go To Transfer
    Submit Transfer    ${ACCOUNT_ID}    ${TRANSFER_AMOUNT}
    Validate Error    You cannot transfer to your own account.
