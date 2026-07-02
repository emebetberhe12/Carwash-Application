const express = require('express');
const router = express.Router();
const { getCarWashes } = require('../controllers/carWashController');

router.get('/', getCarWashes);

module.exports = router;