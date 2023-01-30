const admin = require('firebase-admin');
const {Actions} = require('../collections.js');

const getAction = async(req,res)=>{
    try{
        let get_actions = await Actions.get();
        let all_actions_true = [];
        let all_actions_false = [];
        let all_actions = [];
        let num_true = 0;
        get_actions.docs.map((doc)=>{
            if(doc._fieldsProto.default_select.booleanValue==true){
                all_actions_true.push({
                    id: doc.id,
                    name: doc._fieldsProto.name.stringValue,
                    logo: doc._fieldsProto.logo.stringValue,
                    select: doc._fieldsProto.default_select.booleanValue,
                });
                ++num_true;
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
        all_actions = all_actions_true.concat(all_actions_false);
        return res.status(200).json({message:'Actions Returned',uid:req.uid,all_actions_true:all_actions_true,all_actions_false:all_actions_false});
    }catch(err){
        console.log(err.message);
        return res.status(500).json({message:'Internal Server Error'});
    }
}

module.exports = {
    getAction,
}