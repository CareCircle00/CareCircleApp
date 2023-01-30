const express = require('express');
const router = express.Router();
const controllers = require('../controllers/setup.controller.js');

router.post('/addRoles',controllers.add_roles);
router.post('/delRoles',controllers.del_roles);
router.post('/addActions',controllers.add_actions);
router.post('/delActions',controllers.del_actions);

module.exports = router;