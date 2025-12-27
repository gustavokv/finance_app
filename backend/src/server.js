const http = require('http');
const app = require('./app');
const mongoose = require('mongoose');

require('dotenv').config();

const server = http.createServer(app);
const PORT = process.env.PORT || 3500;

mongoose.connection.on('connected', () => {
    server.listen(PORT, () => {
        console.log(`Server running on PORT ${PORT}`);
    });
});