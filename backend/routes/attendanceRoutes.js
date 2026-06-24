const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const db = require('../db');

// Check-in
router.post('/checkin', (req, res) => {
    const { userId, latitude, longitude, isWFH } = req.body;
    
    if (!userId || !latitude || !longitude) {
        return res.status(400).json({ error: 'Missing required location data' });
    }

    const id = crypto.randomUUID();
    const now = new Date();
    const dateStr = now.toISOString().split('T')[0];
    const timeStr = now.toISOString();

    db.run(
        `INSERT INTO attendance (id, userId, checkInTime, checkInLat, checkInLng, status, isWFH, date) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [id, userId, timeStr, latitude, longitude, 'present', isWFH ? 1 : 0, dateStr],
        function (err) {
            if (err) {
                return res.status(500).json({ error: err.message });
            }
            res.status(201).json({ 
                message: 'Check-in successful', 
                record: { id, userId, checkInTime: timeStr, checkInLat: latitude, checkInLng: longitude, status: 'present', isWFH: isWFH ? 1 : 0, date: dateStr }
            });
        }
    );
});

// Check-out
router.post('/checkout', (req, res) => {
    const { userId, latitude, longitude } = req.body;

    if (!userId || !latitude || !longitude) {
        return res.status(400).json({ error: 'Missing required data' });
    }

    // Find the latest open attendance record for today
    const dateStr = new Date().toISOString().split('T')[0];

    db.get(
        `SELECT id FROM attendance WHERE userId = ? AND date = ? AND checkOutTime IS NULL ORDER BY checkInTime DESC LIMIT 1`,
        [userId, dateStr],
        (err, record) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }
            if (!record) {
                return res.status(404).json({ error: 'No active check-in found for today' });
            }

            const timeStr = new Date().toISOString();

            db.run(
                `UPDATE attendance SET checkOutTime = ?, checkOutLat = ?, checkOutLng = ? WHERE id = ?`,
                [timeStr, latitude, longitude, record.id],
                function (err) {
                    if (err) {
                        return res.status(500).json({ error: err.message });
                    }
                    res.json({ message: 'Check-out successful', attendanceId: record.id });
                }
            );
        }
    );
});

// Get attendance records for a user
router.get('/history/:userId', (req, res) => {
    const { userId } = req.params;

    db.all(`SELECT * FROM attendance WHERE userId = ? ORDER BY checkInTime DESC`, [userId], (err, rows) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json(rows);
    });
});

// Add location track point
router.post('/track', (req, res) => {
    const { attendanceId, latitude, longitude, accuracy } = req.body;

    if (!attendanceId || !latitude || !longitude || !accuracy) {
        return res.status(400).json({ error: 'Missing required tracking data' });
    }

    const id = crypto.randomUUID();
    const timeStr = new Date().toISOString();

    db.run(
        `INSERT INTO location_tracks (id, attendanceId, timestamp, latitude, longitude, accuracy) 
         VALUES (?, ?, ?, ?, ?, ?)`,
        [id, attendanceId, timeStr, latitude, longitude, accuracy],
        function (err) {
            if (err) {
                return res.status(500).json({ error: err.message });
            }
            res.status(201).json({ message: 'Location tracked successfully' });
        }
    );
});

// Submit a new request (WFH or Overtime)
router.post('/request', (req, res) => {
    const { userId, type, date } = req.body;
    
    if (!userId || !type || !date) {
        return res.status(400).json({ error: 'Missing required data' });
    }

    const id = crypto.randomUUID();
    
    db.run(
        `INSERT INTO requests (id, userId, type, date, status) VALUES (?, ?, ?, ?, ?)`,
        [id, userId, type, date, 'Pending'],
        function(err) {
            if (err) return res.status(500).json({ error: err.message });
            res.status(201).json({ message: 'Request submitted successfully' });
        }
    );
});

// Get requests for a specific user
router.get('/requests/:userId', (req, res) => {
    const { userId } = req.params;
    db.all(
        `SELECT * FROM requests WHERE userId = ? ORDER BY date DESC`,
        [userId],
        (err, rows) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json(rows);
        }
    );
});

module.exports = router;
