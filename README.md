BRDatabase
==========

This is a simple sqlite3/FMDB database framework that will version your database for upgrades.

### Implementation Notes
There are several specific things that must be done to properly upgrade a database using this framework.

1) There should be a folder titled "Scripts" in the project that will be deployed when the app is bundled/installed.  
2) Your database should be defined in a script titled "DatabaseInstall.sql"  
  2.1) There should be a table called "Version" that has a databaseVersion INT column.  
    Example Script: CREATE TABLE Version (versionId INTEGER PRIMARY KEY ASC, databaseVersion INT, description TEXT);  
3) The variables in this file should specify which target version the application is expecting.  
  3.1) Set the databaseVersion property to the version the application is expecting.  
  3.2) When upgrading, add the version to the array defined in getDatabaseVersionHistory.  
4) The actual upgrade script should be included in this project.  
  4.1) Each version of the database should include a database script with the file name format "<major version>_<minor version><revision>_upgrade.sql".  
    Example Script: To upgrade the database to version 1.2.3 the script would be "1_23_upgrade.sql".  
  4.2) The minor version and revision only support single digits, 0 - 9.  
  4.3) The script files should be set to be copied into bundled resources.  

### Usage Example

```Objective-C
    NSArray *versions = @[ [NSNumber numberWithDouble:1.0] ];

    BRDatabase *database = [BRDatabase sharedBRDatabase];
    [database initializeWithDatabaseName:@"Example.sqlite" withDatabaseVersion:1.0 withVersionHistory:versions];
```