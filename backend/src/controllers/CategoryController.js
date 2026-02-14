const { z } = require('zod');
const AddCategoryService = require('../services/category/AddCategoryService');
const GetCategoryService = require('../services/category/GetCategoryService');

class CategoryController {
    async newCategory(req, res, next){
        const categorySchema = z.object({
            title: z.string().min(1, "O título é obrigatório"),
            color: z.enum(['green', 'red', 'purple', 'yellow', 'orange', 'blue'], {message: "Cor inválida"}),
            type: z.enum(['EXPENSE', 'INCOME'], {message: 'O tipo da transação é obrigatório'})
        });

        try{
            const category = categorySchema.parse(req.body);
            await AddCategoryService.execute(category);

            res.status(201).json({"message": "Categoria adicionada com sucesso."});
        }
        catch(error){
            next(error);
        }
    }

    async getCategory(req, res) {
        try{
            const response = await GetCategoryService.execute(req.query);
            res.status(200).json(response);
        }
        catch(error){
            next(error);
        }
    }
}

module.exports = new CategoryController();