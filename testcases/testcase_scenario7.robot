*** Settings ***
Library    Browser
Library    String
Library    Collections
Suite Setup     Open CU Bank And Login
Suite Teardown  Close Browser
Test Teardown   Take Screenshot    fullPage=True

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
    New Browser    chromium    headless=False
    New Context
    New Page       ${BASE_URL}
    Wait For Elements State    ${SEL_LOGIN_HEADING}    visible    10s
    Fill Text      ${SEL_LOGIN_ACC}    ${ACC_NO}
    Fill Text      ${SEL_LOGIN_PW}     ${PASSWORD}
    Click          ${SEL_LOGIN_BTN}
    Wait Until Account Page Ready

Wait Until Account Page Ready
    Wait For Elements State    ${BILL_WATER}    visible    15s

*** Keywords ***
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
    Fill Text    ${BILL_AMOUNT_INPUT}    ${amount}

Click Bill Confirm
    Click        ${BILL_CONFIRM_BTN}

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
# ---------------- SCENARIO 7: Valid Inputs ----------------

TC7-01 Water bill + 150
    Ensure Balance At Least    10000
    Pay Bill And Expect Success    150    water
    Sleep    2s

TC7-02 Electric bill + 2000
    Ensure Balance At Least    9850
    Pay Bill And Expect Success    2000    electric
    sleep    2s

TC7-03 Phone bill + 300 (boundary min)
    Ensure Balance At Least    7850
    Pay Bill And Expect Success    300    phone
    sleep    2s

TC7-04 Phone bill 7750 (boundary max)
    Ensure Balance At Least    7850
    Pay Bill And Expect Success    7850    phone
    Sleep    2s