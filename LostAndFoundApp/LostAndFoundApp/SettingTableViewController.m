//
//  SettingTableViewController.m
//  LostAndFoundApp
//
//  Created by HoangVu on 10/29/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import "SettingTableViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"
@interface SettingTableViewController ()

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDetailItem];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 2;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void) initDetailItem
{
    PFUser *user = [PFUser currentUser];
    if(user != nil )
    {
        NSString* userId = [user objectId];
        PFQuery *item1 = [PFUser query];
        [item1 whereKey:@"objectId" equalTo: userId ];
        [item1 whereKey:@"Notifty" equalTo:[NSNumber numberWithBool:YES]];
        //NSError *error ;
        PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:item1,nil]];
        [query  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                PFObject* object = objects.firstObject;
                if (object!= nil) {
                    [self.notifiswitch setOn:YES animated:YES];
                }
                else
                {
                     [self.notifiswitch setOn:NO animated:YES];
                }
                
                
            }
            
            
        }];
        
        
    }

}

- (IBAction)notifiTap:(id)sender {
    
     AppDelegate * delegate =(AppDelegate*) [UIApplication sharedApplication].delegate;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Waiting";
    [hud show:YES];
    UISwitch *whichSwitch = (UISwitch *)sender;
    BOOL setting = whichSwitch.isOn;
    PFUser *user = [PFUser currentUser];
    if(user != nil )
    {
        NSString* userId = [user objectId];
        PFQuery *item1 = [PFUser query];
        [item1 whereKey:@"objectId" equalTo: userId ];
        PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:item1,nil]];
        [query  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                PFObject* object = objects.firstObject;
                if (object!= nil) {
                
                    if(setting == YES)
                    {
                        [object setObject:[NSNumber numberWithBool:YES]  forKey:@"Notifty"];
                        [delegate EnableExitRange];
                        
                    }
                    else
                    {
                        [object setObject:[NSNumber numberWithBool:NO]  forKey:@"Notifty"];
                    }
                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(succeeded)
                        {
                            
                            [hud hide:YES];
                            [self.notifiswitch setOn:setting animated:YES];
                            
                        }
                    }];
                }
                
                
            }
            
            
        }];
        
        
    }
}
- (IBAction)soundTap:(id)sender {
}
@end
