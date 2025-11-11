*** Settings ***
Library           SeleniumLibrary
Suite Setup       Login To Bank
Suite Teardown    Close Browser

# ไม่พึ่ง DB อีกต่อไป: ถ้าไฟล์ของคุณ import resources พวก Mongo ไว้ในที่อื่น ให้คอมเมนต์ออกสำหรับชุดนี้

*** Variables ***
${BASE_URL}         http://localhost:3000
${BROWSER}          chrome

# >>> ใช้ที่คุณให้มา <<<
${VALID_ACC}        6870194521
${PASSWORD}         1234

# ค่าที่ใช้ในเทส
${BALANCE_BASE}     1500
${WITHDRAW_OVER}    2000
${WITHDRAW_OK}      200
${WITHDRAW_ZERO}    0
${WITHDRAW_DEC}     100.5
${WITHDRAW_TEXT}    abc

# ข้อความจาก src หน้า Account
${MSG_INSUFFICIENT}     Your balance is not enough to complete the withdrawal.
${MSG_GT_ZERO}          The amount must be greater than 0. Please enter a positive number.
${MSG_DECIMAL}          The balance amount must be a whole number with no decimals.
${MSG_INVALID}          Invalid balance amount. Please enter a valid number.

*** Keywords ***
Login To Bank
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    # สมมติหน้า login มี cid l1/l2/lc ตามสคริปต์ก่อนหน้า (ถ้าไม่ตรง แจ้ง cid ที่ถูกต้องมาได้)
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
    # รอจนกว่าจะเห็นตัวเลขในตำแหน่ง Balance จริง ๆ (API อาจหน่วง)
    Wait Until Keyword Succeeds    10x    1s    Balance Element Should Contain Digits

Balance Element Should Contain Digits
    ${txt}=    Get Text    xpath=(//h2[normalize-space()="Balance:"]/following-sibling::h1)[1]
    Should Match Regexp    ${txt}    ^-?\\d+$

Get Balance
    Wait For Balance Number
    ${bal_text}=    Get Text    xpath=(//h2[normalize-space()="Balance:"]/following-sibling::h1)[1]
    ${bal}=         Convert To Integer    ${bal_text}
    RETURN          ${bal}

Ensure Balance Is
    [Arguments]    ${expected}
    Go To Account
    ${current}=    Get Balance
    ${diff}=       Evaluate    ${expected} - ${current}
    Run Keyword If    ${diff} > 0    Deposit By Amount    ${diff}
    ...    ELSE IF    ${diff} < 0    Withdraw By Amount   ${diff * -1}
    # diff==0 ก็ไม่ทำอะไร
    Reload Page
    ${after}=    Get Balance
    Should Be Equal As Integers    ${after}    ${expected}

Deposit By Amount
    [Arguments]    ${amount}
    # ไปที่ส่วน Deposit (ใช้ cid='d1' และปุ่ม cid='dc' จากโค้ด)
    Scroll Element Into View    xpath=//h2[normalize-space()="Deposit"]
    Wait Until Page Contains Element    xpath=//h2[normalize-space()="Deposit"]/following::input[@cid="d1"][1]    10s
    Clear Element Text          xpath=//h2[normalize-space()="Deposit"]/following::input[@cid="d1"][1]
    Input Text                  xpath=//h2[normalize-space()="Deposit"]/following::input[@cid="d1"][1]    ${amount}
    Click Button                css:[cid="dc"]
    Sleep    1s
    # หน้ารีโหลดเองใน src; เผื่อไว้
    Wait Until Page Contains    Account ID:    10s

Withdraw By Amount
    [Arguments]    ${amount}
    Go To Withdraw
    Wait Until Page Contains Element    xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]    10s
    Clear Element Text                  xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]
    Input Text                          xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]    ${amount}
    Click Button                        css:[cid="wc"]
    Sleep    1s

Submit Withdraw (Plain)
    [Arguments]    ${amount}
    Go To Withdraw
    Wait Until Page Contains Element    xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]    10s
    Clear Element Text                  xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]
    Input Text                          xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]    ${amount}
    Click Button                        css:[cid="wc"]
    Sleep    1s

Submit Withdraw (Force JS Value)
    [Arguments]    ${value_as_text}
    Go To Withdraw
    ${locator}=    Set Variable    //h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]
    Wait Until Page Contains Element    xpath=${locator}    10s
    ${js}=    Catenate    SEPARATOR=\n
    ...    (function(){
    ...      const el = document.evaluate("${locator}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
    ...      el.value = "${value_as_text}";
    ...      const ev1 = new Event('input', {bubbles:true});
    ...      const ev2 = new Event('change', {bubbles:true});
    ...      el.dispatchEvent(ev1); el.dispatchEvent(ev2);
    ...    })();
    Execute Javascript    ${js}
    Click Button          css:[cid="wc"]
    Sleep    1s

Validate Withdraw Error
    [Arguments]    ${msg}
    Wait Until Element Is Visible    css:[cid="withdraw-error-mes"]    5s
    ${txt}=    Get Text    css:[cid="withdraw-error-mes"]
    Should Be Equal As Strings    ${txt}    ${msg}

Validate Balance Equals
    [Arguments]    ${expected}
    ${cur}=    Get Balance
    Should Be Equal As Integers    ${cur}    ${expected}

*** Test Cases ***
# TC01 — Withdraw fail (> balance)
TC01 Withdraw fail (> balance)
    Ensure Balance Is        ${BALANCE_BASE}
    ${before}=               Get Balance
    Should Be Equal As Integers    ${before}    ${BALANCE_BASE}
    Submit Withdraw (Plain)        ${WITHDRAW_OVER}     # 2000
    Validate Withdraw Error        ${MSG_INSUFFICIENT}
    Validate Balance Equals        ${BALANCE_BASE}

# TC02 — Withdraw success (≤ balance) : 1500 - 200 = 1300
TC02 Withdraw success (≤ balance)
    Ensure Balance Is        ${BALANCE_BASE}
    Submit Withdraw (Plain)  ${WITHDRAW_OK}
    Sleep    1s
    Reload Page
    Validate Balance Equals  1300

# TC03 — Withdraw invalid (≤ 0)
TC03 Withdraw invalid (≤ 0)
    Ensure Balance Is        ${BALANCE_BASE}
    ${before}=               Get Balance
    Submit Withdraw (Plain)  ${WITHDRAW_ZERO}
    Validate Withdraw Error  ${MSG_GT_ZERO}
    Validate Balance Equals  ${before}

# TC04 — Withdraw invalid (non-integer / non-numeric)
# หมายเหตุ: โค้ดจริงใช้ parseInt → 100.5 จะถูกตีเป็น 100 (อาจ "ผ่าน")
# เทสนี้ใช้ JS ยัดค่าเพื่อตรวจตามสเปก ถ้าแอปไม่แสดง error เทสจะล้ม → ช่วยเผย defect
TC04 Withdraw invalid (non-integer / non-numeric)
    Ensure Balance Is        ${BALANCE_BASE}
    ${before}=               Get Balance

    # 4.1 decimal
    Submit Withdraw (Force JS Value)    ${WITHDRAW_DEC}
    Validate Withdraw Error             ${MSG_DECIMAL}
    Validate Balance Equals             ${before}

    # 4.2 non-numeric
    Submit Withdraw (Force JS Value)    ${WITHDRAW_TEXT}
    Validate Withdraw Error             ${MSG_INVALID}
    Validate Balance Equals             ${before}
