const jwt = require('jsonwebtoken');

const verifyAccess = (req, res, next) => {
    const token = req.headers['authorization'];

    if(!token){
        return res.status(401).end();
    }

    jwt.verify(
        token,
        process.env.ACCESS_TOKEN_SECRET,
        (err, userInfo) => {
            if(err){
                return res.status(403).json({'message': err.message});
            }

            req.userInfo = userInfo;
            next();
        }
    );
}

module.exports = verifyAccess;