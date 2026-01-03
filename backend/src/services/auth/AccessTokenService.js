const jwt = require('jsonwebtoken');
const UserRepository = require('../../repositories/UserRepository');

class AccessTokenService {
    async execute(token){
        return new Promise((resolve, reject) => {
            jwt.verify(
                token,
                process.env.REFRESH_TOKEN_SECRET,
                async (err, userInfo) => {
                    if(err){
                        const error = new Error(err.message);
                        error.code = 403;

                        return reject(error);
                    }
                    
                    const userFound = await UserRepository.findByEmail(userInfo.email);

                    if(!userFound){
                        const error = new Error(`O usuário com este email não existe.`);
                        error.code = 404;

                        return reject(error);
                    }

                    const accessToken = jwt.sign(
                        {
                            'email': userFound.email,
                            'roles': userFound.roles
                        },
                        process.env.ACCESS_TOKEN_SECRET,
                        {expiresIn: process.env.ACCESS_TOKEN_EXPIRATION}
                    );
            
                    const refreshToken = jwt.sign(
                        {'email': userFound.email},
                        process.env.REFRESH_TOKEN_SECRET,
                        {expiresIn: process.env.REFRESH_TOKEN_EXPIRATION}
                    );

                    const response = await UserRepository.update({_id: userFound._id}, {'refreshToken': refreshToken});
                    
                    if(!response){
                        const error = new Error('Ocorreu um erro ao atualizar o token deste usuário');
                        error.code = 500;

                        return reject(error);
                    }

                    const { name, email, accountBalance } = userFound;
                    return resolve({ accessToken, refreshToken, 'user': {'username': name, 'email': email, 'account_balance': accountBalance} });
                }
            );
        }
    )};
}

module.exports = new AccessTokenService();