const functions = require('firebase-functions');
const admin = require('firebase-admin');

const {Roles,Users, Circle} = require('../collections.js');
const { firestore } = require('firebase-admin');

exports.newUser = functions.https.onCall(async(data,context)=>{    
    let uid = data.uid;
    let role = data.role;
    await Roles.doc(role).get().then((r)=>{
        if(!r.exists){
            throw new functions.https.HttpsError("invalid-argument","Role is not correct");
        }
    })
    return Users.doc(uid).get().then(async (u)=>{
        if(u.exists){
            return{message:'User doc exists!'}
        }
        else{
            return Users.doc(uid).create({
                roleId: role,
            }).then((u)=>{
                return {message:'User Created Succesfully!'}
            }).catch((err)=>{
                throw new functions.https.HttpsError("internal",`User creation failed: ${err}`)
            })
        }
    });
});

//////////////////////////////////////////////////////////////////

exports.checkUser = functions.https.onCall(async(user,context)=>{
    let uid = context.auth.uid;
    return Users.doc(uid).get().then(async (u)=>{
        if(u.exists){
            return {user: u.data(), message:'User exists!'}
        }else{
            return {message: 'User doesnot exist!'}
        }
    }).catch((err)=>{
        throw new functions.https.HttpsError('internal','User detection failed')
    })
})

exports.createUser = functions.https.onCall(async(data,context)=>{
    let uid = context.auth.uid;
    let ph = data.ph;
    return Users.doc(uid).create({
        ph:ph
    }).then((u)=>{
        return {message:'User Created Succesfully!'}
    }).catch((err)=>{
        throw new functions.https.HttpsError("internal",`User creation failed: ${err}`)
    })
})

exports.checkLovedOne = functions.https.onCall(async(data,context)=>{
    let id = context.auth.uid;
    let {ph} = data
    let c=[];
    return Circle.get().then((doc)=>{
        let rval = [];
        doc.docs.map((m)=>{
            if(m._fieldsProto.lovedOne.mapValue.fields.lovedOnephNo.stringValue.replace(' ','')==ph.replace(' ','')){
                rval.push(m._fieldsProto.lovedOne.mapValue.fields.lovedOnephNo.stringValue);
                c.push(m);
            }
        })
        if(c.length==0){
            return {message:'found this', phs: rval, cid: '', id: ''}
        }else{
            return {message:'found this', phs: rval, cid: c[0], id: c[0].id}
        }
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`);
    });
})

exports.updateUserRole = functions.https.onCall(async(data,context)=>{
    let role = data.role;
    let uid = context.auth.uid;
    return Users.doc(uid).update({
        role: role,
    }).then((doc)=>{
        return {message: 'Role updated'}
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`);
    })
})

exports.updateUserCircle = functions.https.onCall(async(data,context)=>{
    let cid = data.cid;
    let uid = context.auth.uid;
    return Users.doc(uid).update({
        circle:cid
    }).then((doc)=>{
        return {message: 'Circle ID updated'}
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`);    
    })
})
exports.checkUnacceptedMember = functions.https.onCall(async(data,context)=>{
    let uid = context.auth.uid;
    let phno = data.phno;
    let circle = [];
    return Circle.where('members','array-contains',{memberNumber: phno,status:'Pending'}).get().then((doc)=>{
        if(doc.docs.length == 0 ){return {message:'found this',  length: 0};}
        doc.docs.forEach((element)=>{
            circle.push(element);
        })
        // return {message:'found this', circle:circle[0].id,members:circle[0]._fieldsProto.members.arrayValue.values.mapValue, lovedOne:circle[0]._fieldsProto.lovedOne,length: doc.docs.length};
        return {message:'found this', lovedOne : circle[0]._fieldsProto.lovedOne,circle:circle[0].id,members:circle[0]._fieldsProto.members.arrayValue.values, lovedOne:circle[0]._fieldsProto.lovedOne,length: doc.docs.length};
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`);
    });
})
exports.removeUnacceptedMember = functions.https.onCall(async(data,context)=>{
    let uid = context.auth.uid;
    let phno = data.phno;
    let cid = data.cid;
    return Circle.doc(cid).update({
        members: firestore.FieldValue.arrayRemove({
            // memberID: uid,
            memberNumber: phno,
            status: 'Pending'
        })
    }).then((rval)=>{
        return {message: 'Member removed'}
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`);    
    })
})
exports.updateAcceptance = functions.https.onCall(async(data,context)=>{
    let uid = context.auth.uid;
    let phno = data.phno;
    let cid = data.cid;
    return Circle.doc(cid).update({
        members: firestore.FieldValue.arrayUnion({
            memberID: uid,
            memberNumber: phno,
            status: 'Accepted'
        })
    }).then((rval)=>{
        return {message: 'Status Updated'}
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`);    
    })
})

exports.getUserInfo = functions.https.onCall(async(data,context)=>{
    let uid = context.auth.uid;
    return Users.doc(uid).get().then((doc)=>{
        return {message:'User found',circle: doc.data()['circle']}
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`);    
    })
})
///////////////////////////////////////////////////////////////////
// exports.addMemberToCircle = functions.https.onCall(async(data,context)=>{    
//     let uid = context.auth.uid;
//     let ph = data.ph;
//     let circle = [];
//     let m = [];
//     return Circle.where('members','array-contains',{memberID:uid,memberNumber: phno,status:'Accepted'}).get().then((doc)=>{
//         if(doc.docs.length == 0 ){return {message:'found this',  length: 0};}
//         doc.docs.forEach((element)=>{
//             circle.push(element);
//         })
//         circle[0]._fieldsProto.members.arrayValue.values.map((mem)=>{
//             m.push(mem);
//         })
//         return {dekh: m}
//     }).catch((err)=>{
//         throw new functions.https.HttpsError(`internal','Internal server error:${err}`);
//     });

// });
