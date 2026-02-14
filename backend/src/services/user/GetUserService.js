const UserRepository = require('../../repositories/UserRepository');
const TransactionRepository = require('../../repositories/TransactionRepository');
const { Decimal128 } = require('mongodb');

class GetUserService{
    async execute(email){
        const today = new Date();
        const year = today.getFullYear();
        const month = today.getMonth();

        const start = new Date(year, month, 1);
        const end = new Date(year, month + 1, 1);

        try{
            const user = await UserRepository.findByEmail(email);
            const transactions = await TransactionRepository.filterByDate(user._id, {first: start, last: end});

            const expenses = transactions.filter((transaction) => transaction.type == "EXPENSE");
            const incomes = transactions.filter((transaction) => transaction.type == "INCOME");

            let expensesSum = 0;
            let incomesSum = 0;

            expenses.forEach((expense) => expensesSum += +expense.amount.toString());
            incomes.forEach((income) => incomesSum += +income.amount.toString());

            user.expenses = expensesSum.toString();
            user.incomes = incomesSum.toString();

            return user;
        }
        catch(error){
            throw error;
        }
    }
}

module.exports = new GetUserService();