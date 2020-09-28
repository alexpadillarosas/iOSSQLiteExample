//
//  ViewController.h
//  SQLiteExample
//
//  Created by alex on 27/9/20.
//  Copyright © 2020 alex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) NSString* databasePath;
@property (nonatomic) sqlite3* db;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

- (IBAction)save:(id)sender;
- (IBAction)find:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)viewAll:(id)sender;


@end

