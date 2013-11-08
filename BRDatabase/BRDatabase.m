//
//  BRDatabase.m
//  FMDB_CocoaPods
//
//  Created by Zane Kellogg on 10/17/13.
//  Copyright (c) 2013 Beloved Robot LLC. All rights reserved.
//
// Implementation Notes: There are several specific things that must be done to properly upgrade a database using this framework.
// 1) Your database should be defined in a script titled "DatabaseInstall.sql"
//   1.1) There should be a table called "Version" that has a databaseVersion INT column.
//        Example Script: CREATE TABLE Version (versionId INTEGER PRIMARY KEY ASC, databaseVersion INT, description TEXT);
// 2) The variables in this file should specify which target version the application is expecting.
//   2.1) Set the databaseVersion property to the version the application is expecting.
//   2.2) When upgrading, add the version to the array defined in getDatabaseVersionHistory.
// 3) The actual upgrade script should be included in this project.
//   3.1) Each version of the database should include a database script with the file name format
//        "<major version>_<minor version><revision>_upgrade.sql".
//        Example Script: To upgrade the database to version 1.2.3 the script would be "1_23_upgrade.sql".
//   3.2) The minor version and revision only support single digits, 0 - 9.
//   3.3) The script files should be set to be copied into bundled resources.
//

#import "BRDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase+BRDatabaseExtensions.h"

@implementation BRDatabase

@synthesize database = _database;
@synthesize databaseQueue = _databaseQueue;
@synthesize databasePath = _databasePath;
@synthesize databaseName = _databaseName;
@synthesize databaseVersion = _databaseVersion;

// This method returns a "constant" list of versions. If you version the database add
// the version number in sequence here.
- (NSArray *)getDatabaseVersionHistory {
    return @[
                [NSNumber numberWithDouble:1.0],
                [NSNumber numberWithDouble:1.1]
            ];
}

+ (id)sharedBRDatabase {
    static BRDatabase *sharedBRDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBRDatabase = [[self alloc] init];
    });
    return sharedBRDatabase;
}

- (void)initializeWithDatabaseName:(NSString *)databaseName withDatabaseVersion:(double)databaseVersion {
    // 1 - Set Version
    _databaseVersion = databaseVersion;
    
    // 2 - Get path of database file
    _databasePath = [self getDatabasePathWithDatabaseName:databaseName];
    
    // 3 - See if the database exists then create FMDatabase instance
    _database = [self initializeFMDatabaseInstance];
    
    // 4 - Check version
    double actualDatabaseVersion;
    bool needsToUpgrade = [self databaseDoesNeedUpgradeFromVersion:&actualDatabaseVersion];

    if (!needsToUpgrade)
        return;
    
    // 5 - Detarmine which versions are necessary for upgrade
    NSArray *versionsNeeded = [self getVersionsToUpgradeToFromOldVersion:actualDatabaseVersion];
    
    // 6 - Iterate versions and execute upgrades
    [self executeUpgradesWithVersions:versionsNeeded];
}

// This method builds the database path with name.
- (NSString *)getDatabasePathWithDatabaseName:(NSString *)databaseName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    return [docsPath stringByAppendingPathComponent:databaseName];
}

// This method initializes an instance of FMDatabase. If the database is new the
// installation script is run against it.
- (FMDatabase *)initializeFMDatabaseInstance {
    FMDatabase* database;

    // If the file does not exist then this is a new installation. We need to run the install script.
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_databasePath];
    if (!fileExists) {
        
        // The database does not exist so create it
        database = [FMDatabase databaseWithPath:_databasePath];
        
        if ([database open]) {
            NSLog(@"Opening the new db was successful");
        
            // Look for the file "DatabaseInstall.sql"
            NSString *installScriptPath = [[NSBundle mainBundle] pathForResource:@"DatabaseInstall" ofType:@"sql"];
            NSString *installScript = [NSString stringWithContentsOfFile:installScriptPath encoding:NSUTF8StringEncoding error:nil];
            
            NSError *error;
            [database executeBatchWithSqlScript:installScript outError:&error];
            if (error != nil)
                NSLog(@"Updated failed with error");
        }
        
        [database close];
    }
    
    // Re-init the database, since it may have already existed
    return[FMDatabase databaseWithPath:_databasePath];
}

// This method executes a script on the current database to determine the version and then compares
// it to the version specified by the property "databaseVersion".
- (BOOL)databaseDoesNeedUpgradeFromVersion:(double*)actualDatabaseVersion {
    BOOL doesNeedUpgrade = false;

    [_database open];
    
    // For each version of the database we insert a row, if the version of the latest is less than the
    // version hard specified by this file then we need an upgrade.
    FMResultSet *result = [_database executeQuery:@"SELECT databaseVersion FROM Version ORDER BY versionID DESC LIMIT 1;"];
    if ([result next]) {
        *actualDatabaseVersion = [result doubleForColumnIndex:0];
        NSLog(@"Database version is %.2f", *actualDatabaseVersion);
        
        if (*actualDatabaseVersion < _databaseVersion)
            doesNeedUpgrade = true;
    }
    [result close];
    [_database close];
    
    return doesNeedUpgrade;
}

// This method returns an array of database versions that need to be upgraded to.
- (NSArray *)getVersionsToUpgradeToFromOldVersion:(double)oldVersion {
    NSMutableArray *versionsNeeded = [[NSMutableArray alloc] init];
    
    for (NSNumber *version in [self getDatabaseVersionHistory]) {
        if (oldVersion < [version doubleValue]) {
            [versionsNeeded addObject:version];
        }
    }
    
    return [NSArray arrayWithArray:versionsNeeded];
}

// This method constructs the filename and path to retrieve an upgrade script
// for a specific version.
- (NSString*)getUpgradeScriptForVersion:(double)upgradeDatabaseVersion {
    // To get the database upgrade script, we need to "build" the filename
    NSString *dbVersionString = [NSString stringWithFormat:@"%.2f", upgradeDatabaseVersion];
    NSArray *dbVersionDelimed = [dbVersionString componentsSeparatedByString:@"."];
    NSString *dbVersion = [dbVersionDelimed firstObject];
    NSString *dbSubVersion = [dbVersionDelimed lastObject];
    NSString *upgradeFileName = [NSString stringWithFormat:@"%@_%@_upgrade", dbVersion, dbSubVersion];
    
    NSString *upgradeScriptPath = [[NSBundle mainBundle] pathForResource:upgradeFileName ofType:@"sql"];
    return [NSString stringWithContentsOfFile:upgradeScriptPath encoding:NSUTF8StringEncoding error:nil];
}

// This method will iterate the versioning scripts and execute them.
- (BOOL)executeUpgradesWithVersions:(NSArray*)versions {
    for (NSNumber *version in versions) {
        [_database open];
        
        NSString *upgradeScript = [self getUpgradeScriptForVersion:[version doubleValue]];
        
        NSError *error;
        [_database executeBatchWithSqlScript:upgradeScript outError:&error];
        if (error != nil)
            NSLog(@"Updated failed with error");
        
        [_database close];
    }
    
    return true;
}

@end
