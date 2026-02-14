const TransactionCategoryRepository = require('../../repositories/TransactionCategoryRepository');

class AddCategoryService {
    async execute(category){
        const response = await TransactionCategoryRepository.find({title: category.title});

        if(response.length > 0){
            const error = new Error('A categoria com este nome já existe');
            error.code = 409;
            throw error;
        }

        try{
            await TransactionCategoryRepository.create(category);
        }
        catch(err){
            console.log(err);
            const error = new Error('Erro ao adicionar categoria.');
            
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

module.exports = new AddCategoryService();