from pymongo import MongoClient

class MongoKeywords:
    def connect_to_mongo(self, uri, db_name):
        """Connect to MongoDB and return a DB object"""
        client = MongoClient(uri)
        self.db = client[db_name]
        return self.db

    def delete_document_by_account(self, collection_name, account_id):
        """Delete all documents with a given accountId"""
        collection = self.db[collection_name]
        result = collection.delete_many({"accountId": account_id})
        return result.deleted_count

    def delete_transactions_by_account(self, collection_name, account_id):
        collection = self.db[collection_name]
        # Use $set to replace transactions array with an empty list
        result = collection.update_one(
            {"accountId": account_id},
            {"$set": {"transactions": []}}
        )
        return result.modified_count

    def update_account_balance_to_zero(self, collection_name, account_id):
        """Update balance to 0 for a given accountId"""
        collection = self.db[collection_name]
        result = collection.update_one(
            {"accountId": account_id},
            {"$set": {"balance": 0}}
        )
        return result.modified_count

    def update_account_balance_by_amount(self, collection_name, account_id, amount):
        """Update balance to 0 for a given accountId"""
        collection = self.db[collection_name]
        result = collection.update_one(
            {"accountId": account_id},
            {"$set": {"balance": amount}}
        )
        return result.modified_count

    def disconnect_mongo(self):
        """Close the MongoDB connection"""
        self.db.client.close()
