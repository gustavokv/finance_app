const AddTransactionService = require("../services/transaction/AddTransactionService");
const GetTransactionService = require('../services/transaction/GetTransactionService');
const { z } = require('zod');

class TransactionController{
    async newTransaction(req, res, next){
        const transactionSchema = z.object({
            title: z.string().min(1, "O título é obrigatório"),
            amount: z.coerce.number().positive("O valor deve ser positivo"),
            type: z.enum(['INCOME', 'EXPENSE'], { message: "Tipo inválido" }),
            category: z.string().length(24, "ID da categoria inválido"), 
            date: z.coerce.date().optional(),
            description: z.string().optional()
        });

        try{
            const transaction = transactionSchema.parse(req.body);
            const user = req.userInfo;

            await AddTransactionService.execute(user, transaction);

            res.status(201).json({"message": "Transação adicionada com sucesso."});
        }
        catch(error){
            next(error);
        }
    }

    async getTransaction(req, res, next){
        const user = req.userInfo.email;
        const filter = req.query;

        try{
            const response = await GetTransactionService.execute(user, filter);
            res.status(200).json(response);
        }
        catch(error){
            next(error);
        }
    }
}

module.exports = new TransactionController();