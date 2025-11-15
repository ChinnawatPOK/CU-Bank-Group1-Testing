*** Settings ***
Resource    ../../resources/imports.robot

*** Variables ***
${MONGO_URI}        mongodb://127.0.0.1:27017
${DB_NAME}          cu-bank
${COLLECTION_NAME}  users
${ACCOUNT_ID}       6870194521

*** Keywords ***
Delete Transactions On Account
    [Arguments]    ${accountId}
    Connect To Mongo    ${MONGO_URI}    ${DB_NAME}
    ${deleted}=    delete_transactions_by_account    ${COLLECTION_NAME}    ${accountId}
    Log To Console    Deleted documents count: ${deleted}
    Disconnect Mongo

Update Balance To Zero
    [Arguments]    ${accountId}
    Connect To Mongo    ${MONGO_URI}    ${DB_NAME}
    ${updated}=    update_account_balance_to_zero    ${COLLECTION_NAME}    ${accountId}
    Log To Console    Balance updated for ${ACCOUNT_ID}, modified: ${updated}
    Disconnect Mongo
    
Update Balance By Amount
    [Arguments]    ${accountId}  ${amount}
    Connect To Mongo    ${MONGO_URI}    ${DB_NAME}
    ${updated}=    update_account_balance_by_amount    ${COLLECTION_NAME}    ${accountId}  ${amount}
    Log To Console    Balance updated for ${ACCOUNT_ID}, modified: ${updated}
    Disconnect Mongo

Delete Account By Id
    [Arguments]    ${accountId}
    Connect To Mongo    ${MONGO_URI}    ${DB_NAME}
    delete_document_by_account  ${COLLECTION_NAME}  ${accountId}
    Disconnect Mongo

Create New User
    [Arguments]    ${name}  ${accountId}  ${password}
    Connect To Mongo    ${MONGO_URI}    ${DB_NAME}
    ${res}=  add_new_user  ${COLLECTION_NAME}  ${name}   ${accountId}  ${password}
    Log  ${res}