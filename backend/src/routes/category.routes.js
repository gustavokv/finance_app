const express = require('express');
const router = express.Router();
const CategoryController = require('../controllers/CategoryController');

router.post('/add', CategoryController.newCategory);
router.get('/get', CategoryController.getCategory);

module.exports = router;