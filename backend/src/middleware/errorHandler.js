const { ZodError } = require('zod');
const { JsonWebTokenError, TokenExpiredError } = require('jsonwebtoken');

const errorHandler = (error, req, res, next) => {
    let statusCode = 500;
    let errorMessage = 'Erro interno do servidor.';

    if (error.code && typeof error.code === 'number') {
        statusCode = error.code;
        errorMessage = error.message;
    }

    if (error instanceof ZodError) {
        statusCode = 400;
        errorMessage = error.issues.map(issue => issue.message).join('. ');
    }

    if (error instanceof JsonWebTokenError) {
        statusCode = 401;
        errorMessage = 'Token inválido ou malformado.';
    }
    
    if (error instanceof TokenExpiredError) {
        statusCode = 401;
        errorMessage = 'Token expirado. Faça login novamente.';
    }

    if (statusCode === 500 && process.env.NODE_ENV === 'production') {
        errorMessage = 'Ocorreu um erro inesperado no servidor. Tente novamente mais tarde.';
        console.error('SERVER ERROR:', error);
    } else {
        console.error(error); 
    }

    res.status(statusCode).json({ message: errorMessage });
}

module.exports = errorHandler;