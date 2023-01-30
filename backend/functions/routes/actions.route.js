const express = require('express');
const router = express.Router();
const controllers = require('../controllers/actions.controller.js');
const middleware = require('../middleware/verifyToken.middleware.js');

router.get('/getActions', middleware.decodeToken,controllers.getAction);

module.exports = router;