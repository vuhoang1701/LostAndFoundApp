//
//  BeaconNotificationsManager.h
//  Vuhoang1701GmailComSNo4Dj
//

#import <Foundation/Foundation.h>
#import <EstimoteSDK/EstimoteSDK.h>

#import "BeaconID.h"

@interface BeaconNotificationsManager : NSObject

- (void)enableNotificationsForBeaconID:(BeaconID *)beaconID
                          enterMessage:(NSString *)enterMessage
                           exitMessage:(NSString *)exitMessage;

@end
