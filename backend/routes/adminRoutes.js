const express = require('express');
const router = express.Router();
const db = require('../db');

// Get all users
router.get('/users', (req, res) => {
    db.all(`SELECT id, name, email, department FROM users`, [], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// Get all attendance history (with user info)
router.get('/attendance', (req, res) => {
    const query = `
        SELECT a.*, u.name as userName 
        FROM attendance a
        JOIN users u ON a.userId = u.id
        ORDER BY a.checkInTime DESC
    `;
    db.all(query, [], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// Get all requests
router.get('/requests', (req, res) => {
    const query = `
        SELECT r.*, u.name as userName 
        FROM requests r
        JOIN users u ON r.userId = u.id
        ORDER BY r.date DESC
    `;
    db.all(query, [], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// Update request status
router.put('/requests/:id', (req, res) => {
    const { status } = req.body;
    db.run(
        `UPDATE requests SET status = ? WHERE id = ?`,
        [status, req.params.id],
        function(err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ message: 'Request updated' });
        }
    );
});

// Get office location
router.get('/settings/office', (req, res) => {
    db.all(`SELECT * FROM settings WHERE key IN ('office_lat', 'office_lng')`, [], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        let settings = {};
        rows.forEach(r => settings[r.key] = parseFloat(r.value));
        res.json(settings);
    });
});

// Update office location
router.post('/settings/office', (req, res) => {
    const { lat, lng } = req.body;
    db.serialize(() => {
        db.run(`UPDATE settings SET value = ? WHERE key = 'office_lat'`, [lat.toString()]);
        db.run(`UPDATE settings SET value = ? WHERE key = 'office_lng'`, [lng.toString()]);
    });
    res.json({ message: 'Office location updated' });
});

module.exports = router;
