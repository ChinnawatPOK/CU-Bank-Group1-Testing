*** Settings ***
Resource    ../resources/imports.robot
Test Teardown  Close All Browsers


*** Variables ***
${LOGIN_URL}       http://localhost:3000
${ACCOUNT_URL}     http://localhost:3000/account
${BROWSER}         chrome

${LOGIN_ID}        1111111111
${PASSWORD}        1234
${TARGET_ACCOUNT}  2222222222
${INVALID_TARGET_ACCOUNT}  12345
${AMOUNT}          500

*** Test Cases ***
Transfer success
    [Tags]    Transfer

    # --- Step 1: Open login page ---
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    id=accountId    timeout=10s

    # --- Step 2: Perform login ---
    Input Text       id=accountId    ${LOGIN_ID}
    Input Password   id=password     ${PASSWORD}
    Click Button     xpath=//button[@cid="lc"]
    Sleep            3s

    # --- Step 3: Navigate to Account page ---
    Go To    ${ACCOUNT_URL}
    Wait Until Page Contains Element    xpath=//h2[text()="Transfer"]    timeout=10s


    # --- Step 4: Fill the Transfer form ---
    Input Text       css:[cid="t1"]    ${TARGET_ACCOUNT}
    Input Text       css:[cid="t2"]    ${AMOUNT}
    Capture Page Screenshot

    # --- Step 5: Use JavaScript to click Confirm (more reliable) ---
    Execute JavaScript    document.querySelector('button[cid="tc"]').click()
    Sleep    2s

    # --- Step 6: Verify submission ---
    Wait Until Page Contains    Confirm    timeout=5s
    Capture Page Screenshot

*** Test Cases ***
Invalid Target account