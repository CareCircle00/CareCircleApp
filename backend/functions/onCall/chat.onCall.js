const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {Chat} = require('../collections.js');

exports.newChat = functions.https.onCall(async(data,context)=>{
    let {lovedOne,createdBy,phNo} = data;
    return Circle.doc().create({
        createdBy:createdBy,
        lovedOne:{lovedOne:lovedOne,invitationStatus:'Pending'},
        members: [{memberID:createdBy,memberNumber: phNo,status:'Accepted'}],
        setUpComplete: false,
    }).then((c)=>{
        return {message:'Message Sent'};
    }).catch((err)=>{
        throw new functions.https.HttpsError('internal',`Internal Server Error:${err}`);
    })
});