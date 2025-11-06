*** Settings ***
Resource    ../resources/imports.robot
Test Teardown  Close All Browsers

*** Test Cases ***
Verify registration form with all input field
    [Tags]    All Input
    Open Browser    https://panaryco.wixsite.com/myhotel  chrome
    Maximize Browser Window
    sleep   5