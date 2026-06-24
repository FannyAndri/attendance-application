const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.resolve(__dirname, 'attendance.db');

const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error('Error connecting to database:', err.message);
    } else {
        console.log('Connected to the SQLite database.');
        initializeDb();
    }
});

function initializeDb() {
    db.serialize(() => {
        db.run(`CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            department TEXT
        )`);

        db.run(`CREATE TABLE IF NOT EXISTS attendance (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            checkInTime TEXT NOT NULL,
            checkInLat REAL NOT NULL,
            checkInLng REAL NOT NULL,
            checkOutTime TEXT,
            checkOutLat REAL,
            checkOutLng REAL,
            status TEXT NOT NULL,
            isWFH INTEGER NOT NULL DEFAULT 0,
            date TEXT NOT NULL,
            FOREIGN KEY(userId) REFERENCES users(id)
        )`);

        db.run(`CREATE TABLE IF NOT EXISTS location_tracks (
            id TEXT PRIMARY KEY,
            attendanceId TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            accuracy REAL NOT NULL,
            FOREIGN KEY(attendanceId) REFERENCES attendance(id)
        )`);

        db.run(`CREATE TABLE IF NOT EXISTS requests (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'Pending',
            FOREIGN KEY(userId) REFERENCES users(id)
        )`);

        db.run(`CREATE TABLE IF NOT EXISTS settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
        )`);

        // Insert default office location if not exists
        db.get(`SELECT key FROM settings WHERE key = 'office_lat'`, (err, row) => {
            if (!row) {
                db.run(`INSERT INTO settings (key, value) VALUES ('office_lat', '-6.200000')`);
                db.run(`INSERT INTO settings (key, value) VALUES ('office_lng', '106.816666')`);
            }
        });
    });
}

module.exports = db;
