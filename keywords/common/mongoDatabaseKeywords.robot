*** Settings ***
Resource    ../../resources/imports.robot

*** Variables ***
${MONGO_URI}        mongodb+srv://chinnawat_kaewchim_db_user:0VFL8UIiiD8yHYPN@cubankcluster.jcnfl4o.mongodb.net/?appName=CUBankCluster
${DB_NAME}          test
${COLLECTION_NAME}  users

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