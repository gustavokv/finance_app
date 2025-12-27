const UserRepository = require('../../repositories/UserRepository');
const bcrypjs = require('bcryptjs');
const jwt = require('jsonwebtoken');

require('dotenv').config();

class AuthUserService{
    async execute(email, password){
        const userFound = await UserRepository.findByEmail(email);

        if(!userFound){
            const error = new Error('Email ou senha incorretos.');
            error.code = 401;
            throw error;
        }

        const passwordMatch = await bcrypjs.compare(password, userFound.hashedPassword);

        console.log(passwordMatch);

        if(!passwordMatch){
            const error = new Error('Email ou senha incorretos.');
            error.code = 401;
            throw error; 
        }

        const accessToken = jwt.sign(
            {'name': userFound.name},
            process.env.ACCESS_TOKEN_SECRET,
            {expiresIn: '15m'}
        );

        const refreshToken = jwt.sign(
            {'name': userFound.name},
            process.env.REFRESH_TOKEN_SECRET,
            {expiresIn: '1d'}
        );

        const result = await UserRepository.update({_id: userFound._id}, {'refreshToken': refreshToken});
        
        if(!result){
            const error = new Error();
            error.code = 500;
            throw error; 
        }

        return {
            user: {
                id: userFound._id,
                name: userFound.name,
                email: userFound.email
            },
            accessToken
        };
    }
}

module.exports = new AuthUserService();