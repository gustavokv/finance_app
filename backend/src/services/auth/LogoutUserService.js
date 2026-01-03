const jwt = require('jsonwebtoken');
const UserRepository = require('../../repositories/UserRepository');

class LogoutUserService{
    async execute(token){
        return new Promise((resolve, reject) => {
            jwt.verify(
                token,
                process.env.REFRESH_TOKEN_SECRET,
                async (err, userInfo) => {
                    if(userInfo){
                        const user = await UserRepository.findByEmail(userInfo.email);
                        await UserRepository.update({_id: user._id}, {refreshToken: ''});

                        resolve();
                    }

                    if(err){
                        const error = new Error(err.message);
                        error.code = 403;
                    
                        return reject(error);
                    }    
                }
            );
        });
    }
}

module.exports = new LogoutUserService();