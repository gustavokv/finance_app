const AddTransactionService = require("../services/transaction/AddTransactionService");

class TransactionController{
    async newTransaction(req, res){
        const transaction = req.body;
        const user = req.userInfo;

        try{
            await AddTransactionService.execute(user, transaction);
            res.status(204).json({"message": "Transação adicionada com sucesso."});
        }
        catch(error){
            let errorStatus = error.code;
            let errorMessage = error.message;
            
            res.status(errorStatus).json({'message': errorMessage});
        }
    }
}

module.exports = new TransactionController();