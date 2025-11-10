*** Settings ***
Resource    ../../resources/imports.robot

*** Variables ***
${GLOBALTIMEOUT}     ${15}
${GLOBALWAITTIME}    ${5}
${SPEEDTIME}    ${1}
${BROWSER}       chrome

*** Keywords ***
Login with account number and password
    [Arguments]    ${accountNumber}  ${password}
    Input Text   //*[@id='accountId']  ${accountNumber}
    Input Text   //*[@id='password']  ${password}
    Click Button  //*[@id="root"]/div/div/div/form/button
    
Make deposit transaction success
    [Arguments]    ${depositAmount}
    Wait Until Element Is Visible  xpath=//input[@cid='d1']
    Input Text    xpath=//input[@cid='d1']  ${depositAmount}
    Click Button  xpath=//button[@cid='dc']
    Wait Until Element Is Visible  xpath=//div[@class="history-list"]/div[@class="account-form"]

Make deposit transaction
    [Arguments]    ${depositAmount}
    Wait Until Element Is Visible  xpath=//input[@cid='d1']
    Input Text    xpath=//input[@cid='d1']  ${depositAmount}
    Click Button  xpath=//button[@cid='dc']

Click deposit button
    Wait Until Element Is Visible  xpath=//button[@cid='dc']
    Click Button  xpath=//button[@cid='dc']

Verify Balance On Title
    [Arguments]    ${balance}
    Wait Until Element Is Visible  //*[@id="root"]/div/div/div/div[2]/article/h1[3]
    Wait Until Element Contains       //*[@id="root"]/div/div/div/div[2]/article/h1[3]    ${balance}

Verify tooltip deposit invalid value decimal
    ${tooltip}=    Execute JavaScript    return document.querySelector("input[cid='d1']").validationMessage;
    Log To Console    Tooltip: ${tooltip}
    Should Contain    ${tooltip}   Please enter a valid value. The two nearest valid values are 0 and 1.

Verify tooltip deposit not fill out amount
    ${tooltip}=    Execute JavaScript    return document.querySelector("input[cid='d1']").validationMessage;
    Log To Console    Tooltip: ${tooltip}
    Should Contain    ${tooltip}   Please fill out this field.

Verify History transaction should correct
    [Arguments]    ${expected_data}
    ${index}=  Set Variable   1
    FOR  ${expected_history_txn}  IN  @{expected_data}
         Wait Until Element Is Visible  xpath=//div[@class="history-list"]/div[@class="account-form"]/div[${index}]
         Wait Until Element Is Visible  xpath=//div[@class="history-list"]/div[@class="account-form"]/div[${index}]
         ${actual_type}=       Get Text          xpath=(//div[@class="history-list"]/div[@class="account-form"]/div/div[@class="Card_card__1d4RB"]/div)[${index}]/h2[1]
         ${actual_amount}=     Get Text          xpath=(//div[@class="history-list"]/div[@class="account-form"]/div/div[@class="Card_card__1d4RB"]/div)[${index}]/p[3]
         ${actual_balance}=    Get Text          xpath=(//div[@class="history-list"]/div[@class="account-form"]/div/div[@class="Card_card__1d4RB"]/div)[${index}]/p[4]
         Should Contain    ${actual_type}    ${expected_history_txn.type}
         Should Contain    ${actual_amount}   amount: ${expected_history_txn.amount}
         Should Contain    ${actual_balance}   balance: ${expected_history_txn.balance}
         ${index}=  Evaluate  ${index} + 1
    END

Verify History transaction should empty
    Wait Until Element Is Not Visible  xpath=//div[@class="history-list"]/div[@class="account-form"]

Validate Error Message
    [Arguments]    ${msg}
    Wait Until Element Is Visible    css:[cid="deposite-error-mes"]    timeout=5s
    ${txt}=    Get Text    css:[cid="deposite-error-mes"]
    Should Be Equal As Strings    ${txt}    ${msg}
    Capture Page Screenshot
