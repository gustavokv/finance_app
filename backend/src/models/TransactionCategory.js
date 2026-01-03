const mongoose = require('mongoose');
const { Schema } = mongoose;

const TransactionCategory = new Schema({
    title:{
        type: String,
        required: true
    },
    color:{
        type: String,
        default: 'green'
    }
}, {timestamps: true});

model.exports = mongoose.model('TransactionCategory', TransactionCategory);