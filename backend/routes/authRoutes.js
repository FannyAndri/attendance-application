const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const db = require('../db');

const JWT_SECRET = 'your_super_secret_key_change_in_production';

// Register
router.post('/register', (req, res) => {
    const { email, password, name, department } = req.body;
    
    if (!email || !password || !name) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const userId = 'user_' + email.split('@')[0];

    db.run(
        `INSERT INTO users (id, name, email, password, department) VALUES (?, ?, ?, ?, ?)`,
        [userId, name, email, password, department],
        function (err) {
            if (err) {
                if (err.message.includes('UNIQUE constraint failed')) {
                    return res.status(400).json({ error: 'Email already exists' });
                }
                return res.status(500).json({ error: err.message });
            }
            res.status(201).json({ message: 'User registered successfully', userId });
        }
    );
});

// Login
router.post('/login', (req, res) => {
    const { email, password } = req.body;

    db.get(`SELECT * FROM users WHERE email = ?`, [email], (err, user) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        if (!user || user.password !== password) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        const token = jwt.sign({ userId: user.id, email: user.email }, JWT_SECRET, { expiresIn: '24h' });

        res.json({
            token,
            userId: user.id,
            email: user.email,
            name: user.name
        });
    });
});

module.exports = router;
