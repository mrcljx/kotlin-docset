CREATE TABLE IF NOT EXISTS searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);
CREATE UNIQUE INDEX IF NOT EXISTS anchor ON searchIndex (name, type, path);
