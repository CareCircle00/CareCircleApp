const express = require('express');
const router = express.Router();
const controllers = require('../controllers/role.controller.js');

router.get('/getRoles',controllers.get_roles);

module.exports = router;