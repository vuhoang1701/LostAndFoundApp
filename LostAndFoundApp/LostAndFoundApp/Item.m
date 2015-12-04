//
//  Item.m
//  LostAndFoundApp
//
//  Created by HoangVu on 10/8/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import "Item.h"

@implementation Item
@synthesize UUID; // UUID of item
@synthesize major; // major of item
@synthesize minor; // minor of item
@synthesize name; // name of item
@synthesize userId; // userID of item
@synthesize longitude; // longitude of item
@synthesize latitude; // latitude of item
@synthesize isLost; // islost value
@synthesize notify;
@synthesize lastUpdate; // lastupdate of item
@synthesize imageFile; // image of item
@end
