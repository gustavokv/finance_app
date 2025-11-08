const http = require('http');
const app = require('./src/app');

/*
* Normalizes the port into a number, string or false.
*/
function normalizePort(val) {
  const port = parseInt(val, 10);

  if (isNaN(port)) {
    // named pipe
    return val;
  }

  if (port >= 0) {
    // port number
    return port;
  }

  return false;
}

const PORT = normalizePort(process.env.PORT || '8181');
app.set('port', PORT);

const onError = (error) => {
    if (error.syscall != 'listen'){
        throw error;
    }

    const bind = typeof port === 'string' ? 'Pipe ' + port : 'Port ' + port;

    // Gently handles the listen errors.
    switch (error.code){
        case 'EACCES':
            console.error(bind + ' needs super user privileges.');
            process.exit(1);
        case 'EADDRINUSE':
            console.error(bind + ' is already in use.');
            process.exit(1);
        default:
            throw error;
    }
}

const server = http.createServer(app);

/*
* Event handler for the listening event of the HTTP server.
*/
const onListening = () => {
    const addr = server.address();
    const bind = typeof addr === 'string' ? 'pipe ' + addr : 'port ' + addr.port;
    console.log('Server running in ' + bind);
}

server.listen(PORT);
server.on('error', onError);
server.on('listening', onListening);