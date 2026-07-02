const db = require('../config/database');

// 1. Create a guest booking
const createGuestBooking = async (req, res) => {
    try {
        const { customer_name, customer_phone, customer_lat, customer_lng, car_wash_id, date, time, vehicle_type } = req.body;

        if (!customer_name || !customer_phone) {
            return res.status(400).json({ success: false, message: 'Name and Phone are required' });
        }

        const [result] = await db.query(
            'INSERT INTO bookings (customer_name, customer_phone, customer_lat, customer_lng, car_wash_id, date, time, vehicle_type, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [customer_name, customer_phone, customer_lat, customer_lng, car_wash_id, date, time, vehicle_type || 'Sedan', 'pending']
        );

        res.status(201).json({
            success: true,
            message: 'Appointment request sent to Admin!'
        });
    } catch (error) {
        console.error('Booking Error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// 2. Get bookings (filter by status)
const getBookings = async (req, res) => {
    try {
        const { status } = req.query;
        let query = 'SELECT * FROM bookings';
        let params = [];

        if (status) {
            query += ' WHERE status = ?';
            params.push(status);
        }
        
        query += ' ORDER BY created_at DESC'; // ORDER BY goes LAST

        const [bookings] = await db.query(query, params);
        res.json({ success: true, data: bookings });
    } catch (error) {
        console.error('Get Bookings Error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// 3. Update a booking (Mark as washed, add notes)
// Update a booking (Edit details, Assign to worker, Mark as washed)
const updateBooking = async (req, res) => {
    try {
        const { status, notes, customer_name, vehicle_type, date, time, assigned_to } = req.body;
        const bookingId = req.params.id;

        await db.query(
            'UPDATE bookings SET status = ?, notes = ?, customer_name = ?, vehicle_type = ?, date = ?, time = ?, assigned_to = ? WHERE id = ?',
            [status, notes, customer_name, vehicle_type, date, time, assigned_to, bookingId]
        );

        res.json({ success: true, message: 'Booking updated and assigned!' });
    } catch (error) {
        console.error('Update Booking Error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// EXPORT ALL THREE FUNCTIONS HERE AT THE BOTTOM
module.exports = { createGuestBooking, getBookings, updateBooking };