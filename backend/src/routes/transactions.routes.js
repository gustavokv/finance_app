const express = require('express');
const router = express.Router();
const TransactionController = require('../controllers/TransactionController');

router.post('/add', TransactionController.newTransaction);

module.exports = router;