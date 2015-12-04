//
//  SettingTableViewController.h
//  LostAndFoundApp
//
//  Created by HoangVu on 10/29/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewController : UITableViewController
- (IBAction)notifiTap:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *notifiswitch;
- (IBAction)soundTap:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;

@end
