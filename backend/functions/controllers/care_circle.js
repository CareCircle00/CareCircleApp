const admin = require('firebase-admin');
const {Users,Circle} = require('../collections.js');

const create_circle = (req,res) =>{
    try{
        let {phoneNumber} = req.body;
        return res.status(200).json({message:"Circle Created"});
    }catch(err){
        console.log(err.message);
        return res.status(404).json({message: "Internal Server Error"});
    }
}

module.exports = {
    create_circle,
}