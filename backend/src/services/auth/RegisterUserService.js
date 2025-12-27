const UserRepository = require('../../repositories/UserRepository');
const bcryptjs = require('bcryptjs');

class RegisterUserService{
    async execute(name, email, password){
        const userFound = await UserRepository.findByEmail(email);

        if(userFound){
            const error = new Error('Usuário já existe.');
            error.code = 409;
            throw error;
        }

        const hashedPassword = bcryptjs.hashSync(password, 10);

        const user = await UserRepository.create({name, email, hashedPassword});

        if(!user){
            throw new Error('Erro ao criar novo usuário.');
        }

        const userResponse = user.toObject();
        delete userResponse.hashedPassword;

        return userResponse;
    }
}

module.exports = new RegisterUserService();