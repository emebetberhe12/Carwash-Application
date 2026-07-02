const express = require('express');
const cors = require('cors');
require('dotenv').config();
require('./src/config/database'); // Connect to DB

const app = express();

app.use(express.json());
app.use(cors()); // <--- FIXED THE TYPO HERE

// Add API Routes
app.use('/api/auth', require('./src/routes/authRoutes'));
app.use('/api/carwashes', require('./src/routes/carWashRoutes'));
app.use('/api/bookings', require('./src/routes/bookingRoutes'));
// Start the server
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
    console.log(`
    🚀 Server is running!
    📡 Port: http://localhost:${PORT}
    `);
});