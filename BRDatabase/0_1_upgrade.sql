ALTER TABLE Person ADD COLUMN address TEXT;
ALTER TABLE Person ADD COLUMN city TEXT;
ALTER TABLE Person ADD COLUMN state TEXT;
ALTER TABLE Person ADD COLUMN zip INT;

INSERT INTO Version (databaseVersion, description) VALUES (0.1, 'The first upgrade.');