*** Settings ***
Library           SeleniumLibrary
Suite Setup       Login To Bank
Suite Teardown    Close Browser

*** Variables ***
${BROWSER}        chrome
${BASE_URL}       http://localhost:3000

${VALID_ACC}      6870333421
${PASSWORD}       1990
${AMOUNT}         500
${CLICK_COUNT}    5

*** Test Cases ***
Login to account
    Input text    //*[@id='accountId']    6870333421
    Input text    //*[@id='password']    1990
    Click Element    xpath=//button[@cid="lc"]

*** Keywords ***
Login To Bank
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    css:[cid="l1"]
    Input Text       css:[cid="l1"]    ${VALID_ACC}
    Input Password   css:[cid="l2"]    ${PASSWORD}
    Click Button     css:[cid="lc"]
    Wait Until Page Contains    Account ID:

Deposit Multiple Times
    Sleep    10s