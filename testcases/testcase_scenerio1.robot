*** Settings ***
Resource    ../resources/imports.robot
Suite Setup    Open Browser    http://localhost:3000/register    chrome
Suite Teardown    Close Browser

*** Variables ***
${VALID_ACC}         3434343434
${VALID_PASS}        1234
${VALID_FIRST}       Nong
${VALID_LAST}        Chacoal

*** Test Cases ***

Register Account Short
    Input Text    id=accountId     12345
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Click Button  id=rc
    Wait Until Page Contains    Your account ID must be exactly 10 digits long.

Register Account Long
    Input Text    id=accountId     1234567890123456
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Click Button  id=rc
    Wait Until Page Contains    Your account ID must be exactly 10 digits long.

Register Account NonNumeric
    Input Text    id=accountId     ABCDEFGHIJ
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Click Button  id=rc           
    Wait Until Page Contains    Your account ID should contain numbers only.

Register Password Too Short
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      12
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Click Button  id=rc
    Wait Until Page Contains    Your password must be exactly 4 digits long.

Register Password Too Long
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      12345678
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Click Button  id=rc
    Wait Until Page Contains    Your password must be exactly 4 digits long.

Register Account NonNumeric
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      AV12
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Click Button  id=rc           
    Wait Until Page Contains    Your password should contain numbers only.

Register Missing FirstName
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     
    Input Text    id=lastName      ${VALID_LAST}
    Click Button  id=rc
    Wait Until Page Contains    Please fill your first name

Register Missing LastName
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      
    Click Button  id=rc
    Wait Until Page Contains    Please fill your last name

Register Name Too Long
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     Supercalifragilisticexpialidocious
    Input Text    id=lastName      TestTest
    Click Button  id=rc
    Wait Until Page Contains    The combined length of your first and last name must not exceed 30 characters.

Register Success
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Click Button  id=rc
    Wait Until Location Contains    /
