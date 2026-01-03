const Transaction = require('../models/Transaction');

class TransactionRepository{
    async create(transaction){
        try{
            const response = await Transaction.create(transaction);
            return response;
        }
        catch(error){
            throw error;
        }
    }
}

module.exports = new TransactionRepository();