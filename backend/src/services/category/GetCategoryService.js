const TransactionCategoryRepository = require('../../repositories/TransactionCategoryRepository');

class GetCategoryService{
    async execute(query){   
        try{
            return await TransactionCategoryRepository.find(query);
        }
        catch(err){
            console.log(err);
            const error = new Error('Erro ao buscar categoria.');
            
            error.code = 500;
            
            throw error;
        }
    }
}

module.exports = new GetCategoryService();