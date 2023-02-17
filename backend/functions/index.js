const functions = require("firebase-functions");
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');
const app = express();
const fs = require('fs');
var serviceAccount = require("./permissions.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

app.use(cors({origin:true}));

// fs.readdirSync("./routes").map((r) => app.use("/api", require(`./routes/${r}`)));

exports.actions = require('./onCall/actions.onCall');
exports.role = require('./onCall/role.onCall');
exports.setUp = require('./onCall/setUp.onCall');
exports.user = require('./onCall/user.onCall');
exports.circle = require('./onCall/circle.onCall');
exports.activity = require('./onCall/activity.onCall');