const TransactionRepository = require('../../repositories/TransactionRepository');
const UserRepository = require('../../repositories/UserRepository');

class GetTransactionService {
    async execute(userEmail, filter){
        const user = await UserRepository.findByEmail(userEmail);
        const queryFilter = {};

        if(filter.first != null && filter.last != null){
            queryFilter.first = filter.first;
            queryFilter.last = filter.last;
        }

        try{
            let response = {};

            if(queryFilter.first != null){
                response = await TransactionRepository.filterByDate(user._id, queryFilter);
            }
            else{
                response = await TransactionRepository.filter(user._id);
            }

            return response; 
        }
        catch(err){
            const error = new Error('Erro ao filtrar transações.');
            error.code = 500;
            
            throw error;
        }
    }
}

module.exports = new GetTransactionService();