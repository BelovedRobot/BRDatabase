BRDatabase
==========

This is a simple sqlite3/FMDB database framework that will version your database for upgrades.

### Implementation Notes
There are several specific things that must be done to properly upgrade a database using this framework.

1) Your database should be defined in a script titled "DatabaseInstall.sql" 
  1.1) There should be a table called "Version" that has a databaseVersion INT column.
    Example Script: CREATE TABLE Version (versionId INTEGER PRIMARY KEY ASC, databaseVersion INT, description TEXT);
  1.2) You should seed your version table with the initial install. You can seed it at 0.0/1.1/199.99 (whatever you want).
2) When initializing your database you should pass the parameters:
  - DatabaseName - (NSString) The name of your database. If you change the name the previous version will not be upgraded but your database will be created from scratch and upgraded to the latest version.
3) The actual upgrade scripts should be included in the project.  
  3.1) Each version of the database should include a database script with the file name format "<major version>_<minor version>_upgrade.sql".  
    Example Script: To upgrade the database to version 1.2 the script would be "1_2_upgrade.sql".  
4) All script files should be set to be copied into bundled resources.

# Issues
- If you get an exception stating you have an unrecognized selector when calling executeBatch it is likely because your missing the linker flag "-all_load" in build settings for the Release configuration.

### Usage Example - Initial Install

```Objective-C
    BRDatabase *database = [BRDatabase sharedBRDatabase];
    [database initializeWithDatabaseName:@"Example.sqlite" withDatabaseVersion:1.0];
```

### Usage Example - Upgrade

```Objective-C
    /* Two versions of the database will exist.
       1.0 - Installed using file “DatabaseInstall.sql”
       1.1 - Upgraded to by executing the file 1_1_upgrade.sql
    */
    BRDatabase *database = [BRDatabase sharedBRDatabase];
    [database initializeWithDatabaseName:@"Example.sqlite" withDatabaseVersion:1.1];
```
