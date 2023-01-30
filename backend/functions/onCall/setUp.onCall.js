const functions = require('firebase-functions');
const admin = require('firebase-admin');

const {Roles,Actions} = require('../collections.js');
const roles = require('../setup_data/roles.json');
const actions = require('../setup_data/actions.json');

exports.delRoles = functions.https.onCall(async (data,context) => {
    try{
        Roles.listDocuments().then(val => {
            val.map(async (val) => {
                await val.delete()
            })
        });
        return {message:"Roles Deleted"};
    }catch(err){
        console.log(err.message);
        throw new functions.https.HttpsError("internal", "Internal server error");
    }
})

exports.addRoles = functions.https.onCall(async (data,context) => {
    try{
        roles.list.map(async (r,index)=>{
            await Roles.doc()
            .create(r);
        });
        return {message:"Roles Created"};
    }catch(err){
        console.log(err.message);
        throw new functions.https.HttpsError("internal", "Internal server error");
    }
})

exports.addActions = functions.https.onCall(async (data,context) => {
    try{
        actions.list.map(async(a,index)=>{
            await Actions.doc().create(a);
        });
        return {message:"Actions Created"};
    }catch(err){
        console.log(err.message);
        throw new functions.https.HttpsError("internal", "Internal server error");
    }
})

exports.delActions = functions.https.onCall(async (data,context) => {
    try{
        Actions.listDocuments().then(val => {
            val.map(async (val) => {
                await val.delete()
            })
        });
        return {message:"Actions Deleted"};
    }catch(err){
        console.log(err.message);
        throw new functions.https.HttpsError("internal", "Internal server error");
    }
})

