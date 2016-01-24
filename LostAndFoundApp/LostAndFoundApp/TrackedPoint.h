//
//  TrackedPoint.h
//  LostAndFoundApp
//
//  Created by HoangVu on 1/24/16.
//  Copyright © 2016 HoangVu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TrackedPoint : NSObject
@property (nonatomic, strong) NSString* time;
@property (nonatomic, strong) NSString* placeDetail;
- (id) initWithCoordinate: (double) lng withLat: (double) lat andTime:(NSDate*) updateTime;
- (NSString*)serialize;
@end
