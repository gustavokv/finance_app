const UserRepository = require('../../repositories/UserRepository');
const TransactionRepository = require('../../repositories/TransactionRepository');

class AddTransactionService {
    async execute(user, transaction){
        const userFound = await UserRepository.findByEmail(user.email);

        if(!userFound){
            const error = new Error('Erro ao encontrar o usuário para criar esta transação.');
            error.code = 404;
            throw error;
        }

        transaction.userId = userFound._id;

        let balanceChange = transaction.amount;
        if(transaction.type === 'EXPENSE'){
            balanceChange = -Math.abs(balanceChange);
        }
        
        try{
            const createdTransaction = await TransactionRepository.create(transaction);
            await UserRepository.updateBalance(userFound._id, balanceChange);

            return createdTransaction;
        }
        catch(err){
            console.log(err);
            const error = new Error('Erro ao processar transação.');
            
            if (err.name === 'ValidationError') {
                error.message = Object.values(err.errors).map(val => val.message).join(', ');
                error.code = 400;
            } else {
                error.code = 500;
            }
            
            throw error;
        }
    }
}   

module.exports = new AddTransactionService();