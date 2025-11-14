*** Settings ***
Library           SeleniumLibrary
Resource          ../../keywords/common/cubankCommonKeywords.robot
Resource          ../../keywords/common/mongoDatabaseKeywords.robot

Suite Setup       Run Keywords  Delete Account By Id    ${VALID_ACC}
                  ...   AND   Create New User    ${NAME}    ${VALID_ACC}    ${PASSWORD}   
                  ...   AND   Open Browser First
                  ...   AND   Login with account number and password  accountNumber=${VALID_ACC}  password=${PASSWORD}
Suite Teardown    Run Keywords  Close Browser
                  ...   AND    Delete Account By Id    ${VALID_ACC}


*** Variables ***
${BASE_URL}       http://localhost:3000
${BROWSER}        chrome

${NAME}           Litle Chacoal
${PASSWORD}       1111
${VALID_ACC}    1234567894      
${PASSWORD}       1234


${BILL_WATER}     water
${BILL_ELECTRIC}  electric
${BILL_PHONE}     phone

# Test Amounts
${AMOUNT_VALID1}      150
${AMOUNT_VALID2}      2000
${AMOUNT_VALID3}      300
${AMOUNT_EQUAL}       7550
${AMOUNT_ZERO}        0
${AMOUNT_NEGATIVE}   -500
${AMOUNT_OVER}        50000
${AMOUNT_NON_INTEGER}    e1

*** Keywords ***
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


*** Test Cases ***
TC40 จำนวนเงินเป็นศูนย์
    Go To Bill Payment
    Submit Bill Payment    ${BILL_ELECTRIC}    ${AMOUNT_ZERO}
    Validate Error    The amount must be greater than 0. Please enter a positive number.

TC41 จำนวนเงินติดลบ
    Go To Bill Payment
    Submit Bill Payment    ${BILL_ELECTRIC}    ${AMOUNT_NEGATIVE}
    Validate Error    The amount must be greater than 0. Please enter a positive number.

TC42 ยอดเกินกว่ายอดเงินคงเหลือ
    Go To Bill Payment
    Submit Bill Payment    ${BILL_PHONE}    ${AMOUNT_OVER}
    Validate Error    Your balance is not enough to complete the bill payment.

TC43 ยอดเงินไม่เป็นตัวเลข
    Go To Bill Payment
    Submit Bill Payment    ${BILL_PHONE}    ${AMOUNT_NON_INTEGER}
    Validate Error    Invalid balance amount. Please enter a valid number.