const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const attendanceRoutes = require('./routes/attendanceRoutes');
const adminRoutes = require('./routes/adminRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/admin', adminRoutes);

// Health check endpoint
app.get('/', (req, res) => {
    res.json({ message: 'Welcome to Employee Attendance API' });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
});
