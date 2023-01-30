const admin = require('firebase-admin');
const roles = require('../setup_data/roles.json');
const actions = require('../setup_data/actions.json');

const {Roles,Actions} = require('../collections.js');

const del_roles = async(req,res)=>{
    try{
        Roles.listDocuments().then(val => {
            val.map(async (val) => {
                await val.delete()
            })
        });
        return res.status(200).json({message:"Roles Deleted"});
    }catch(err){
        console.log(err.message);
        return res.status(500).json({message:'Internal Server Error'});
    }
}

const add_roles = async(req,res)=>{
    try{
            roles.list.map(async (r,index)=>{
                await Roles.doc()
                .create(r);
            });
            return res.status(200).json({message:'Roles Added'});
    }catch(err){
        console.log(err.message);
        return res.status(500).json({message:'Internal Server Error'});
    }
}

const add_actions = async(req,res)=>{
    try{
        actions.list.map(async(a,index)=>{
            await Actions.doc().create(a);
        });
        return res.status(200).json({message:'Actions created'});
    }catch(err){
        console.log(err.message);
        return res.status(500).json({message:"Internal Server Error"});
    }
}

const del_actions = async(req,res)=>{
    try{
        Actions.listDocuments().then(val => {
            val.map(async (val) => {
                await val.delete()
            })
        });
        return res.status(200).json({message:"Actions Deleted"});
    }catch(err){
        console.log(err.message);
        return res.status(500).json({message:'Internal Server Error'});
    }
}


module.exports = {
    add_roles,
    del_roles,
    add_actions,
    del_actions,
}