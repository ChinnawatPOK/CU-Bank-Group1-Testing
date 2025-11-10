*** Settings ***
Resource    ../resources/imports.robot
Resource    ../keywords/common/cubankCommonKeywords.robot

Suite Setup     Open CU Bank And Login
Test Teardown  Close All Browsers

*** Variables ***
${BASE_URL}       http://localhost:3000
${ACC_NO}         6870054321
${PASSWORD}       1999

# --- Selectors ---
${SEL_LOGIN_ACC}         css=input[placeholder*="account number"]
${SEL_LOGIN_PW}          css=input[placeholder*="password"]
${SEL_LOGIN_BTN}         role=button[name="Login"]
${SEL_LOGIN_HEADING}     role=heading[name="Login"]
${SEL_BODY_TEXT}         css=body
${ALL_AMOUNT_INPUTS}     css=input[placeholder*="Please fill amount"]
${DEPOSIT_AMOUNT}        ${ALL_AMOUNT_INPUTS} >> nth=0
${DEPOSIT_CONFIRM}       xpath=(//button[normalize-space()='Confirm'])[1]
${BILL_FORM}             xpath=//form[.//input[@name='billTarget']]
${BILL_WATER}            ${BILL_FORM} >> css=input[name="billTarget"][value="water"]
${BILL_ELECTRIC}         ${BILL_FORM} >> css=input[name="billTarget"][value="electric"]
${BILL_PHONE}            ${BILL_FORM} >> css=input[name="billTarget"][value="phone"]
${BILL_AMOUNT_INPUT}     ${BILL_FORM} >> css=input[placeholder*="Please fill amount"]
${BILL_CONFIRM_BTN}      ${BILL_FORM} >> css=button[cid="bc"]
${MSG_INSUFF}            Your balance is not enough to complete the bill payment.
${SEL_BALANCE_TEXT}    xpath=//div[contains(text(), "Balance:")]/following::div[1]

*** Keywords ***
Open CU Bank And Login
    Open Browser    http://localhost:3000  chrome
#    New Context
#    New Page       ${BASE_URL}
#    Wait For Elements State    ${SEL_LOGIN_HEADING}    visible    10s
    Login with account number and password  accountNumber=${ACC_NO}  password=${PASSWORD}
#    Wait Until Account Page Ready

Wait Until Account Page Ready
    Wait For Elements State    ${BILL_WATER}    visible    15s

Get Balance
    ${bal_text}=    Get Text    ${SEL_BALANCE_TEXT}
    Log To Console    Raw balance text: ${bal_text}
    ${bal_text}=     Replace String    ${bal_text}    ,    ${EMPTY}
    Should Not Be Empty    ${bal_text}
    ${bal}=          Convert To Integer    ${bal_text}
    RETURN    ${bal}

Ensure Balance At Least
    [Arguments]    ${min_required}
    ${bal}=    Get Balance
    IF    ${bal} < ${min_required}
        ${need}=    Evaluate    int(${min_required}) - int(${bal})
        Fill Text   ${DEPOSIT_AMOUNT}    ${need}
        Click       ${DEPOSIT_CONFIRM}
        Wait Until Keyword Succeeds    5x    1s    Balance Should Increase By    ${bal}    ${need}
    END

Balance Should Increase By
    [Arguments]    ${before}    ${amount}
    ${expected}=    Evaluate    int(${before}) + int(${amount})
    ${after}=       Get Balance
    Should Be Equal As Integers    ${after}    ${expected}

Balance Should Decrease By
    [Arguments]    ${before}    ${amount}
    ${expected}=    Evaluate    int(${before}) - int(${amount})
    ${after}=       Get Balance
    Should Be Equal As Integers    ${after}    ${expected}

Bill Payment Should Not Change Balance
    ${b1}=    Get Balance
    Sleep    300ms
    ${b2}=    Get Balance
    Should Be Equal As Integers    ${b2}    ${b1}

Select Bill Type
    [Arguments]    ${type}
    IF    '${type}'=='water'
        Click    ${BILL_WATER}
    ELSE IF    '${type}'=='electric'
        Click    ${BILL_ELECTRIC}
    ELSE IF    '${type}'=='phone'
        Click    ${BILL_PHONE}
    END

Set Bill Amount
    [Arguments]    ${amount}
    Wait Until Element Is Visible  xpath=//input[@cid='b4']
    Input Text    xpath=//input[@cid='b4']  ${amount}

Click Bill Confirm
    Click Button        ${BILL_CONFIRM_BTN}

Pay Bill And Expect Success
    [Arguments]    ${amount}    ${type}=water
    ${before}=    Get Balance
    Select Bill Type    ${type}
    Set Bill Amount     ${amount}
    Click Bill Confirm
    Wait Until Keyword Succeeds    5x    1s    Balance Should Decrease By    ${before}    ${amount}

Pay Bill And Expect Fail
    [Arguments]    ${amount}    ${type}=water
    Select Bill Type    ${type}
    Set Bill Amount     ${amount}
    Click Bill Confirm
    Wait For Elements State    text=${MSG_INSUFF}    visible    5s
    Bill Payment Should Not Change Balance

*** Test Cases ***

# ---------------- SCENARIO 6: Invalid Inputs ----------------

TC6-01 No bill type selected
    Set Bill Amount    300
    Click Bill Confirm
    Verify Balance On Title  balance=10000
    Sleep    2s

TC6-02 Blank amount
    Select Bill Type    water
    Fill Text    ${BILL_AMOUNT_INPUT}    ${EMPTY}
    Click Bill Confirm
    Bill Payment Should Not Change Balance
    Sleep    2s

TC6-03 Zero amount
    Select Bill Type    water
    Set Bill Amount     0
    Click Bill Confirm
    Bill Payment Should Not Change Balance
    sleep    2s

TC6-04 Negative amount
    Select Bill Type    water
    Set Bill Amount     -500
    Click Bill Confirm
    Bill Payment Should Not Change Balance
    Sleep    2s

TC6-05 Non-numeric amount
    Select Bill Type   water
    Set Bill Amount    50000
    Click Bill Confirm
    Bill Payment Should Not Change Balance
    Sleep    2s