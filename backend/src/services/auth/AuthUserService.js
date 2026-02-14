const UserRepository = require('../../repositories/UserRepository');
const bcrypjs = require('bcryptjs');
const jwt = require('jsonwebtoken');

class AuthUserService{
    async execute(parameterEmail, password){
        const userFound = await UserRepository.findByEmail(parameterEmail);

        if(!userFound){
            const error = new Error('Email ou senha incorretos.');
            error.code = 401;
            throw error;
        }

        const passwordMatch = await bcrypjs.compare(password, userFound.hashedPassword);

        if(!passwordMatch){
            const error = new Error('Email ou senha incorretos.');
            error.code = 401;
            throw error; 
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

        const result = await UserRepository.update({'_id': userFound._id}, {'refreshToken': refreshToken});
        
        if(!result){
            const error = new Error();
            error.code = 500;
            throw error; 
        }

        return { accessToken, refreshToken };
    }
}

module.exports = new AuthUserService();