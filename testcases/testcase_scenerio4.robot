*** Settings ***
Library           SeleniumLibrary
Suite Setup       Login To Bank
Suite Teardown    Close Browser

Resource          ../resources/imports.robot
Resource          ../keywords/common/mongoDatabaseKeywords.robot
Resource          ../keywords/common/cubankCommonKeywords.robot

Variables    ../resources/testdata/scenerio4.yml

*** Variables ***
${BASE_URL}           http://localhost:3000
${BROWSER}            chrome

${VALID_ACC}          6870194521
${PASSWORD}           1234

${BALANCE_BASE}       1500
${WITHDRAW_OVER}      2000
${WITHDRAW_OK}        200
${WITHDRAW_ZERO}      0
${WITHDRAW_DEC}       100.5

${MSG_INSUFFICIENT}   Your balance is not enough to complete the withdrawal.
${MSG_GT_ZERO}        The amount must be greater than 0. Please enter a positive number.
${MSG_DECIMAL}        The balance amount must be a whole number with no decimals.
${MSG_INVALID}        Invalid balance amount. Please enter a valid number.


*** Keywords ***
Login To Bank
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    css:[cid="l1"]    15s
    Input Text       css:[cid="l1"]    ${VALID_ACC}
    Input Password   css:[cid="l2"]    ${PASSWORD}
    Click Button     css:[cid="lc"]
    Wait Until Page Contains            Account ID:    15s

Go To Account
    Go To    ${BASE_URL}/account
    Wait Until Page Contains    Account ID:
    Page Should Contain         Balance:

Go To Withdraw
    Go To Account
    Wait Until Page Contains Element    xpath=//h2[normalize-space()="Withdraw"]    15s
    Scroll Element Into View            xpath=//h2[normalize-space()="Withdraw"]

Wait For Balance Number
    Wait Until Keyword Succeeds    10x    1s    Balance Element Should Contain Digits

Balance Element Should Contain Digits
    ${txt}=    Get Text    xpath=(//h2[normalize-space()="Balance:"]/following-sibling::h1)[1]
    Should Match Regexp    ${txt}    ^-?\\d+$

Get Balance
    Wait For Balance Number
    ${bal_text}=    Get Text    xpath=(//h2[normalize-space()="Balance:"]/following-sibling::h1)[1]
    ${bal}=         Convert To Integer    ${bal_text}
    RETURN          ${bal}

Submit Withdraw
    [Arguments]    ${amount}
    Go To Withdraw
    Wait Until Page Contains Element    xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]    10s
    Clear Element Text                  xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]
    Input Text                          xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]    ${amount}
    Click Button                        css:[cid="wc"]
    Sleep    500ms

Validate Withdraw Error
    [Arguments]    ${msg}
    Wait Until Element Is Visible    css:[cid="withdraw-error-mes"]    5s
    ${txt}=    Get Text    css:[cid="withdraw-error-mes"]
    Should Be Equal As Strings    ${txt}    ${msg}
    Capture Page Screenshot

Validate Balance Equals
    [Arguments]    ${expected}
    ${cur}=    Get Balance
    Should Be Equal As Integers    ${cur}    ${expected}

Validate Success
    Wait Until Page Contains    Confirm    timeout=5s

