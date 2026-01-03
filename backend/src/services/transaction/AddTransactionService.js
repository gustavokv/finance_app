const UserRepository = require('../../repositories/UserRepository');
const TransactionRepository = require('../../repositories/TransactionRepository');

class AddTransactionService {
    async execute(user, transaction){
        const response = await UserRepository.findByEmail(user.email);

        if(!response){
            const error = new Error('Erro ao encontrar o usuário para criar esta transação.');
            error.code = 500;
            throw error;
        }

        transaction.userId = response._id;
        
        try{
            const createdTransaction = await TransactionRepository.create(transaction);
            return createdTransaction;
        }
        catch(err){
            console.log(err);
            const error = new Error(`Erro ao criar esta transação: ${err.errors.category}`);
            error.code = 500;
            throw error;
        }
    }
}   

module.exports = new AddTransactionService();