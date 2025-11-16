*** Settings ***
Resource    ../../resources/imports.robot
Resource    ../../keywords/common/cubankCommonKeywords.robot
Resource    ../../keywords/common/mongoDatabaseKeywords.robot

Variables    ../../resources/testdata/scenario/s8.yml

Suite Setup       Run Keywords  Delete Account By Id    ${ACCOUNT_ID}
                  ...   AND   Create New User    ${NAME}    ${ACCOUNT_ID}    ${PASSWORD}
                  ...    AND    Create New User    ${NAME}    ${TARGET_VALID}    ${PASSWORD}      
                  ...   AND   Open Browser First
                  ...    AND    Login with account number and password  accountNumber=${ACCOUNT_ID}  password=${PASSWORD} 
Suite Teardown    Run Keywords  Close Browser
                  ...   AND    Delete Account By Id    ${ACCOUNT_ID}
                  ...    AND    Delete Account By Id    ${TARGET_VALID}    

*** Variables ***
${ACCOUNT_ID}       1234567890
${NAME}           Litle Chacoal
${PASSWORD}       1111

${BALANCE_BASE}       1000
${WITHDRAW_AMOUNT}    200
${TRANSFER_AMOUNT}    200

${TARGET_VALID}    5555555555         

${MSG_INSUFFICIENT}   Your balance is not enough to complete the withdrawal.

*** Keywords ***
Go To Transfer
    Go To    http://localhost:3000/account
    Wait Until Page Contains Element    xpath=//h2[text()="Transfer"]
    Scroll Element Into View            xpath=//h2[text()="Transfer"]

Submit Transfer
    [Arguments]    ${acc}    ${amount}
    Input Text     xpath=//h2[text()="Transfer"]/following::input[@cid="t1"][1]    ${acc}
    Input Text     xpath=//h2[text()="Transfer"]/following::input[@cid="t2"][1]    ${amount}
    Execute JavaScript    document.querySelector('button[cid="tc"]').click()
    Sleep    1s

Submit Withdraw
    [Arguments]    ${amount}
    Go To Withdraw
    Wait Until Page Contains Element    xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]    10s
    Clear Element Text                  xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]
    Input Text                          xpath=//h2[normalize-space()="Withdraw"]/following::input[@cid="w1"][1]    ${amount}
    Click Button                        css:[cid="wc"]
    Sleep    200ms

Validate Error
    [Arguments]    ${msg}
    Wait Until Element Is Visible    css:[cid="transfer-error-mes"]    timeout=5s
    ${txt}=    Get Text    css:[cid="transfer-error-mes"]
    Should Be Equal As Strings    ${txt}    ${msg}

*** Test Cases ***
TC30 โอนเงินสำเร็จ - โอนจำนวนเท่ายอดคงเหลือ 
    [Setup]   Run Keywords    Delete Transactions On Account    ${ACCOUNT_ID}
    ...       AND   Update Balance By Amount    ${ACCOUNT_ID}    ${BALANCE_BASE}
    Go To Transfer
    Submit Transfer   ${TARGET_VALID}   ${BALANCE_BASE}
    Verify History transaction should correct   expected_data=${s8.TC_001.expected_history}
 
TC31 โอนเงินไม่สำเร็จ - ยอดเงินคงเหลือมีค่าเท่ากับศูนย์
    Submit Transfer   ${TARGET_VALID}   ${BALANCE_BASE}
    Verify Balance On Title  balance=0
    Validate Error    Your balance is not enough to complete the transfer.