const admin = require('firebase-admin');
const {Users,Roles} = require('../collections.js');
const firebase = require('firebase-functions');

let default_role = "Caregiver";

const create_user = async(req,res) =>{
    try{
        let {uid,role} = req.body;
        await admin.auth().getUser(uid).then((user)=>{
            if(!user){
                return res.status(404).json({message:'UID does not exist'});
            }
        });
        let r = await Roles.doc(role).get();
        console.log(r);
        if(r.createTime==undefined){
            return res.status(405).json({message:"Role does not exist"});
        }
        let u=await Users.get(uid);
        if(u!=undefined){
            return res.status(200).json({message:'User doc exists'});
        }
        await Users.doc(uid).create({
            roleId: role,
        });
        return res.status(200).json({message:'User Created Succesfully!'});
    }catch(err){
        console.log(err.message);
        return res.status(404).json({message: `Error creating user:${err.message}`});
    }
}

module.exports = {
    create_user,
}