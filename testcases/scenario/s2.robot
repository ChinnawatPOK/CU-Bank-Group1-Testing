*** Settings ***
Resource    ../../resources/imports.robot
Resource    ../../keywords/common/mongoDatabaseKeywords.robot
Resource    ../../keywords/common/cubankCommonKeywords.robot
Resource    ../../keywords/common/mongoDatabaseKeywords.robot

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
TC13 เข้าสู่ระบบไม่ผ่าน - กรอกหมายเลขบัญชียาวเกินไป (Account Number > 10 digits)
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     1234567890123456
    Input Text    id=password      ${VALID_PASS}
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()
    Validate Error    Your account ID must be exactly 10 digits long.

TC14 เข้าสู่ระบบไม่ผ่าน - กรอกหมายเลขบัญชีสั้นเกินไป (Account Number < 10 digits)
    Input Text    id=accountId     12345
    Input Text    id=password      ${VALID_PASS}
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()
    Validate Error    Your account ID must be exactly 10 digits long.

TC15 เข้าสู่ระบบไม่ผ่าน - กรอกหมายเลขบัญชีมีตัวอักษร
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ABCDEFGHIJ
    Input Text    id=password      ${VALID_PASS}
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()        
    Validate Error    Your account ID should contain numbers only.

TC16 เข้าสู่ระบบไม่ผ่าน - รหัสผ่านสั้นเกินไป 
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      12
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()
    Validate Error    Your password must be exactly 4 digits long.

TC17 เข้าสู่ระบบไม่ผ่าน - กรอกเลขบัญชีไม่ตรงกับผู้ใช้ในระบบ 
    Reload Page
    Sleep             200ms
    Input Text    id=accountId    ${INVALID_ACC}
    Input Text    id=password    1234   
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()
    Validate Error    User not found. Please check your account ID.

TC18 เข้าสู่ระบบไม่ผ่าน - รหัสผ่านยาวเกินไป 
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      12345678
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()
    Validate Error   Your password must be exactly 4 digits long.

TC19 เข้าสู่ระบบไม่ผ่าน - รหัสผ่านไม่ใช่ตัวเลข 
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      AV12
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()         
    Validate Error    Your password should contain numbers only.


TC20 เข้าสู่ระบบไม่ผ่าน - รหัสผ่านไม่ตรงกับที่สมัคร  
    Reload Page
    Sleep             200ms
    Input Text    id=accountId    ${VALID_ACC}
    Input Text    id=password    0000
    Execute JavaScript    document.querySelector('button[cid="lc"]').click()
    Validate Error    Incorrect password. Please try again.