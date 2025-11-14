*** Settings ***
Library           SeleniumLibrary

Suite Setup       Run Keywords  Delete Account By Id    ${VALID_ACC}
                  ...   AND   Create New User    ${NAME}    ${VALID_ACC}    ${PASSWORD}
                  ...    AND    Create New User    ${NAME}    ${TARGET_VALID}    ${PASSWORD}     
                  ...   AND   Open Browser First
                  ...   AND   Login with account number and password  accountNumber=${VALID_ACC}  password=${PASSWORD}
Suite Teardown    Run Keywords  Close Browser
                  ...   AND    Delete Account By Id    ${VALID_ACC}
                  ...    AND    Delete Account By Id    ${TARGET_VALID}

Resource    ../keywords/common/cubankCommonKeywords.robot
Resource    ../keywords/common/mongoDatabaseKeywords.robot

Variables    ../resources/testdata/scenerio5.yml

*** Variables ***
${BASE_URL}       http://localhost:3000
${BROWSER}        chrome

${NAME}           Litle Chacoal
${PASSWORD}       1111
${VALID_ACC}      1234567896
${PASSWORD}       1234

${TARGET_VALID}   1234567897         # A1: correct format + exists
${TARGET_NOTFOUND}    5555555555        # A2: valid format but not exist
${TARGET_SHORT}   12345              # A3: < 10 digits
${TARGET_LONG}    123451234512345    # A4: > 10 digits
${TARGET_TEXT}    ABCD               # A5: non-number
${TARGET_SELF}    ${VALID_ACC}       # A6: transfer to yourself

${AMOUNT_VALID}   300                # B1 valid amount
${AMOUNT_EQUAL}   1000               # B2 equal balance test
${AMOUNT_OVER}    20000              # B3 > balance
${AMOUNT_ZERO}    0                  # B4 <= 0
${AMOUNT_DECIMAL}    120.5
${AMOUNT_NON_INTEGER}    e1


*** Keywords ***
Go To Transfer
    Go To    ${BASE_URL}/account
    Wait Until Page Contains Element    xpath=//h2[text()="Transfer"]
    Scroll Element Into View            xpath=//h2[text()="Transfer"]

Submit Transfer
    [Arguments]    ${acc}    ${amount}
    Input Text     xpath=//h2[text()="Transfer"]/following::input[@cid="t1"][1]    ${acc}
    Input Text     xpath=//h2[text()="Transfer"]/following::input[@cid="t2"][1]    ${amount}
    Execute JavaScript    document.querySelector('button[cid="tc"]').click()
    Sleep    1s

Validate Error
    [Arguments]    ${msg}
    Wait Until Element Is Visible    css:[cid="transfer-error-mes"]    timeout=5s
    ${txt}=    Get Text    css:[cid="transfer-error-mes"]
    Should Be Equal As Strings    ${txt}    ${msg}

Validate Success
    Wait Until Page Contains    Confirm    timeout=5s

*** Test Cases ***
TC001 โอนสำเร็จข้อมูลถูกต้อง 
    [Setup]   Run Keywords    Delete Transactions On Account    ${VALID_ACC}
    ...       AND   Update Balance By Amount    ${VALID_ACC}    1000
    Go To Transfer
    ${old_balance}=    Get Balance
    Log To Console    Balance before transfer: ${old_balance}
    Submit Transfer   ${TARGET_VALID}   ${AMOUNT_VALID}
    Validate Success
    Sleep             2s
    Reload Page
    Verify Balance On Title  balance=700
    Verify History transaction should correct   expected_data=${scenerio5.TC_001.expected_history}


TC002 โอนจำนวนเท่ายอดคงเหลือ 
    [Setup]   Run Keywords    Delete Transactions On Account    ${VALID_ACC}
    ...       AND   Update Balance By Amount    ${VALID_ACC}    1000
    Go To Transfer
    ${old_balance}=    Get Balance
    Log To Console    Balance before transfer: ${old_balance}
    Submit Transfer   ${TARGET_VALID}   ${old_balance}
    Validate Success
    Sleep             2s
    Reload Page
    Verify Balance On Title  balance=0
    Verify History transaction should correct   expected_data=${scenerio5.TC_002.expected_history}


TC003 ยอดเงินไม่พอ 
    [Setup]   Run Keywords    Delete Transactions On Account    ${VALID_ACC}
    ...       AND   Update Balance By Amount    ${VALID_ACC}    1000
    Go To Transfer
    Submit Transfer    ${TARGET_VALID}   ${AMOUNT_OVER}
    Validate Error    Your balance is not enough to complete the transfer.


TC004 จำนวนเงินต้องมากกว่า 0 
    Go To Transfer
    Submit Transfer    ${TARGET_VALID}   ${AMOUNT_ZERO}
    Validate Error    The amount must be greater than 0. Please enter a positive number.


TC005 จำนวนเงินต้องเป็นจำนวนเต็ม 
    Go To Transfer
    Submit Transfer    ${TARGET_VALID}   ${AMOUNT_DECIMAL}
    Validate Error    The balance amount must be a whole number with no decimals.

TC006 จำนวนเงินต้องเป็นจำนวนเต็ม (2) 
    Go To Transfer
    Submit Transfer    ${TARGET_VALID}   ${AMOUNT_NON_INTEGER}
    Validate Error    The balance amount must be a whole number with no decimals.


TC007 บัญชีไม่พบในระบบ 
    Go To Transfer
    Submit Transfer    ${TARGET_NOTFOUND}    ${AMOUNT_VALID}
    Validate Error    We couldn't find the recipient's account. Please double-check the account ID.


TC008 เลขบัญชีไม่ครบ 10 หลัก 
    Go To Transfer
    Submit Transfer    ${TARGET_SHORT}    ${AMOUNT_VALID}
    Validate Error    The account number must be exactly 10 digits long.


TC009 เลขบัญชีเกิน 10 หลัก 
    Go To Transfer
    Submit Transfer    ${TARGET_LONG}    ${AMOUNT_VALID}
    Validate Error    Your account ID must be exactly 10 digits long.


TC010 เลขบัญชีต้องเป็นตัวเลขเท่านั้น 
    Go To Transfer
    Submit Transfer    ${TARGET_TEXT}    ${AMOUNT_VALID}
    Validate Error    Your account ID should contain numbers only.


TC011 โอนไปหาตัวเองไม่ได้ 
    Go To Transfer
    Submit Transfer    ${TARGET_SELF}    ${AMOUNT_VALID}
    Validate Error    You cannot transfer to your own account.

