const admin = require("firebase-admin");
const db = admin.firestore();

const Roles = db.collection("Roles");
const Users = db.collection("Users");
const Actions = db.collection("Actions");
const Circle = db.collection("Circle");
const Chat = db.collection('Chat');
const Activity = db.collection('Activity');

module.exports = {
    Roles,
    Users,
    Actions,
    Circle,
    Chat,
    Activity,
}