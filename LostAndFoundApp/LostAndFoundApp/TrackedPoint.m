//
//  TrackedPoint.m
//  LostAndFoundApp
//
//  Created by HoangVu on 1/24/16.
//  Copyright © 2016 HoangVu. All rights reserved.
//

#import "TrackedPoint.h"
#import "AppDelegate.h"
#import "NSDate+NVTimeAgo.h"
@implementation TrackedPoint

- (id) initWithCoordinate: (double) lng withLat: (double) lat andTime:(NSDate*) updateTime {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
    self.time = [updateTime formattedAsTimeAgo];
    
    //Get address
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:lat longitude:lng];
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         self.placeDetail = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         
     }];
    return self;
}

- (NSString*) serialize {
    NSString* result = [NSString stringWithFormat:@"%@ \n%@", self.placeDetail, self.time];
    return result;
}

@end
