const mongoose = require('mongoose');
const { Schema } = mongoose;

const TransactionSchema = Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true
    },
    title: {
        type: String,
        required: true
    },
    description: String,
    amount: {
        type: mongoose.Types.Decimal128,
        required: true
    },
    type: {
        type: String,
        enum: ['INCOME', 'EXPENSE'],
        required: true
    },
    category: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'TransactionCategory',
        required: true
    },
    date:{
        type: Date,
        default: Date.now
    }
}, {timestamps: true});

module.exports = mongoose.model('Transaction', TransactionSchema);