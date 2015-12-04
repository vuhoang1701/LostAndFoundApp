//
//  DetailViewController.h
//  LostAndFoundApp
//
//  Created by HoangVu on 10/8/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <ParseUI/ParseUI.h>
#import "Item.h"
@interface DetailViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate>
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation* currentlocation;
- (IBAction)btnDeleteTap:(id)sender;
@property (weak, nonatomic) IBOutlet PFImageView *imageItem;
@property (weak, nonatomic) IBOutlet UIButton *btnDeleteItem;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *labelColor;
@property (weak, nonatomic) IBOutlet UILabel *labelDistance;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (nonatomic, strong) Item *item;

@property (weak, nonatomic) IBOutlet UISwitch *LostSwitch;

- (IBAction)tapLostSwitch:(id)sender;
- (IBAction)tapNotifySwitch:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *NotifySwitch;


@end
