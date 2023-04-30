const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {Circle,Users,Activity} = require('../collections.js');
const { firebaseConfig } = require('firebase-functions');
const db = admin.firestore();

exports.createActivityDoc = functions.https.onCall(async(data,context)=>{
    let cid = data.cid;
    return await Activity.doc(cid).create({ 
    }).then((c)=>{
        return {message:'Activity Doc Created'};
    }).catch((err)=>{
        throw new functions.https.HttpsError('internal',`Internal Server Error:${err}`);
    })
});

exports.addActivity = functions.https.onCall(async(data,context)=>{
    let cid = data.cid;
    let uid = context.auth.uid;
    let activity = data.activity;
    let timestamp = data.timestamp;
    let ph = data.ph;
    let listRef = db.collection('Activity').doc(cid).collection('List');
    return await listRef.add({
        uid: uid,
        activity: activity,
        cid: cid,
        timestamp: timestamp,
        ph:ph
    }).then((c)=>{
        return {message:'Activity added'}
    }).catch((err)=>{
        throw new functions.https.HttpsError(`internal Internal Server Error:${err}`);    
    })
})

exports.delActivity = functions.https.onCall(async(data,context)=>{
    let cid = data.cid;
    return await Activity.doc(cid).delete().then(()=>{
        return {message: 'Activity Deleted'}
    }).catch(err=>{
        throw new functions.https.HttpsError(`internal','Internal server error:${err}`); 
    })
})

// exports.addActivity = functions.https.onCall(async(data,context)=>{
//     let cid = data.cid;
//     let uid = context.auth.uid;
//     let {activityName,activityType,timestamp} = data;
//     return Activity.doc(cid).update({
//         activities: firestore.FieldValue.arrayUnion({
//             user:uid,
//             activity_type: activityType,
//             activityName: activityName,
//             timestamp: timestamp
//         })
//     }).then((c)=>{
//         return {message:'Activity added'};
//     }).catch((err)=>{
//         throw new functions.https.HttpsError('internal',`Internal Server Error:${err}`);
//     })
// })

// exports.getActivity = functions.https.onCall(async(data,context)=>{
//     let cid = data.cid;
//     let {page} = data;
//     return Activity.doc(cid).get((doc)=>{
//         return {message: 'found activity', activities: doc.data().activities}    
//     }).catch((err)=>{
//         throw new functions.https.HttpsError('internal',`Internal Server Error:${err}`);
//     })
// })

// exports.updatedActivity = functions.firestore.document('Activity/{id}').onUpdate((change,context)=>{
//     const newValue = change.after.data();
//     return Activity.doc(context.params.id).get().then((doc)=>{
//         return {message:'Updated', activities: doc.data().activities}
//     }).catch((err)=>{
//         throw new functions.https.HttpsError('internal',`Internal Server Error:${err}`);    
//     })
// })