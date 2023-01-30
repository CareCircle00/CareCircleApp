const functions = require('firebase-functions');
const {Roles, Circle} = require('../collections.js');

exports.getRoles = functions.https.onCall(async (data, context) => {
    let all_roles = await Roles.get();
    let roles = [];
    all_roles.docs.map((r)=>{
        roles.push({
            id:r.id,
            name: r._fieldsProto.name.stringValue,
        })
    })
    return {roles:roles,message:"Roles returned"}; 
});

exports.checkLovedOneNumber = functions.https.onCall(async(data,context)=>{
    let id = context.auth.uid;
    let {ph} = data
    return Circle.get().then((doc)=>{
        let rval = [];
        doc.docs.map((m)=>{
            if(m._fieldsProto.lovedOne.mapValue.fields.lovedOnephNo.stringValue.replace(' ','')==ph.replace(' ','')){
                rval.push(m._fieldsProto.lovedOne.mapValue.fields.lovedOnephNo.stringValue);
            }
        })
        return {message:'found this', phs: rval}
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`);
    });
})