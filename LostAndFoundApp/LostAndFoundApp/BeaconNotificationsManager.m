//
//  BeaconNotificationsManager.m
//  Vuhoang1701GmailComSNo4Dj
//

#import "BeaconNotificationsManager.h"
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface BeaconNotificationsManager () <ESTBeaconManagerDelegate>

@property (nonatomic) ESTBeaconManager *beaconManager;

@property (nonatomic) NSMutableDictionary *enterMessages;
@property (nonatomic) NSMutableDictionary *exitMessages;

@end

@implementation BeaconNotificationsManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.beaconManager = [ESTBeaconManager new];
        self.beaconManager.delegate = self;
        [self.beaconManager requestAlwaysAuthorization];

        self.enterMessages = [NSMutableDictionary new];
        self.exitMessages = [NSMutableDictionary new];

        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    return self;
}

- (void)enableNotificationsForBeaconID:(BeaconID *)beaconID
                          enterMessage:(NSString *)enterMessage
                           exitMessage:(NSString *)exitMessage {
    CLBeaconRegion *beaconRegion = beaconID.asBeaconRegion;
    self.enterMessages[beaconRegion.identifier] = [enterMessage copy];
    self.exitMessages[beaconRegion.identifier] = [exitMessage copy];
    [self.beaconManager startMonitoringForRegion:beaconRegion];
}

- (void)beaconManager:(id)manager didEnterRegion:(CLBeaconRegion *)region {
    NSString *message = self.enterMessages[region.identifier];
    if (message) {
        [self showNotificationWithMessage:message];
    }
}

- (void)beaconManager:(id)manager didExitRegion:(CLBeaconRegion *)region {
    NSString *message = self.exitMessages[region.identifier];
    if (message) {
        [self showNotificationWithMessage:message];
    }
}

- (void)showNotificationWithMessage:(NSString *)message {
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
                    UILocalNotification *notification = [UILocalNotification new];
                    notification.alertBody = message;
                    notification.soundName = UILocalNotificationDefaultSoundName;
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                    NSLog(@"Showed notification");
                }
                
                
            }
            
            
        }];
        
        
    }
    
}

- (void)beaconManager:(id)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        NSLog(@"Location Services are disabled for this app, which means it won't be able to detect beacons.");
    }
}

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"Monitoring failed for region: %@. Make sure that Bluetooth and Location Services are on, and that Location Services are allowed for this app. Beacons require a Bluetooth Low Energy compatible device: <http://www.bluetooth.com/Pages/Bluetooth-Smart-Devices-List.aspx>. Note that the iOS simulator doesn't support Bluetooth at all. The error was: %@", region.identifier, error);
}

@end
