const mongoose = require('mongoose');

require('dotenv').config();

const connectDB = async () => {
    try{
        await mongoose.connect(process.env.MONGO_URI);
        
        console.log('Mongo connected successfully.');
    } catch(error){
        console.error(`Error on connect to Mongo: ${error}`);
        process.exit(1);
    }
}

module.exports = connectDB;