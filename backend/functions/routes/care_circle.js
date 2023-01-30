const express = require('express');
const router = express.Router();
const controllers = require('../controllers/care_circle.js');

router.post('/createCircle',controllers.create_circle);

module.exports = router;