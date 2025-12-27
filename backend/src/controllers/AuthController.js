const { z, ZodError }= require('zod');
const RegisterUserService = require('../services/auth/RegisterUserService');
const AuthUserService = require('../services/auth/AuthUserService');

class AuthController {
    async register(req, res){
        const registerModel = z.object({
            name: z.string().min(4),
            password: z.string().min(8),
            email: z.email()
        });

        try{
            const { name, email, password } = registerModel.parse(req.body);

            const newUser = await RegisterUserService.execute(name, email, password);
            res.status(201).json(newUser);
        }
        catch(error){
            let errorStatus = error.code;
            let errorMessage = error.message;

            if(error instanceof ZodError){
                errorStatus = 401;
                errorMessage = error.issues[0].message;
            }

            res.status(errorStatus).json({'message': errorMessage});
        }
    }

    async login(req, res){
        const loginModel = z.object({
            email: z.email(),
            password: z.string()
        });

        try{
            const { email, password } = loginModel.parse(req.body);
 
            const user = await AuthUserService.execute(email, password);
            res.status(201).json({'accessToken': user.accessToken});
        }
        catch(error){
            let errorStatus = error.code;
            let errorMessage = error.message;

            if(error instanceof ZodError){
                errorStatus = 401;
                errorMessage = error.issues[0].message;
            }

            res.status(errorStatus).json({'message': errorMessage});
        }
    }   
}

module.exports = new AuthController();