Verify History transaction should correct_windows
    [Arguments]    ${expected_data}
    ${index}=  Set Variable   1
    FOR  ${expected_history_txn}  IN  @{expected_data}
         Wait Until Element Is Visible  xpath=//div[@class="history-list"]/div[@class="account-form"]/div[${index}]
         Wait Until Element Is Visible  xpath=//div[@class="history-list"]/div[@class="account-form"]/div[${index}]
         ${actual_type}=       Get Text          xpath=(//div[@class="history-list"]/div[@class="account-form"]/div/div[@class="Card_card__Q7ZOF"]/div)[${index}]/h2[1]
         ${actual_amount}=     Get Text          xpath=(//div[@class="history-list"]/div[@class="account-form"]/div/div[@class="Card_card__Q7ZOF"]/div)[${index}]/p[3]
         ${actual_balance}=    Get Text          xpath=(//div[@class="history-list"]/div[@class="account-form"]/div/div[@class="Card_card__Q7ZOF"]/div)[${index}]/p[4]
         Should Contain    ${actual_type}    ${expected_history_txn.type}
         Should Contain    ${actual_amount}   amount: ${expected_history_txn.amount}
         Should Contain    ${actual_balance}   balance: ${expected_history_txn.balance}
         ${index}=  Evaluate  ${index} + 1
    END

# --------------------- NEW: อ่าน popup validation ของ browser ---------------------
Get Withdraw Native Tooltip
    [Documentation]    อ่านข้อความ native validation ของ <input type="number"> (frontend)
    
    ${msg}=    Execute Javascript    return document.querySelector('input[cid="w1"]').validationMessage;
    Log To Console    Withdraw tooltip: ${msg}
    [Return]    ${msg}

# --------------------- NEW: ใส่ค่า non-numeric ด้วย JS (type=number ไม่ยอม) -----
Set Withdraw Value Via JS
    [Arguments]    ${text}
    
    Execute Javascript
    ...    (function(val){
    ...      const el = document.querySelector('input[cid="w1"]');
    ...      if(!el) return;
    ...      el.value = val;
    ...      el.dispatchEvent(new Event('input', {bubbles:true}));
    ...      el.dispatchEvent(new Event('change', {bubbles:true}));
    ...    })(arguments[0]);
    ...    ${text}

# --------------------- NEW: ช่วยตรวจหลายประโยคที่เป็นไปได้ของ tooltip --------
Should Contain Any
    [Arguments]    ${actual}    @{candidates}
    
    ${ok}=    Set Variable    False
    FOR    ${c}    IN    @{candidates}
        ${found}=    Run Keyword And Return Status    Should Contain    ${actual}    ${c}
        Run Keyword If    ${found}    ${ok}=    Set Variable    True
    END
    Run Keyword Unless    ${ok}    Fail    Actual text did not contain any candidate.\nActual: ${actual}\nCandidates: ${candidates}


*** Test Cases ***
# ============================ TC01 ============================
# Withdraw fail (> balance)
TC01 Withdraw fail (> balance)
    Delete Transactions On Account  ${VALID_ACC}
    Update Balance By Amount    ${VALID_ACC}  ${BALANCE_BASE}
    Go To Account
    Reload Page
    ${before}=    Get Balance
    Should Be Equal As Integers    ${before}    ${BALANCE_BASE}
    Verify History transaction should empty

    Submit Withdraw      ${WITHDRAW_OVER}
    Validate Withdraw Error      ${MSG_INSUFFICIENT}
    Validate Balance Equals      ${BALANCE_BASE}
    Verify History transaction should empty

# ============================ TC02 ============================
# Withdraw success (≤ balance)
TC02 Withdraw success (≤ balance)
    Delete Transactions On Account  ${VALID_ACC}
    Update Balance By Amount    ${VALID_ACC}  ${BALANCE_BASE}
    Go To Account
    Reload Page
    ${before}=    Get Balance
    Should Be Equal As Integers    ${before}    ${BALANCE_BASE}

    Submit Withdraw    ${WITHDRAW_OK}
    Validate Success
    Sleep    2s
    Reload Page
    Verify Balance On Title    1300
    Sleep    200s
    Verify History transaction should correct_windows   expected_data=${scenerio4.TC_02.expected_history}

# ============================ TC03 ============================
# Withdraw invalid (≤ 0) – ตรวจข้อความจาก backend
TC03 Withdraw invalid (≤ 0)
    Delete Transactions On Account  ${VALID_ACC}
    Update Balance By Amount    ${VALID_ACC}  ${BALANCE_BASE}
    Go To Account
    Reload Page
    ${before}=    Get Balance
    Should Be Equal As Integers    ${before}    ${BALANCE_BASE}
    Verify History transaction should empty

    Submit Withdraw      ${WITHDRAW_ZERO}
    Validate Withdraw Error      ${MSG_GT_ZERO}
    Validate Balance Equals      ${BALANCE_BASE}
    Verify History transaction should empty

# ============================ TC04 ============================
# Withdraw invalid (decimal & non-numeric) – ตรวจ popup ของ browser (frontend)
TC04 Withdraw invalid (non-integer / non-numeric)
    Delete Transactions On Account  ${VALID_ACC}
    Update Balance By Amount    ${VALID_ACC}  ${BALANCE_BASE}
    Go To Account
    Reload Page
    ${before}=    Get Balance
    Should Be Equal As Integers    ${before}    ${BALANCE_BASE}
    Verify History transaction should empty

    # 4.1 decimal → browser tooltip จะบอก "Please enter a valid value ..." และ nearest values
    
    Go To Withdraw
    Clear Element Text    css:[cid="w1"]
    Input Text            css:[cid="w1"]    ${WITHDRAW_DEC}
    Click Button          css:[cid="wc"]
    ${tip1}=    Get Withdraw Native Tooltip
    Should Contain Any    ${tip1}    Please enter a valid value.    nearest valid values

    Validate Balance Equals             ${BALANCE_BASE}
    Verify History transaction should empty
