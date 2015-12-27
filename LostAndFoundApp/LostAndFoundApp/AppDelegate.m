//
//  AppDelegate.m
//  LostAndFoundApp
//
//  Created by HoangVu on 10/8/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import <EstimoteSDK/EstimoteSDK.h>
#import "BeaconNotificationsManager.h"
@interface AppDelegate () <ESTBeaconManagerDelegate>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@property (nonatomic) ESTBeaconManager *beaconManager;
@property (nonatomic) Boolean *first;
@property (nonatomic) BeaconNotificationsManager *beaconNotificationsManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    

    self.first = YES;
    //Init and request location
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    //Init and set dele for beaconmanager
    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self;
    [self.beaconManager requestAlwaysAuthorization];
    NSUUID *uuid = [[NSUUID alloc]
                    initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                              
                                                            identifier:@"regionDelegate"];
    [self.beaconManager startRangingBeaconsInRegion:region];
    [self.beaconManager startMonitoringForRegion:region];
    

    
    [ESTConfig setupAppID:@"vuhoang1701-gmail-com-s-no-4dj" andAppToken:@"f21f22a74f5ca5aaff6034c23ac037eb"];
    
    
    //Push notificaiton declare
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    //Declare parse key
    [Parse setApplicationId:@"cwWhT5nGZRriLl7DRpSeD46xx7sgksXlRSErQO3Q"
                  clientKey:@"qV5TxnSpsA9jX0t0YiGuRAdDjPRvBanr9HKl2GsC"];
    
    
    //Init FBSDK
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    PFUser *user = [PFUser currentUser];
    if(user != nil )
    {
        NSString* userId = [user objectId];
        PFQuery *item1 = [PFUser query];
        [item1 whereKey:@"objectId" equalTo: userId ];
        [item1 whereKey:@"Notifty" equalTo:[NSNumber numberWithBool:YES]];
        //NSError *error ;
        PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:item1,nil]];
        [query  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
          if(objects.count >0)
          {
                    [self EnableExitRange];
          }
                
                
            }
            
            
        }];
        
        
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [FBSDKAppEvents activateApp];
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}
- (void)beaconManager:(id)manager didEnterRegion:(CLBeaconRegion *)region {
    
     NSLog(@"enter");
}



- (void)beaconManager:(id)manager didExitRegion:(CLBeaconRegion *)region
{
    

    
}

-(void) EnableExitRange
{
    self.beaconNotificationsManager = [BeaconNotificationsManager new];

    NSString* userId = [[PFUser currentUser] objectId];
    PFQuery *item1 = [PFQuery queryWithClassName:@"Item"];
    [item1 whereKey:@"UserId" equalTo: userId ];
    [item1 whereKey:@"Notify" equalTo:[NSNumber numberWithBool:YES]];
                //NSError *error ;
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:item1,nil]];
    [query  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
            for(id item in objects)
            {
                PFObject* object = item;
                [self.beaconNotificationsManager
                enableNotificationsForBeaconID: [[BeaconID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
                                                                                        major:[[object valueForKey:@"Major"] intValue]
                                                                                        minor:[[object valueForKey:@"Minor"] intValue]]
                enterMessage:[NSString stringWithFormat:@"%@ is near you", [object valueForKey:@"ItemName"]]
                exitMessage:[NSString stringWithFormat:@"You forget %@", [object valueForKey:@"ItemName"]]// NOTE: "exit" event has a built-in delay of 30 seconds, to make sure that the user has really exited the beacon's range. The delay is imposed by iOS and is non-adjustable.
                ];
            }
        
                }
                
                
    }];
}
-(void) UpdateLocationLostBeacon: (NSNumber*) major withMinor: (NSNumber*) minor
{
    
    PFQuery *islost = [PFQuery queryWithClassName:@"Item"];
    [islost whereKey:@"IsLost" equalTo:[NSNumber numberWithBool:YES]];
    [islost whereKey:@"Major" equalTo: major];
    [islost whereKey:@"Minor" equalTo: minor];
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:islost,nil]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object,NSError* error) {
        if (!object) {
        } else {
            __unused NSString *string= [NSString stringWithFormat: @"Major %d , Minor %d",[[object objectForKey:@"Minor"] intValue],[[object objectForKey:@"Major"] intValue]  ];
            float longi = self.currentlocation.coordinate.longitude;
            float lat = self.currentlocation.coordinate.latitude;
            [object setObject:[NSString stringWithFormat:@"%f",longi] forKey:@"Longitude"];
            [object setObject:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded)
                {
                    NSLog(@"Location details are update");
                    [self.locationManager stopUpdatingLocation];
                }
            }];
            
        }

        
    }];
}
- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons
             inRegion:(CLBeaconRegion *)region {
    if(beacons.count != 0)
    {
    for (id object in beacons) {
        CLBeacon *item = object;
        [self.locationManager startUpdatingLocation];
        [self UpdateLocationLostBeacon:item.major withMinor:item.minor];
    }
      
}
 
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentlocation = [locations objectAtIndex:0];
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    // Region struct defines the map to show based on center coordinate and span.
    MKCoordinateRegion region;
    region.center = self.currentlocation.coordinate;
    region.span = span;
    if (self.currentlocation.coordinate.longitude != 0  ||self.currentlocation.coordinate.latitude != 0) {
        [manager stopUpdatingLocation];
    }
    
    
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager:didFailWithError");
}

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) setbackground: (UIView*) view
{
     UIImage *image = [self imageWithImage:[UIImage imageNamed:@"ibecon.png"] scaledToWidth:view.frame.size.width];
    view.backgroundColor = [UIColor colorWithPatternImage:image];

}





@end