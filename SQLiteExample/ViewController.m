//
//  ViewController.m
//  SQLiteExample
//
//  Created by alex on 27/9/20.
//  Copyright © 2020 alex. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(void) showUIAlertWithMessage:(NSString*) message andTitle:(NSString*)title{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            NSLog(@"You have saved the planet");
        }];
        [alert addAction:okAction];
    
        [self presentViewController:alert animated:YES completion:^{
            NSLog(@"%@", message);
        }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString* docsDir;
    NSArray* dirPaths;
    
    //get the directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    //Build the path to keep the database
    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"myUsers.db"]];
    
    NSFileManager* fileMananger = [NSFileManager defaultManager];
    
    if([fileMananger fileExistsAtPath:_databasePath] == NO){
        const char* dbPath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbPath, &_db) == SQLITE_OK){
            char* errorMessage;
            const char* sqlStatement = "CREATE TABLE IF NOT EXISTS USERS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)";
            if(sqlite3_exec(_db, sqlStatement, NULL, NULL, &errorMessage) != SQLITE_OK){
                [self showUIAlertWithMessage:@"Failed to create the table" andTitle: @"SQLite3"];
            }
            sqlite3_close(_db);
        }else{
            [self showUIAlertWithMessage:@"Failed to open/create the table" andTitle: @"SQLite3"];
        }
    }
}



- (IBAction)viewAll:(id)sender {
    const char* dbPath = [_databasePath UTF8String];

    sqlite3_stmt *stmt = NULL;
    int err = 0;
    
    if(sqlite3_open(dbPath, &_db) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT ID, Name FROM users"];
        const char* queryStatement = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_db, queryStatement, -1, &stmt, NULL) == SQLITE_OK ){
            
            if (err != SQLITE_OK) {
                NSLog(@"prepare failed: %s", sqlite3_errmsg(_db));
            }else{

                for (;;) {
                    err = sqlite3_step(stmt);
                    if (err != SQLITE_ROW)
                        break;

                    int id = sqlite3_column_int (stmt, 0);
                    const unsigned char* name = sqlite3_column_text(stmt, 1);

                    NSLog(@"ID: %d, Name: %s\n", id, name);
                }

                if (err != SQLITE_DONE) {
                    NSLog(@"execution failed: %s", sqlite3_errmsg(_db));
                }
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(_db);

    }
}

- (IBAction)remove:(id)sender {
    const char* dbPath = [_databasePath UTF8String];
    char* errorMessage;
    
    if(sqlite3_open(dbPath, &_db) == SQLITE_OK){
        NSString* querySQL = [NSString stringWithFormat:@"DELETE FROM users WHERE name = \"%@\"", [_nameTextField text]];
        const char* queryStatement = [querySQL UTF8String];
        int value = sqlite3_exec(_db, queryStatement, NULL, NULL, &errorMessage);
        if( value == SQLITE_OK){
            [self showUIAlertWithMessage:@"Deleted from database" andTitle: @"SQLite3"];
            [_addressTextField setText:@""];
            [_phoneTextField setText:@""];
            [_nameTextField setText:@""];
        }else{
            [self showUIAlertWithMessage:@"Failed to delete from database" andTitle: @"SQLite3"];
        }
    }else{
        [self showUIAlertWithMessage:@"Failed to delete from database" andTitle: @"SQLite3"];
    }
    
}

- (IBAction)find:(id)sender {
    
    sqlite3_stmt* statement;
    const char* dbPath =[_databasePath UTF8String];
    
    if(sqlite3_open(dbPath, &_db) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT address, phone FROM users WHERE name = \"%@\"", [_nameTextField text] ];
        const char* queryStatement = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_db, queryStatement, -1, &statement, NULL) == SQLITE_OK ){
            if(sqlite3_step(statement) == SQLITE_ROW){
                NSString* addressField = [[NSString alloc] initWithUTF8String: (const char*) sqlite3_column_text(statement, 0)];
                [_addressTextField setText:addressField];
                NSString* phoneField = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(statement, 1)];
                [_phoneTextField setText:phoneField];
                [self showUIAlertWithMessage:@"Match found in the database" andTitle: @"SQLite3"];
            }else{
                [self showUIAlertWithMessage:@"Match not found in the database" andTitle: @"SQLite3"];
                [_addressTextField setText:@""];
                [_phoneTextField setText:@""];
            }
        }else{
            [self showUIAlertWithMessage:@"Failed to search the database" andTitle: @"SQLite3"];
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    
    
    
}

- (IBAction)save:(id)sender {
    sqlite3_stmt* statement;
    const char* dbPath = [_databasePath UTF8String];
    
    if(sqlite3_open(dbPath, &_db) == SQLITE_OK){
        NSString* insertSQL = [NSString stringWithFormat:@"INSERT INTO USERS (NAME, ADDRESS, PHONE) VALUES (\"%@\", \"%@\", \"%@\")", [_nameTextField text], [_addressTextField text], [_phoneTextField text]  ];
        const char* insert_statement = [insertSQL UTF8String];
        sqlite3_prepare_v2(_db, insert_statement, -1, &statement, NULL);
        
        if(sqlite3_step(statement) == SQLITE_DONE){
            [self showUIAlertWithMessage:@"User added to the db" andTitle: @"SQLite3"];
            [_nameTextField setText:@""];
            [_addressTextField setText:@""];
            [_phoneTextField setText:@""];
        }else{
            [self showUIAlertWithMessage:@"Failed to add the user" andTitle: @"SQLite3"];
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
}



@end
