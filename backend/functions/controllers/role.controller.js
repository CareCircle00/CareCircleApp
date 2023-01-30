const admin = require('firebase-admin');
const {Roles} = require('../collections.js');

const get_roles = async(req,res) =>{
    try{
        let all_roles = await Roles.get();
        let roles = [];
        all_roles.docs.map((r)=>{
            roles.push({
                id:r.id,
                name: r._fieldsProto.name.stringValue,
            })
        })
        return res.status(200).json({roles:roles,message:"Roles returned"})
    }catch(err){
        console.log(err.message);
        return res.status(404).json({message: `Error getting roles:${err.message}`});
    }
}

module.exports = {
    get_roles,
}