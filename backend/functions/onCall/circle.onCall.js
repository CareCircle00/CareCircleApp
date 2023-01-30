const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {Circle,Users} = require('../collections.js');
const { firebaseConfig } = require('firebase-functions');

exports.createCircle = functions.https.onCall(async(data,context)=>{
    let {lovedOne,createdBy,phNo} = data;
    return Circle.doc().create({
        createdBy:createdBy,
        lovedOne:{lovedOneuid:'',lovedOnephNo:lovedOne,invitationStatus:'Pending'},
        members: [{memberID:createdBy,memberNumber: phNo,status:'Accepted'}],
        setUpComplete: false,
    }).then((c)=>{
        return {message:'Circle Created', id:c};
    }).catch((err)=>{
        throw new functions.https.HttpsError('internal',`Internal Server Error:${err}`);
    })
});

exports.getCircleUID = functions.https.onCall(async(data,context)=>{
    let uid = context.auth.token.uid;
    let {phno} = data;
    let circle = [];
    let num = 0;
    return Circle.where('members','array-contains',{memberID:uid,memberNumber: phno,status:'Accepted'}).get().then((doc)=>{
        if(doc.docs.length == 0 ){return {message:'found this',  length: 0};}
        doc.docs.forEach((element)=>{
            circle.push(element);
        })
        return {message:'found this', cid:circle[0].id, length: doc.docs.length};
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`);
    });
})

exports.getCircleUnacceptedUID = functions.https.onCall(async(data,context)=>{
    let uid = context.auth.token.uid;
    let {phno} = data;
    let circle = [];
    let num = 0;
    return Circle.where('members','array-contains',{memberID:uid,memberNumber: phno,status:'Pending'}).get().then((doc)=>{
        if(doc.docs.length == 0 ){return {message:'found this',  length: 0};}
        doc.docs.forEach((element)=>{
            circle.push(element);
        })
        return {message:'found this', cid:circle[0].id, length: doc.docs.length};
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`);
    });
})

exports.getCircle = functions.https.onCall(async(data,context)=>{
    let {circleID} = data;
    await Circle.doc(circleID).get().then((doc)=>{
        return {circle: doc};
    }).catch((err)=>{
        throw new functions.https.HttpsError('internal',`Internal Server Error:${err}`);
    });
})

exports.getCircleMembers = functions.https.onCall(async(data,context)=>{
    let uid = context.auth.token.uid;
    let {phno} = data;
    let circle = [];
    let num = 0;
    return Circle.where('members','array-contains',{memberID:uid,memberNumber: phno,status:'Accepted'}).get().then((doc)=>{
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

exports.inviteMembers = functions.https.onCall(async (data,context)=>{
    try{
        let {circleID,members} = data;
        let m =[];
        await members.forEach(mem=>{
            m.push({memberNumber:mem,status:'Pending'})
        })
        await Circle.doc(circleID).update({
            members: admin.firestore.FieldValue.arrayUnion(...m),
            setUpComplete: true
        })
        return {message:'Members added',m}
    }catch(err){
        throw new functions.https.HttpsError('internal',err);
    }
})

exports.checkIfMember = functions.https.onCall(async(data,context)=>{
    let uid = context.auth.uid;
    let circle = [];
    let phno = data.ph;
    return Circle.where('members','array-contains',{memberID:uid,memberNumber: phno,status:'Pending'}).get().then(async (doc)=>{
        if(doc.docs.length == 0 ){return {message:'found this',  length: 0};}
        doc.docs.forEach((element)=>{
            circle.push(element);
        })
        // await circle[0].update({
        //     members: firebase.firestore.FieldValue.arrayRemove({memberID:uid,memberNumber: phno,status:'Pending'})
        // });
        return {message:'found this', cid:circle[0].id, length: doc.docs.length};
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`);
    });
})

// exports.checkSetup = functions.https.onCall(async(data,context)=>{
//     let uid = context.auth.token.uid;
//     let {phno} = data;
//     let circle = [];
//     let num = 0;
//     return Circle.where('members','array-contains',{memberID:uid,memberNumber: phno,status:'Accepted'}).get().then((doc)=>{
//         if(doc.docs.length == 0 ){return {message:'found this',  length: 0};}
//         doc.docs.forEach((element)=>{
//             circle.push(element);
//         })
//         return {message:'found this', circle:circle[0].id,setUpComplete: circle[0]};
//     }).catch((err)=>{
//         throw new functions.https.HttpsError(`internal','Internal server error:${err}`);
//     });
// })
exports.checkSetup = functions.https.onCall(async(data,context)=>{
    let uid = context.auth.token.uid;
    let circle = data.circle;
    return Circle.doc(circle).get().then((doc)=>{
        if(doc.data().setUpComplete == false){
            return {setUpComplete: false}
        }else{
            return {setUpComplete: true}
        }
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`);
    });
})

exports.changeMood = functions.https.onCall(async(data,context)=>{
    try{
        let {mood,circleID} = data;
        let c = await Circle.doc(circleID).update({mood:mood});
        return {message:'Mood Updated'}
    }catch(err){
        throw new functions.https.HttpsError('internal',err)
    }
})

exports.getCurrentMood = functions.https.onCall(async(data,context)=>{
    let cid = data.cid;
    return Circle.doc(cid).get().then((doc)=>{
        return {mood: doc.data().mood}
    }).catch((err)=>{
        throw new functions.https.HttpsError('internal',err)
    })
})

// exports.updateLovedOne = functions.https.onCall(async(data,context)=>{
//     try{
//         let id = context.auth.uid;
//         let {ph} = data;
//         let c = await Circle.where('')
//         return {message:'Actions added',ids:ids}
//     }catch(err){
//         throw new functions.https.HttpsError(`internal ${err}`)
//     }
// })

exports.updateLovedOneStatus = functions.https.onCall(async(data,context)=>{
    let uid = context.auth.token.uid;
    let phno = data.phno;
    let cid = data.cid;
    return Circle.doc(cid).update({
        lovedOne:{
            invitationStatus:'Accepted',
            lovedOnephNo: phno,
            lovedOneuid: uid,
        }
    }).then((c)=>{
        return {message: 'loved one status updated'}
    }).catch((err)=>{
        throw new functions.https.HttpsError('internal',err)
    })
})

exports.getCircleUIDFinal = functions.https.onCall(async(data,context)=>{
    let uid = context.auth.token.uid;
    let {phno} = data;
    let circle = [];
    let num = 0;
    let c = await Circle.where('members','array-contains',{memberID:uid,memberNumber: phno,status:'Accepted'}).get();
    if(c._size == 0){
        let c2 = await Circle.where('members','array-contains',{memberID:uid,memberNumber: phno,status:'Pending'}).get();
        if(c2._size == 0){
            return {message:'new user'}
        }
        else{
            return {c: c2}
        }
    }
    else{
        return {c: c}
    }
})