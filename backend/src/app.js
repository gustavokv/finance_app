const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const routes = require('./api');

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({extended: true}));

app.get('/', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'API is working!',
    version: '1.0.0'
  });
});

// Connects the main router from the API to the prefix /api
// All routes will be accessible by that prefix (/api)
app.use('/api', routes);

app.use((req, res, next) => {
  const error = new Error('Route not found');
  error.status = 404;
  next(error); // Gives the error to the next error middleware
});

app.use((error, req, res, next) => {
  res.status(error.status || 500); // Defines the status from the error or pattern 500
  res.json({
    error: {
      message: error.message || 'Internal server error.',
    },
  });
});

// Exports the app instance so it can be used in the server.js file
module.exports = app;