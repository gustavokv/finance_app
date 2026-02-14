const mongoose = require('mongoose');
const { Schema } = mongoose;

const TransactionCategory = new Schema({
    title:{
        type: String,
        required: true
    },
    color:{
        type: String,
        enum: ['green', 'red', 'purple', 'yellow', 'orange', 'blue'],
        default: 'green'
    },
    type:{
        type: String,
        enum: ['EXPENSE', 'INCOME'],
        required: true
    }
}, {timestamps: true});

module.exports = mongoose.model('TransactionCategory', TransactionCategory);