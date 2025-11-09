*** Settings ***
Resource    ../resources/imports.robot
Test Teardown  Close All Browsers

*** Test Cases ***
TC01 -- 
    [Tags]    All Input
    Open Browser    http://localhost:3000/  chrome
    Maximize Browser Window
    sleep    1s
    Input text    //*[@id='accountId']    6870194521
    Input text    //*[@id='password']    1234
    Click Element    xpath=//button[@cid="lc"]
    sleep    1s
    Input text    //*[@cid='d1']    10000
    Click Element    xpath=//button[@cid="dc"]
    sleep    1s
    Input text    //*[@cid='w1']    999999
    Click Element    xpath=//button[@cid="wc"]
    sleep    5s