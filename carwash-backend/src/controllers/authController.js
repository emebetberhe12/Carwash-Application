const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

// Register a new user
const register = async (req, res) => {
    try {
        const { name, email, password } = req.body;

        // 1. Check if user already exists
        const [users] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
        if (users.length > 0) {
            return res.status(400).json({ success: false, message: 'Email already registered' });
        }

        // 2. Hash the password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // 3. Save to database
        const [result] = await db.query(
            'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
            [name, email, hashedPassword]
        );

        // 4. Create a JWT token
        const token = jwt.sign({ userId: result.insertId }, 'your_super_secret_jwt_key', { expiresIn: '7d' });

        res.status(201).json({
            success: true,
            message: 'Registration successful',
            data: { token, user: { id: result.insertId, name, email } }
        });
    } catch (error) {
        console.error('Register Error:', error); // <--- ADD THIS LINE
        res.status(500).json({ success: false, message: 'Server error' });
    
    }
};

// Login user
const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // 1. Find user
        const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(401).json({ success: false, message: 'Invalid email or password' });
        }

        const user = users[0];

        // 2. Check password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ success: false, message: 'Invalid email or password' });
        }

        // 3. Create a JWT token
        const token = jwt.sign({ userId: user.id }, 'your_super_secret_jwt_key', { expiresIn: '7d' });

        res.json({
            success: true,
            message: 'Login successful',
            data: { token, user: { id: user.id, name: user.name, email: user.email } }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

module.exports = { register, login };