-- Create the Version table to store the database version
CREATE TABLE Version (versionId INTEGER PRIMARY KEY ASC, databaseVersion INT, description TEXT);

-- Create the Person table to store the children
CREATE Table Person (personId INTEGER PRIMARY KEY ASC, firstName TEXT, lastName TEXT, birthDate TEXT);

-- Seed any data
INSERT INTO Version (databaseVersion, description) VALUES (0.0, 'The initial install of the database.');