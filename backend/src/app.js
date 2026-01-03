const cors = require('cors');
const express = require('express');
const connectDB = require('./config/mongodb');
const cookieParser = require('cookie-parser');
const verifyAccess = require('./middleware/verifyAccess');

const app = express();

connectDB();

app.use(express.json());
app.use(cookieParser());
app.use(express.urlencoded({ extended: false }));
app.use(cors());

// Auth Routes
app.use('/auth', require('./routes/auth.routes'));

// Protected by JWT Routes
app.use(verifyAccess);
app.use('/transaction', require('./routes/transactions.routes'));
app.use('/category', require('./routes/category.routes'));

module.exports = app;