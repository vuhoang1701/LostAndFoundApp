//
//  AppDelegate.h
//  LostAndFoundApp
//
//  Created by HoangVu on 10/8/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation* currentlocation;
@property (strong,nonatomic) NSArray *listbeacon;
-(void) EnableExitRange;
-(void) setbackground: (UIView*) view;
@end

