const TransactionCategory = require('../models/TransactionCategory');

class TransactionCategoryRepository {
    async create(category){
        return await TransactionCategory.create(category);
    }

    async find(query){
        return await TransactionCategory.find(query);
    }
}

module.exports = new TransactionCategoryRepository();