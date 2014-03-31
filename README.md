BRDatabase
==========

This is a simple sqlite3/FMDB database framework that will version your database for upgrades.

### Implementation Notes
There are several specific things that must be done to properly upgrade a database using this framework.

1) There should be a folder titled "Scripts" in the project that will be deployed when the app is bundled/installed.  
2) Your database should be defined in a script titled "DatabaseInstall.sql"  
  2.1) There should be a table called "Version" that has a databaseVersion INT column.  
    Example Script: CREATE TABLE Version (versionId INTEGER PRIMARY KEY ASC, databaseVersion INT, description TEXT);  
3) When initializing your database you should pass in several parameters.
  - DatabaseName - (NSString) The name of your database. If you change the name the previous version will not be upgraded but your database will be created from scratch and upgraded to the latest version.
  - DatabaseVersion - (NSNumber) The current version or the version you are upgrading to, whichever is the latest.
An array of NSNumber/s is required when initializing your database. These numbers represent all deployed versions
  - DatabaseVersionHistory - (NSArray of type NSDouble) All of the versions in which you have a script. If the database does not exist than the framework will execute DataInstall.sql and then foreach version here look for a matching upgrade script (see step 4 below).
4) The actual upgrade scripts should be included in the project.  
  4.1) Each version of the database should include a database script with the file name format "<major version>_<minor version><revision>_upgrade.sql".  
    Example Script: To upgrade the database to version 1.2.3 the script would be "1_23_upgrade.sql".  
  4.2) The minor version and revision only support single digits, 0 - 9.  
  4.3) The script files should be set to be copied into bundled resources.  

### Usage Example - Initial Install

```Objective-C
    NSArray *versions = @[ [NSNumber numberWithDouble:1.0] ];

    BRDatabase *database = [BRDatabase sharedBRDatabase];
    [database initializeWithDatabaseName:@"Example.sqlite" withDatabaseVersion:1.0 withVersionHistory:versions];
```

### Usage Example - Upgrade

```Objective-C
    /* Two versions of the database will exist.
       1.0 - Installed using file “DatabaseInstall.sql”
       1.1 - Upgraded to by executing the file 1_10_upgrade.sql
    */
    NSArray *versions = @[ 
			[NSNumber numberWithDouble:1.0], 
			[NSNumber numberWithDouble:1.1]
			];

    BRDatabase *database = [BRDatabase sharedBRDatabase];
    [database initializeWithDatabaseName:@"Example.sqlite" withDatabaseVersion:1.1 withVersionHistory:versions];
```

