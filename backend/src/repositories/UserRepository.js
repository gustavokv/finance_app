const User = require('../models/User');

class UserRepository {
    async create(data){
        const user = User.create(data);
        return user;
    }

    async findByEmail(email){
        return await User.findOne({ email });
    }

    async findById(id){
        return await User.findById(id);
    }

    async update(query, update){
        return await User.findOneAndUpdate(query, update);
    }
}

module.exports = new UserRepository();