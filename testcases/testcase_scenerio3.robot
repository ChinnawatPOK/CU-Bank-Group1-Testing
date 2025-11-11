*** Settings ***
Resource    ../resources/imports.robot
Resource    ../keywords/common/cubankCommonKeywords.robot
Resource    ../keywords/common/mongoDatabaseKeywords.robot

Variables    ../resources/testdata/scenerio3.yml

Suite Setup       Login with account number and password  accountNumber=${ACCOUNT_ID}  password=1234
Suite Teardown    Close Browser

*** Variables ***
${ACCOUNT_ID}       1234567890

*** Test Cases ***
TC01 Deposit Success
    [Setup]   Run Keywords    Delete Transactions On Account  ${ACCOUNT_ID}
    ...       AND   Update Balance To Zero  ${ACCOUNT_ID}
    Reload Page
    Make deposit transaction success   depositAmount=500
    Verify Balance On Title  balance=500
    Verify History transaction should correct   expected_data=${scenerio3.TC_001.expected_history}

TC02 Deposit Failed Amount Is Negative
    [Setup]   Run Keywords    Delete Transactions On Account  ${ACCOUNT_ID}
    ...       AND   Update Balance To Zero  ${ACCOUNT_ID}
    Reload Page
    Make deposit transaction   depositAmount=-1
    Validate Error Message  msg=The amount must be greater than 0. Please enter a positive number.
    Verify History transaction should empty

TC03 Deposit Failed Amount Is Decimal
    [Setup]   Run Keywords    Delete Transactions On Account  ${ACCOUNT_ID}
    ...       AND   Update Balance To Zero  ${ACCOUNT_ID}
    Reload Page
    Make deposit transaction   depositAmount=0.01
    Validate Error Message  msg=The balance amount must be a whole number with no decimals.
    Verify History transaction should empty

TC04 Deposit Failed Amount Is Not Number
    [Setup]   Run Keywords    Delete Transactions On Account  ${ACCOUNT_ID}
    ...       AND   Update Balance To Zero  ${ACCOUNT_ID}
    Reload Page
    Make deposit transaction   depositAmount=e1
    Validate Error Message  msg=Invalid balance amount. Please enter a valid number.
    Verify History transaction should empty
