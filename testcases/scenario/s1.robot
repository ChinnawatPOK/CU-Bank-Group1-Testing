*** Settings ***
Resource    ../../resources/imports.robot
Resource    ../../keywords/common/mongoDatabaseKeywords.robot
Resource    ../../keywords/common/cubankCommonKeywords.robot
Resource    ../../keywords/common/mongoDatabaseKeywords.robot

Suite Setup       Run Keywords  Delete Account By Id    ${VALID_ACC}
                  ...   AND   Create New User    ${NAME}    ${VALID_ACC}    ${PASSWORD}   
                  ...       AND   Open Browser    http://localhost:3000/register    chrome

Suite Teardown    Run Keywords  Close Browser
                  ...   AND    Delete Account By Id    ${VALID_ACC}

*** Variables ***
${VALID_ACC}         3434343434
${DUPLICATE_ACC}    1212121212
${VALID_PASS}        1234
${VALID_FIRST}       Nong
${VALID_LAST}        Chacoal
${NAME}           Nong Chacoal
${PASSWORD}       1111

*** Keywords ***
Validate Error
    [Arguments]    ${msg}
    Wait Until Element Is Visible    css:[cid="register-error-mes"]    timeout=5s
    ${txt}=    Get Text    css:[cid="register-error-mes"]
    Should Be Equal As Strings    ${txt}    ${msg}

*** Test Cases ***

TC02 ลงทะเบียนไม่ผ่าน - กรอกหมายเลขบัญชีสั้นเกินไป (Account Number < 10 digits) 
    Input Text    id=accountId     12345
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Execute JavaScript    document.querySelector('button[cid="rc"]').click()
    Wait Until Page Contains    Your account ID must be exactly 10 digits long.

TC03 ลงทะเบียนไม่ผ่าน - กรอกหมายเลขบัญชีมีตัวอักษร
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ABCDEFGHIJ
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Execute JavaScript    document.querySelector('button[cid="rc"]').click()    
    Validate Error    Your account ID should contain numbers only.

TC04 ลงทะเบียนไม่ผ่าน - กรอกหมายเลขบัญชีมีที่มีอยู่ในระบบ
    Open Browser    http://localhost:3000/register    chrome
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Execute JavaScript    document.querySelector('button[cid="rc"]').click()
    Validate Error    This account ID is already in use. Please choose another.  

TC05 ลงทะเบียนไม่ผ่าน - รหัสผ่านสั้นเกินไป
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      12
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Execute JavaScript    document.querySelector('button[cid="rc"]').click()
    Validate Error    Your password must be exactly 4 digits long.

TC06 ลงทะเบียนไม่ผ่าน - ไม่กรอกชื่อจริง 
    Reload Page    
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     
    Input Text    id=lastName      ${VALID_LAST}
    Execute JavaScript    document.querySelector('button[cid="rc"]').click()
    Validate Error    Please fill your first name

TC07 ลงทะเบียนไม่ผ่าน - ไม่กรอกนามสกุล 
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      
    Execute JavaScript    document.querySelector('button[cid="rc"]').click()
    Validate Error    Please fill your last name

TC08 ลงทะเบียนไม่ผ่าน - ชื่อและนามสกุลรวมกันยาวเกิน 30 ตัวอักษร 
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     Supercalifragilisticexpialidocious
    Input Text    id=lastName      TestTest
    Execute JavaScript    document.querySelector('button[cid="rc"]').click()
    Validate Error    The combined length of your first and last name must not exceed 30 characters.

TC09 ลงทะเบียนไม่ผ่าน - รหัสผ่านไม่ใช่ตัวเลข
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      AV12
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Execute JavaScript    document.querySelector('button[cid="rc"]').click()         
    Validate Error    Your password should contain numbers only.

TC10 ลงทะเบียนไม่ผ่าน - รหัสผ่านความยาวมากกว่า 4 ตัว 
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     ${VALID_ACC}
    Input Text    id=password      12345678
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Execute JavaScript    document.querySelector('button[cid="rc"]').click()
    Validate Error    Your password must be exactly 4 digits long.


TC11 ลงทะเบียนไม่ผ่าน - กรอกหมายเลขบัญชียาวเกินไป (Account Number > 10 digits) 
    Reload Page
    Sleep             200ms
    Input Text    id=accountId     1234567890123456
    Input Text    id=password      ${VALID_PASS}
    Input Text    id=firstName     ${VALID_FIRST}
    Input Text    id=lastName      ${VALID_LAST}
    Execute JavaScript    document.querySelector('button[cid="rc"]').click()
    Validate Error    Your account ID must be exactly 10 digits long.
