const admin = require('firebase-admin');

const decodeToken = async(req,res,next) =>{
    try{
        const token = req.headers.token;
        if (!token) {
            return res.status(403).send("A token is required for authentication");
        }
            admin.auth().verifyIdToken(token).then((decoded)=>{
                req.uid = decoded.uid;
                return next();
            })
    }catch(err){
        console.log(err.message);
        return res.status(404).json({message: `Internal server error${err.message}`});
    }
}

module.exports = {
    decodeToken,
}