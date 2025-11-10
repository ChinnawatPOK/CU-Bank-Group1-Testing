*** Settings ***
Resource    ../../resources/imports.robot

*** Variables ***
${MONGO_URI}        mongodb://127.0.0.1:27017/cu-bank
${DB_NAME}          cu-bank
${COLLECTION_NAME}  users
${ACCOUNT_ID}       1234567892

*** Keywords ***
Delete Transactions On Account
    Connect To Mongo    ${MONGO_URI}    ${DB_NAME}
    ${deleted}=    delete_transactions_by_account    ${COLLECTION_NAME}    ${ACCOUNT_ID}
    Log To Console    Deleted documents count: ${deleted}
    Disconnect Mongo

Update Balance To Zero
    Connect To Mongo    ${MONGO_URI}    ${DB_NAME}
    ${updated}=    update_account_balance_to_zero    ${COLLECTION_NAME}    ${ACCOUNT_ID}
    Log To Console    Balance updated for ${ACCOUNT_ID}, modified: ${updated}
    Disconnect Mongo
    
Update Balance By Amount
    [Arguments]    ${amount}
    Connect To Mongo    ${MONGO_URI}    ${DB_NAME}
    ${updated}=    update_account_balance_by_amount    ${COLLECTION_NAME}    ${ACCOUNT_ID}  ${amount}
    Log To Console    Balance updated for ${ACCOUNT_ID}, modified: ${updated}
    Disconnect Mongo