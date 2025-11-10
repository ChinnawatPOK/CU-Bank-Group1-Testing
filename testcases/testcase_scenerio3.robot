*** Settings ***
Resource    ../resources/imports.robot
Resource    ../keywords/common/cubankCommonKeywords.robot
Resource    ../keywords/common/mongoDatabaseKeywords.robot

Variables    ../resources/testdata/scenerio3.yml

Test Teardown  Close All Browsers

*** Test Cases ***
TC01 Deposit Success
    [Tags]    All Input
    [Setup]   Run Keywords    Delete Transactions On Account
    ...       AND   Update Balance To Zero
    Open Browser    http://localhost:3000  chrome
    Maximize Browser Window
    Login with account number and password  accountNumber=1234567899  password=1234
    Make deposit transaction success   depositAmount=500
    Verify Balance On Title  balance=500
    Verify History transaction should correct   expected_data=${scenerio3.TC_001.expected_history}

TC02 Deposit Failed Amount Is Negative
    [Setup]   Run Keywords    Delete Transactions On Account
    ...       AND   Update Balance To Zero
    Open Browser    http://localhost:3000  chrome
    Maximize Browser Window
    Login with account number and password  accountNumber=1234567899  password=1234
    Make deposit transaction   depositAmount=-1
    Validate Error Message  msg=Invalid balance amount. Please enter a valid number.
    Verify History transaction should empty

TC03 Deposit Failed Amount Is Decimal
    [Setup]   Run Keywords    Delete Transactions On Account
    ...       AND   Update Balance To Zero
    Open Browser    http://localhost:3000  chrome
    Maximize Browser Window
    Login with account number and password  accountNumber=1234567899  password=1234
    Make deposit transaction   depositAmount=0.01
    Validate Error Message  msg=The amount must be greater than 0. Please enter a positive number.
    Verify History transaction should empty

#TC04 Deposit Failed Amount Is Decimal
#    [Setup]   Run Keywords    Delete Transactions On Account
#    ...       AND   Update Balance To Zero
#    Open Browser    http://localhost:3000  chrome
#    Maximize Browser Window
#    Login with account number and password  accountNumber=1234567899  password=1234
#    Click deposit button
##    Verify tooltip deposit not fill out amount
#    Verify History transaction should empty