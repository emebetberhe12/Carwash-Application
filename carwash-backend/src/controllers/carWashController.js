const db = require('../config/database');

// Get all active car washes
const getCarWashes = async (req, res) => {
    try {
        const [carWashes] = await db.query('SELECT * FROM car_washes WHERE status = "active"');
        res.json({ success: true, data: carWashes });
    } catch (error) {
        console.error('Error fetching car washes:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

module.exports = { getCarWashes };