-- Apple iTunes Music Store - Relational Schema
-- SQLite DDL - Run this before importing data

-- Reference/dimension tables (no foreign keys)
CREATE TABLE IF NOT EXISTS genre (
    genre_id INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE IF NOT EXISTS media_type (
    media_type_id INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE IF NOT EXISTS artist (
    artist_id INTEGER PRIMARY KEY,
    name TEXT
);

-- Album depends on artist
CREATE TABLE IF NOT EXISTS album (
    album_id INTEGER PRIMARY KEY,
    title TEXT,
    artist_id INTEGER NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);

-- Employee (self-referencing for reports_to)
CREATE TABLE IF NOT EXISTS employee (
    employee_id INTEGER PRIMARY KEY,
    last_name TEXT,
    first_name TEXT,
    title TEXT,
    reports_to INTEGER,
    levels TEXT,
    birthdate TEXT,
    hire_date TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    postal_code TEXT,
    phone TEXT,
    fax TEXT,
    email TEXT,
    FOREIGN KEY (reports_to) REFERENCES employee(employee_id)
);

-- Track depends on album, media_type, genre
CREATE TABLE IF NOT EXISTS track (
    track_id INTEGER PRIMARY KEY,
    name TEXT,
    album_id INTEGER NOT NULL,
    media_type_id INTEGER NOT NULL,
    genre_id INTEGER NOT NULL,
    composer TEXT,
    milliseconds INTEGER,
    bytes INTEGER,
    unit_price REAL,
    FOREIGN KEY (album_id) REFERENCES album(album_id),
    FOREIGN KEY (media_type_id) REFERENCES media_type(media_type_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

-- Customer depends on employee (support_rep_id)
CREATE TABLE IF NOT EXISTS customer (
    customer_id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    company TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    postal_code TEXT,
    phone TEXT,
    fax TEXT,
    email TEXT,
    support_rep_id INTEGER,
    FOREIGN KEY (support_rep_id) REFERENCES employee(employee_id)
);

-- Invoice depends on customer
CREATE TABLE IF NOT EXISTS invoice (
    invoice_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    invoice_date TEXT,
    billing_address TEXT,
    billing_city TEXT,
    billing_state TEXT,
    billing_country TEXT,
    billing_postal_code TEXT,
    total REAL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Invoice line (fact table)
CREATE TABLE IF NOT EXISTS invoice_line (
    invoice_line_id INTEGER PRIMARY KEY,
    invoice_id INTEGER NOT NULL,
    track_id INTEGER NOT NULL,
    unit_price REAL,
    quantity INTEGER,
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
    FOREIGN KEY (track_id) REFERENCES track(track_id)
);

-- Playlist and playlist_track (many-to-many)
CREATE TABLE IF NOT EXISTS playlist (
    playlist_id INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE IF NOT EXISTS playlist_track (
    playlist_id INTEGER NOT NULL,
    track_id INTEGER NOT NULL,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id),
    FOREIGN KEY (track_id) REFERENCES track(track_id)
);

-- Indexes for common joins and filters
CREATE INDEX IF NOT EXISTS idx_track_album ON track(album_id);
CREATE INDEX IF NOT EXISTS idx_track_genre ON track(genre_id);
CREATE INDEX IF NOT EXISTS idx_track_media_type ON track(media_type_id);
CREATE INDEX IF NOT EXISTS idx_invoice_customer ON invoice(customer_id);
CREATE INDEX IF NOT EXISTS idx_invoice_date ON invoice(invoice_date);
CREATE INDEX IF NOT EXISTS idx_invoice_line_invoice ON invoice_line(invoice_id);
CREATE INDEX IF NOT EXISTS idx_invoice_line_track ON invoice_line(track_id);
CREATE INDEX IF NOT EXISTS idx_customer_support ON customer(support_rep_id);
CREATE INDEX IF NOT EXISTS idx_album_artist ON album(artist_id);
