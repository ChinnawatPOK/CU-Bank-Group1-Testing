*** Settings ***
Library           SeleniumLibrary
Suite Setup       Login To Bank
Suite Teardown    Close Browser

*** Variables ***
${BASE_URL}       http://localhost:3000
${BROWSER}        chrome

${VALID_ACC}      1234567892
${PASSWORD}       1234

${TARGET_VALID}   2222222222         # A1: correct format + exists
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


*** Keywords ***
Login To Bank
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    css:[cid="l1"]
    Input Text       css:[cid="l1"]    ${VALID_ACC}
    Input Password   css:[cid="l2"]    ${PASSWORD}
    Click Button     css:[cid="lc"]
    Wait Until Page Contains    Account ID:

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
    Capture Page Screenshot

Validate Success
    Wait Until Page Contains    Confirm    timeout=5s
    Capture Page Screenshot

Get Balance
    ${bal_text}=    Get Text    xpath=(//h2[text()="Balance:"]/following-sibling::h1)[1]
    ${bal}=         Convert To Integer    ${bal_text}
    [Return]        ${bal}

*** Test Cases ***
# A1,B3 — insufficient balance
TC01 ยอดเงินไม่พอ (A1,B3)
    Go To Transfer
    Submit Transfer    ${TARGET_VALID}   ${AMOUNT_OVER}
    Validate Error    Your balance is not enough to complete the transfer.

# A1,B4 — amount ≤ 0
TC02 จำนวนเงินต้องมากกว่า 0 (A1,B4)
    Go To Transfer
    Submit Transfer    ${TARGET_VALID}   ${AMOUNT_ZERO}
    Validate Error    The amount must be greater than 0. Please enter a positive number.

# A1,B5 — decimal
TC03 จำนวนเงินต้องเป็นจำนวนเต็ม (A1,B5)
    Go To Transfer
    Submit Transfer    ${TARGET_VALID}   ${AMOUNT_DECIMAL}
    Validate Error    The balance amount must be a whole number with no decimals.

# A2 — account not found
TC04 บัญชีไม่พบในระบบ (A2)
    Go To Transfer
    Submit Transfer    ${TARGET_NOTFOUND}    ${AMOUNT_VALID}
    Validate Error    We couldn't find the recipient's account. Please double-check the account ID.

# A3 — account < 10 digits
TC05 เลขบัญชีไม่ครบ 10 หลัก (A3)
    Go To Transfer
    Submit Transfer    ${TARGET_SHORT}    ${AMOUNT_VALID}
    Validate Error    The account number must be exactly 10 digits long

# A4 — account > 10 digits
TC06 เลขบัญชีเกิน 10 หลัก (A4)
    Go To Transfer
    Submit Transfer    ${TARGET_LONG}    ${AMOUNT_VALID}
    Validate Error    Your account ID must be exactly 10 digits long.

# A5 — non-numeric account
TC07 เลขบัญชีต้องเป็นตัวเลขเท่านั้น (A5)
    Go To Transfer
    Submit Transfer    ${TARGET_TEXT}    ${AMOUNT_VALID}
    Validate Error    Your account ID should contain numbers only.

# A6 — transfer to your own account
TC08 โอนไปหาตัวเองไม่ได้ (A6)
    Go To Transfer
    Submit Transfer    ${TARGET_SELF}    ${AMOUNT_VALID}
    Validate Error    You cannot transfer to your own account.

# A1,B1 — valid transfer
TC09 โอนสำเร็จข้อมูลถูกต้อง (A1,B1)
    Go To Transfer
    ${old_balance}=    Get Balance
    Log To Console    Balance before transfer: ${old_balance}
    Submit Transfer   ${TARGET_VALID}   ${AMOUNT_VALID}
    Validate Success
    Sleep             2s
    Reload Page
    ${new_balance}=   Get Balance
    Should Be True    ${new_balance} < ${old_balance}    Balance did not decrease!

# A1,B2 — transfer all funds
TC010 โอนจำนวนเท่ายอดคงเหลือ (A1,B2)
    Go To Transfer
    ${old_balance}=    Get Balance
    Log To Console    Balance before transfer: ${old_balance}
    Submit Transfer   ${TARGET_VALID}   ${old_balance}
    Validate Success
    Sleep             2s
    Reload Page
    ${new_balance}=   Get Balance
    Log To Console    Balance after transfer: ${new_balance}
    Should Be Equal As Integers    ${new_balance}    0    Balance should be zero after full transfer
    Log To Console    Balance is zero after full transfer
