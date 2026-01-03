const mongoose = require('mongoose');
const { Schema } = mongoose;

const UserSchema = new Schema({
    name: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true
    },
    roles: {
        User: {
            type: Number,
            default: 1000
        },
        Admin: Number
    },
    accountBalance:{
        type: mongoose.Schema.Types.Decimal128,
        required: true
    },
    hashedPassword:{
        type: String,
        required: true
    },
    refreshToken: String
}, {
    timestamps: true
});

module.exports = mongoose.model('User', UserSchema);