const express = require('express');
const router = express.Router();
const controllers = require('../controllers/users.controller.js');
const middleware = require('../middleware/verifyToken.middleware.js');

router.post('/createUser',controllers.create_user);

module.exports = router;