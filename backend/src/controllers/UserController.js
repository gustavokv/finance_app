const GetUserService = require('../services/user/GetUserService');

class UserController{
    async profile(req, res){
        const userInfo = req.userInfo;

        try{
            const response = await GetUserService.execute(userInfo.email);

            const user = {
                "name": response.name,
                "email": response.email,
                "accountBalance": response.accountBalance,
                "thisMonthIncomes": response.incomes,
                "thisMonthExpenses": response.expenses
            };

            res.status(200).json({'user': user});
        }
        catch(error){
            next(error);
        }
    }
}

module.exports = new UserController();