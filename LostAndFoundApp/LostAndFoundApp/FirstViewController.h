//
//  FirstViewController.h
//  LostAndFoundApp
//
//  Created by HoangVu on 10/8/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "Listener.h"
@interface FirstViewController : PFQueryTableViewController <UISearchBarDelegate, ListenerDelegate>
@property (strong, nonatomic) Listener* listener;
- (IBAction)btnVoice:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnVoice;

@end

