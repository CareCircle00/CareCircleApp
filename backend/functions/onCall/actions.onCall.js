const { firestore } = require('firebase-admin');
const functions = require('firebase-functions');

const {Actions,Circle} = require('../collections.js');

exports.getActions = functions.https.onCall(async (data, context) => {
    let all_actions_true = [];
    let all_actions_false = [];
    return Actions.get().then((get_actions)=>{
        get_actions.docs.map((doc)=>{
            if(doc._fieldsProto.default_select.booleanValue==true){
                all_actions_true.push({
                    id: doc.id,
                    name: doc._fieldsProto.name.stringValue,
                    logo: doc._fieldsProto.logo.stringValue,
                    select: doc._fieldsProto.default_select.booleanValue,
                });
            }
            else{
                all_actions_false.push({
                    id: doc.id,
                    name: doc._fieldsProto.name.stringValue,
                    logo: doc._fieldsProto.logo.stringValue,
                    select: doc._fieldsProto.default_select.booleanValue,
                });
            }
        });
        return {message:'Actions Returned',all_actions_true:all_actions_true,all_actions_false:all_actions_false};
    }).catch((err)=>{
        throw new functions.https.HttpsError('internal',`Could not find actions:${err}`);
    })
    
});
exports.postActions = functions.https.onCall(async (data,context)=>{
    try{
        let {actions,circleID} = data;
        let ids = [];
        await actions.forEach(a => {
            ids.push(a.id);
        });
        let c = await Circle.doc(circleID).update({actions:ids, setUpComplete: true});
        return {message:'Actions added',ids:ids}
    }catch(err){
        throw new functions.https.HttpsError('internal',err)
    }
});

exports.getCircleActions = functions.https.onCall(async(data,context)=>{
    let {cid} = data;
    return Circle.doc(cid).get().then((d)=>{
        // return {actions: d.data()["actions"], message: 'Circle actions found'}
        return Actions.where(firestore.FieldPath.documentId(), 'in', d.data()['actions']).get().then((d1)=>{
            let actions = [];
            if(d1.docs.length == 0 ){return {message:'found this',  length: 0};}
            d1.docs.forEach((element)=>{
                actions.push(element);
            })
            return {message: 'found this', actions: actions};    
        })
    }).catch((err)=>{
        throw new functions.https.HttpsError('internal',err)
    })
})