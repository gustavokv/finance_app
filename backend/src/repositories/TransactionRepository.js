const Transaction = require('../models/Transaction');

class TransactionRepository{
    async create(transaction){
        return await Transaction.create(transaction);
    }
 
    async filter(userId){
        return await Transaction.find({
            userId: userId
        }).sort({date: -1}).limit(10).exec();
    }

    async filterByDate(userId, dateRange){
        return await Transaction.find({
            userId: userId,
            date: {
                $gte: dateRange.first,
                $lte: dateRange.last
            }
        }).sort({date: -1}).exec();
    }
}

module.exports = new TransactionRepository();