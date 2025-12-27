const cors = require('cors');
const express = require('express');
const connectDB = require('./config/mongodb');

const app = express();

connectDB();

app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cors());

// Routes
app.use('/auth', require('./routes/auth.routes'));

module.exports = app;