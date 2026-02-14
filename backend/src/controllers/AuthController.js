const { z, ZodError } = require('zod');
const RegisterUserService = require('../services/auth/RegisterUserService');
const AuthUserService = require('../services/auth/AuthUserService');
const AccessTokenService = require('../services/auth/AccessTokenService');
const LogoutUserService = require('../services/auth/LogoutUserService');

class AuthController {
    async register(req, res, next){
        const registerModel = z.object({
            name: z.string().min(4),
            password: z.string().min(8),
            email: z.email()
        });

        try{
            const { name, email, password } = registerModel.parse(req.body);

            await RegisterUserService.execute(name, email, password);
            res.status(201).send();
        }
        catch(error){
            next(error);
        }
    }

    async login(req, res, next){
        const loginModel = z.object({
            email: z.email(),
            password: z.string()
        });

        try{
            const { email, password } = loginModel.parse(req.body);

            const response = await AuthUserService.execute(email, password);

            res.cookie('refreshToken', response.refreshToken, {
                httpOnly: true,
                secure: process.env.NODE_ENV === 'production',
                maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days on miliseconds
                sameSite: 'strict'
            });

            res.status(200).json({ 'token': response.accessToken });
        }
        catch(error){
            next(error);
        }
    }  

    async logout(req, res, next) {
        const refreshToken = req.cookies['refreshToken'];

        if(!refreshToken){
            res.status(404).json({'message': 'O token não foi encontrado na requisição.'});
        }

        try{
            await LogoutUserService.execute(refreshToken);

            res.status(204).send();
        }
        catch(error){
           next(error);
        }
    }
    
    async newAccessToken(req, res, next){
        const refreshToken = req.cookies['refreshToken'];

        if(!refreshToken){
            res.status(401).json({'message': 'O token não foi encontrado na requisição.'});
        }

        try{
            const response = await AccessTokenService.execute(refreshToken);

            res.cookie('refreshToken', response.refreshToken, {
                httpOnly: true,
                secure: process.env.NODE_ENV === 'production',
                maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days on miliseconds
                sameSite: 'strict'
            });

            res.status(200).json({ 'token': response.accessToken });
        } 
        catch(error){
            next(error);
        }
    }
}

module.exports = new AuthController();