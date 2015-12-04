//
//  UserTableViewController.h
//  LostAndFoundApp
//
//  Created by HoangVu on 10/29/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
@interface UserTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *lbelUsername;
@property (weak, nonatomic) IBOutlet UILabel *lbelEmail;
@property (weak, nonatomic) IBOutlet PFImageView *imageUser;

@end
