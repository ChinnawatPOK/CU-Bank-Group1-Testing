*** Settings ***
Resource    ../resources/imports.robot
Test Teardown  Close All Browsers

*** Test Cases ***
Verify registration form with all input field
    [Tags]    All Input
    Open Browser    http://localhost:3000/  chrome
    Maximize Browser Window
    Input text    //*[@id='input_48']    studentFirstName
    sleep   1000s