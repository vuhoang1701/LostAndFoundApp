//
//  AddItemViewController.h
//  LostAndFoundApp
//
//  Created by HoangVu on 10/12/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AddItemViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *labelMajor;
@property (weak, nonatomic) IBOutlet UILabel *labelMinor;
- (IBAction)tapBtnDone:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *txtItemName;
@property (strong, nonatomic) IBOutlet UIView *viewAnimation;

@property (weak, nonatomic) IBOutlet UIImageView *imageItem;
- (IBAction)tapLoadImage:(id)sender;
- (IBAction)tapselectImage:(id)sender;


@end
