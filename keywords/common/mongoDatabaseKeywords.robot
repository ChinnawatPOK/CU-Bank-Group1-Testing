*** Settings ***
Resource    ../../resources/imports.robot

*** Variables ***
${MONGO_URI}        mongodb+srv://userxx:passwordxx@cubankcluster.jcnfl4o.mongodb.net/?appName=CUBankCluster
${DB_NAME}          test
${COLLECTION_NAME}  users
${ACCOUNT_ID}       1234567899

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
<<<<<<< HEAD
    Disconnect Mongo
    
Update Balance By Amount
    [Arguments]    ${amount}
    Connect To Mongo    ${MONGO_URI}    ${DB_NAME}
    ${updated}=    update_account_balance_by_amount    ${COLLECTION_NAME}    ${ACCOUNT_ID}  ${amount}
    Log To Console    Balance updated for ${ACCOUNT_ID}, modified: ${updated}
=======
>>>>>>> 1f962b7 (initital scenerio 3)
    Disconnect Mongo