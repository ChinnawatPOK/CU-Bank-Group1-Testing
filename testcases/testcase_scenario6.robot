*** Settings ***
Library           SeleniumLibrary
Suite Setup       Login To Bank
Suite Teardown    Close Browser

Resource          ../keywords/common/cubankCommonKeywords.robot
Resource          ../keywords/common/mongoDatabaseKeywords.robot

Variables         ../resources/testdata/scenario_bill.yml


*** Variables ***
${BASE_URL}       http://localhost:3000
${BROWSER}        chrome

${VALID_ACC}      1234567892
${PASSWORD}       1234

# Bill Types (radio values)
${BILL_WATER}     water
${BILL_ELECTRIC}  electric
${BILL_PHONE}     phone

# Test Amounts
${AMOUNT_VALID1}      150
${AMOUNT_VALID2}      2000
${AMOUNT_VALID3}      300
${AMOUNT_EQUAL}       7750
${AMOUNT_ZERO}        0
${AMOUNT_NEGATIVE}   -500
${AMOUNT_OVER}        50000


*** Keywords ***
Login To Bank
    [Documentation]    Logs into the CU Bank application.
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    css:[cid="l1"]    timeout=10s
    Input Text       css:[cid="l1"]    ${VALID_ACC}
    Input Password   css:[cid="l2"]    ${PASSWORD}
    Click Button     css:[cid="lc"]
    Wait Until Page Contains    Account ID:    timeout=10s


Go To Bill Payment
    [Documentation]    Navigate to Bill Payment page and verify the form is visible.
    Go To    ${BASE_URL}/account
    Wait Until Page Contains Element    xpath=//h2[normalize-space(.)="Bill Payment"]    timeout=10s
    Scroll Element Into View            xpath=//h2[normalize-space(.)="Bill Payment"]
    Wait Until Page Contains Element    css:input[name="billTarget"]    timeout=5s
    Wait Until Page Contains Element    id:amount    timeout=5s


Submit Bill Payment
    [Documentation]    Select bill type (if provided), input amount, and click Confirm.
    [Arguments]    ${bill_type}=    ${amount}=
    Run Keyword If    '${bill_type}' != ''    Click Element    css:input[name="billTarget"][value="${bill_type}"]
    Wait Until Element Is Visible    id:amount    timeout=5s
    Clear Element Text               id:amount
        Input Text     xpath=//h2[text()="Transfer"]/following::input[@cid="b4"][1]    ${amount}
    Wait Until Element Is Visible    css:button[cid="bc"]    timeout=5s
    Click Button                     css:button[cid="bc"]
    Sleep    1s


Validate Error
    [Documentation]    Validate error message shown for failed bill payment.
    [Arguments]    ${msg}
    Wait Until Page Contains    ${msg}    timeout=5s
    Capture Page Screenshot


Validate Success
    [Documentation]    Validate successful payment confirmation appears.
    Wait Until Page Contains    Confirm    timeout=10s
    Capture Page Screenshot


Get Balance
    [Documentation]    Read the numeric account balance from the UI.
    ${bal_text}=    Get Text    xpath=(//h2[text()="Balance:"]/following-sibling::h1)[1]
    ${bal}=         Convert To Integer    ${bal_text}
    [Return]        ${bal}


*** Test Cases ***
# =========================================================
# Scenario 6: Login ผ่านแต่จ่ายบิลไม่ผ่าน (Invalid cases)
# =========================================================

TC01 ไม่เลือกบิล
    [Setup]   Update Balance By Amount    10000
    Go To Bill Payment
    Submit Bill Payment    ${EMPTY}    300
    Validate Error    Please select one of these options.

TC02 จำนวนเงินว่างเปล่า
    Go To Bill Payment
    Submit Bill Payment    ${BILL_WATER}    ${EMPTY}
    Validate Error    Please enter the amount to pay.

TC03 จำนวนเงินเป็นศูนย์
    Go To Bill Payment
    Submit Bill Payment    ${BILL_ELECTRIC}    ${AMOUNT_ZERO}
    Validate Error    The amount must be greater than 0. Please enter a positive number.

TC04 จำนวนเงินติดลบ
    Go To Bill Payment
    Submit Bill Payment    ${BILL_ELECTRIC}    ${AMOUNT_NEGATIVE}
    Validate Error    The amount must be greater than 0. Please enter a positive number.

TC05 ยอดเกินกว่ายอดเงินคงเหลือ
    Go To Bill Payment
    Submit Bill Payment    ${BILL_PHONE}    ${AMOUNT_OVER}
    Validate Error    Your balance is not enough to complete the bill payment.


# =========================================================
# Scenario 7: Login ผ่านและจ่ายบิลสำเร็จ (Valid cases)
# =========================================================

TC06 ชำระค่าน้ำ 150 บาท
    [Setup]   Update Balance By Amount    10000
    Go To Bill Payment
    ${old_balance}=    Get Balance
    Submit Bill Payment    ${BILL_WATER}    ${AMOUNT_VALID1}
    Validate Success
    Reload Page
    Verify Balance On Title    balance=${old_balance - ${AMOUNT_VALID1}}


TC07 ชำระค่าไฟ 2000 บาท
    [Setup]   Update Balance By Amount    9850
    Go To Bill Payment
    ${old_balance}=    Get Balance
    Submit Bill Payment    ${BILL_ELECTRIC}    ${AMOUNT_VALID2}
    Validate Success
    Reload Page
    Verify Balance On Title    balance=${old_balance - ${AMOUNT_VALID2}}

TC08 ชำระค่าโทรศัพท์ 300 บาท
    [Setup]   Update Balance By Amount    7850
    Go To Bill Payment
    ${old_balance}=    Get Balance
    Submit Bill Payment    ${BILL_PHONE}    ${AMOUNT_VALID3}
    Validate Success
    Reload Page
    Verify Balance On Title    balance=${old_balance - ${AMOUNT_VALID3}}


TC09 ชำระเท่ากับยอดคงเหลือ
    [Setup]   Update Balance By Amount    7750
    Go To Bill Payment
    ${old_balance}=    Get Balance
    Submit Bill Payment    ${BILL_WATER}    ${AMOUNT_EQUAL}
    Validate Success
    Reload Page
    Verify Balance On Title    balance=0
