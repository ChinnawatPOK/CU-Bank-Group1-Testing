*** Settings ***
Resource    ../resources/imports.robot
Suite Setup    Open Browser    http://localhost:3000/    chrome
Suite Teardown    Close Browser

*** Variables ***
${VALID_ACC}         1234567890
${VALID_PASS}        1234

*** Test Cases ***

Login Account Short
    Input Text    id=accountId     12345
    Input Text    id=password      ${VALID_PASS}
    Click Button  id=lc
    Wait Until Page Contains    Your account ID must be exactly 10 digits long.

Login Account Long
    Input Text    id=accountId     1234567890123456
    Input Text    id=password      ${VALID_PASS}
    Click Button  id=lc
    Wait Until Page Contains    Your account ID must be exactly 10 digits long.

Login Account NonNumeric
    Input Text    id=accountId     ABCDEFGHIJ
    Input Text    id=password      ${VALID_PASS}
    Click Button  id=lc           
    Wait Until Page Contains    Your account ID should contain numbers only.

Login Password Too Short
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      12
    Click Button  id=lc
    Wait Until Page Contains    Your password must be exactly 4 digits long.

Login Password Too Long
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      12345678
    Click Button  id=lc
    Wait Until Page Contains    Your password must be exactly 4 digits long.

Login Password NonNumeric
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      AV12
    Click Button  id=lc           
    Wait Until Page Contains    Your password should contain numbers only.