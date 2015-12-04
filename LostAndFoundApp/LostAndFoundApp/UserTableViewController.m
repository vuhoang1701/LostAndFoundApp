//
//  UserTableViewController.m
//  LostAndFoundApp
//
//  Created by HoangVu on 10/29/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import "UserTableViewController.h"
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "LoginViewController.h"
#import "AppDelegate.h"
@interface UserTableViewController ()

@end

@implementation UserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser*user = [PFUser currentUser];
    PFFile *thumbnail = [user objectForKey:@"profile_picture"];
    self.imageUser.image = [UIImage imageNamed:@"images.jpeg"];
    self.imageUser.file = thumbnail;
    self.imageUser.layer.cornerRadius = 5;
    self.imageUser.clipsToBounds = YES;
    [ self.imageUser loadInBackground];
    
    //Get Item bame
    
    if( [user objectForKey:@"name"] ==  nil)
    {
        self.lbelUsername.text = [NSString stringWithFormat:@"Username : %@", [user objectForKey:@"username"]];
        
    }
    else{
        self.lbelUsername.text = [NSString stringWithFormat:@"Name : %@", [user objectForKey:@"name"]];
        
    }
    self.lbelEmail.text = [NSString stringWithFormat:@"Email : %@", [user objectForKey:@"email"]];
    

    
    
}


    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;


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
    return 3;
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

@end
