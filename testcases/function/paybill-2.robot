*** Settings ***
Library           SeleniumLibrary
Suite Setup       Run Keywords  Delete Account By Id    ${VALID_ACC}
                  ...   AND   Create New User    ${NAME}    ${VALID_ACC}    ${PASSWORD}   
                  ...   AND   Open Browser First
                  ...   AND   Login with account number and password  accountNumber=${VALID_ACC}  password=${PASSWORD}
Suite Teardown    Run Keywords  Close Browser
                  ...   AND    Delete Account By Id    ${VALID_ACC}

Resource          ../../keywords/common/cubankCommonKeywords.robot
Resource          ../../keywords/common/mongoDatabaseKeywords.robot


Variables    ../../resources/testdata/scenerio7.yml

*** Variables ***
${BASE_URL}       http://localhost:3000
${BROWSER}        chrome

${NAME}           Litle Chacoal
${PASSWORD}       1111
${VALID_ACC}    1234567894      
${PASSWORD}       1234

# Bill Types (radio values)
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


Validate Success
    [Documentation]    Validate successful payment confirmation appears.
    Wait Until Page Contains    Confirm    timeout=10s

*** Test Cases ***
TC001 ชำระค่าน้ำ 150 บาท
    [Setup]   Run Keywords    Delete Transactions On Account    ${VALID_ACC}
    ...       AND   Update Balance By Amount    ${VALID_ACC}    10000
    Go To Bill Payment
    Submit Bill Payment    ${BILL_WATER}    ${AMOUNT_VALID1}
    Validate Success
    Reload Page
    Verify Balance On Title    balance=9850
    Verify History transaction should correct   expected_data=${scenerio7.TC_001.expected_history}


TC002 ชำระค่าไฟ 2000 บาท
    [Setup]    Delete Transactions On Account    ${VALID_ACC}
    Go To Bill Payment
    Submit Bill Payment    ${BILL_ELECTRIC}    ${AMOUNT_VALID2}
    Validate Success
    Reload Page
    Verify Balance On Title    balance=7850
    Verify History transaction should correct   expected_data=${scenerio7.TC_002.expected_history}

TC003 ชำระค่าโทรศัพท์ 300 บาท
    [Setup]    Delete Transactions On Account    ${VALID_ACC}
    Go To Bill Payment
    Submit Bill Payment    ${BILL_PHONE}    ${AMOUNT_VALID3}
    Validate Success
    Reload Page
    Verify Balance On Title    balance=7550
    Verify History transaction should correct   expected_data=${scenerio7.TC_003.expected_history}


TC004 ชำระเท่ากับยอดคงเหลือ
    [Setup]    Delete Transactions On Account    ${VALID_ACC}
    Go To Bill Payment
    Submit Bill Payment    ${BILL_WATER}    ${AMOUNT_EQUAL}
    Validate Success
    Reload Page
    Verify History transaction should correct   expected_data=${scenerio7.TC_004.expected_history}
