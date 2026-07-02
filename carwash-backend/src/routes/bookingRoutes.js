const express = require('express');
const router = express.Router();
const { createGuestBooking, getBookings, updateBooking } = require('../controllers/bookingController');

router.post('/', createGuestBooking);
router.get('/', getBookings); // <--- ADD THIS
router.put('/:id', updateBooking); // <--- ADD THIS

module.exports = router;