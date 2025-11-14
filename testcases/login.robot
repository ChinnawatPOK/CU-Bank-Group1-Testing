*** Settings ***
Resource    ../resources/imports.robot
Resource    ../keywords/common/mongoDatabaseKeywords.robot
Resource    ../keywords/common/cubankCommonKeywords.robot
Resource    ../keywords/common/mongoDatabaseKeywords.robot
Suite Setup       Run Keywords  Delete Account By Id  ${VALID_ACC}
                  ...   AND   Create New User  ${NAME}   ${VALID_ACC}  ${PASSWORD}
                  ...   AND   Open Browser First
Suite Teardown    Run Keywords  Close Browser
                  ...   AND    Delete Account By Id  ${VALID_ACC}

*** Variables ***
${VALID_ACC}         1234567897
${INVALID_ACC}    0000000000
${VALID_PASS}        1234
${INVALID_PASS}    0000
${NAME}           Litle Chacoal
${PASSWORD}       1111


*** Keywords ***
Validate Error
    [Arguments]    ${msg}
    Wait Until Element Is Visible    css:[cid="login-error-mes"]    timeout=5s
    ${txt}=    Get Text    css:[cid="login-error-mes"]
    Should Be Equal As Strings    ${txt}    ${msg}

*** Test Cases ***
Login success
    Login with account number and password  accountNumber=${VALID_ACC}  password=${PASSWORD}

Login Account Short
    Input Text    id=accountId     12345
    Input Text    id=password      ${VALID_PASS}
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()
    Validate Error    Your account ID must be exactly 10 digits long.

Login Account Long
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     1234567890123456
    Input Text    id=password      ${VALID_PASS}
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()
    Validate Error    Your account ID must be exactly 10 digits long.

Login Account NonNumeric
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ABCDEFGHIJ
    Input Text    id=password      ${VALID_PASS}
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()        
    Validate Error    Your account ID should contain numbers only.

Login Password Too Short
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      12
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()
    Validate Error    Your password must be exactly 4 digits long.

Login Password Too Long
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      12345678
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()
    Validate Error   Your password must be exactly 4 digits long.

Login Password NonNumeric
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      AV12
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()         
    Validate Error    Your password should contain numbers only.

Login User Not Found
    Reload Page
    Sleep             200ms
    Input Text    id=accountId    ${INVALID_ACC}
    Input Text    id=password    1234   
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()
    Validate Error    User not found. Please check your account ID.

Login Invalid Password
    Reload Page
    Sleep             200ms
    Input Text    id=accountId    ${VALID_ACC}
    Input Text    id=password    0000
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()
    Validate Error    Incorrect password. Please try again.