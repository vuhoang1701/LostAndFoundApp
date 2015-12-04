//
//  SecondViewController.h
//  LostAndFoundApp
//
//  Created by HoangVu on 10/8/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
@interface SecondViewController : UIViewController
@property (weak, nonatomic) IBOutlet PFImageView *imageUser;
@property (weak, nonatomic) IBOutlet UILabel *lbelUserName;
@property (weak, nonatomic) IBOutlet UILabel *lbelEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnLogoutTap;
- (IBAction)tapLogout:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *containerSetting;
@property (weak, nonatomic) IBOutlet UIView *containerUser;

@end

