//
//  Item.h
//  LostAndFoundApp
//
//  Created by HoangVu on 10/8/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import 	<Parse/Parse.h>

@interface Item : NSObject
@property (nonatomic, strong) NSString *UUID; // UUID of item
@property (nonatomic, strong) NSString *major; // major of item
@property (nonatomic, strong) NSString *minor; // minor of item
@property (nonatomic, strong) NSString *name; // name of item
@property (nonatomic, strong) NSString *userId; // userID of item
@property (nonatomic, strong) NSString *longitude; // longitude of item
@property (nonatomic, strong) NSString *latitude; // latitude of item
@property (nonatomic, assign) BOOL isLost; // islost value
@property (nonatomic, assign) BOOL notify; // islost value
@property (nonatomic, strong) NSString *lastUpdate; // lastupdate of item
@property (nonatomic, strong) PFFile *imageFile; // image of item

@end
