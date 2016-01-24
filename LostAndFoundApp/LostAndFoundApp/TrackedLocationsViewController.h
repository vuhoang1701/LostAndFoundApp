//
//  TrackedLocationsViewController.h
//  LostAndFoundApp
//
//  Created by HoangVu on 1/23/16.
//  Copyright © 2016 HoangVu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import <ParseUI/ParseUI.h>
@interface TrackedLocationsViewController : PFQueryTableViewController <UITableViewDelegate, UITableViewDataSource>
- (IBAction)btnDeleteAll:(id)sender;
@property (nonatomic, strong) Item* item;
@end
