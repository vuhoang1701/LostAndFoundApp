//
//  DetailViewController.m
//  LostAndFoundApp
//
//  Created by HoangVu on 10/8/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import "DetailViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import <EstimoteSDK/EstimoteSDK.h>
#import "AppDelegate.h"
@interface DetailViewController ()<ESTBeaconManagerDelegate>
@property (nonatomic) ESTBeaconManager *beaconManager;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@end

@implementation DetailViewController

@synthesize imageItem;
@synthesize labelDistance;
@synthesize labelColor;
@synthesize labelStatus;
@synthesize labelTime;
@synthesize item;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initDetailItem];
    //Init and set dele for beaconmanager
    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self; 
    NSUUID *uuid = [[NSUUID alloc]
                    initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:[item.major intValue] minor: [item.minor intValue] identifier:@"regiondetail"];
     [self.beaconManager requestAlwaysAuthorization];
    self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ibecon.png"]];
    self.view.backgroundColor = [UIColor clearColor];


    
 
//    UIImage *btnImage = [UIImage imageNamed:@"Delete_Icon.png"];
//    [self.btnDeleteItem setImage:btnImage forState:UIControlStateNormal];
//    UIImage *buttonImage = [UIImage imageNamed:@"back-icon.png"];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setImage:buttonImage forState:UIControlStateNormal];
//    button.frame = CGRectMake(0, 0, 29, 29);
//    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.leftBarButtonItem = customBarItem;
    



    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}

-(void) initDetailItem
{
    
    //Set Cpntent of Item
    self.title = item.name;
    self.labelTime.text = item.lastUpdate;
    self.imageItem.file = item.imageFile;
    [self.LostSwitch setOn:item.isLost animated:YES];
    [self.NotifySwitch setOn:item.notify animated:YES];
    
    ///init and setdelegate location and mapview
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    [self.mapView setDelegate:self];
    self.mapView.showsUserLocation = YES;
    
    ///Radius for image and mapview
    self.imageItem.layer.cornerRadius = 5;
    self.imageItem.clipsToBounds = YES;
    self.mapView.layer.cornerRadius = 40;
    self.mapView.clipsToBounds = YES;
    
    
    ///Set rectangke for mapview with coor of item
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    // Region struct defines the map to show based on center coordinate and span.
    MKCoordinateRegion region;
    CLLocationCoordinate2D  locationitem;
    locationitem.latitude = [item.latitude floatValue];
    locationitem.longitude = [item.longitude floatValue];
    region.center = locationitem;
    region.span = span;
    // Update the map to display the current location.
    [self.mapView setRegion:region animated:YES];
    [self plotResults];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentlocation = [locations objectAtIndex:0];
      // Stop core location services to conserve battery.
    [manager stopUpdatingLocation];
    
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager:didFailWithError");
}


-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    return nil;

}


- (void) plotResults {
    // Annotate the result.
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D  locationitem;
    locationitem.latitude = [item.latitude floatValue];
    locationitem.longitude = [item.longitude floatValue];
    point.coordinate = locationitem;
    point.title = item.name;
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:locationitem.latitude longitude:locationitem.longitude];
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         //String to hold address
         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         point.subtitle = locatedAt;
         
     }];
    [self.mapView addAnnotation:point];

    [item.imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [self imageWithImage:[UIImage imageWithData:data] scaledToSize:CGSizeMake(20, 20)];
            
            [[self.mapView viewForAnnotation:point] setImage:image];
            // image can now be set on a UIImageView
        }
    }];
   
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

     

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)viewDidUnload
{
    [self setImageItem:nil];
    [self setLabelTime:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)btnDeleteTap:(id)sender {
}
- (IBAction)tapLostSwitch:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Waiting";
    [hud show:YES];
    UISwitch *whichSwitch = (UISwitch *)sender;
    BOOL setting = whichSwitch.isOn;
    PFQuery *islost = [PFQuery queryWithClassName:@"Item"];
    [islost whereKey:@"Major" equalTo: item.major];
    [islost whereKey:@"Minor" equalTo: item.minor];

    [islost getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            // Did not find any UserStats for the current user
            NSLog(@"Update status Lost fail");
        } else {
            if(setting == YES)
            {
                [object setObject:[NSNumber numberWithBool:YES]  forKey:@"IsLost"];
            }
            else
            {
                 [object setObject:[NSNumber numberWithBool:NO]  forKey:@"IsLost"];
            }
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded)
                {
                    
                    [hud hide:YES];
                    [self.LostSwitch setOn:setting animated:YES];
                    
                }
            }];
            
        }
    }];
}

- (IBAction)tapNotifySwitch:(id)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Waiting";
    [hud show:YES];
    UISwitch *whichSwitch = (UISwitch *)sender;
    BOOL setting = whichSwitch.isOn;
    PFQuery *isNotify = [PFQuery queryWithClassName:@"Item"];
    [isNotify whereKey:@"Major" equalTo: item.major];
    [isNotify whereKey:@"Minor" equalTo: item.minor];
    
    [isNotify getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            // Did not find any UserStats for the current user
            NSLog(@"Update notify fail");
        } else {
            if(setting == YES)
            {
                [object setObject:[NSNumber numberWithBool:YES]  forKey:@"Notify"];
            }
            else
            {
                [object setObject:[NSNumber numberWithBool:NO]  forKey:@"Notify"];
            }
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded)
                {
                    
                    [hud hide:YES];
                    [self.NotifySwitch setOn:setting animated:YES];
                     AppDelegate * delegate =(AppDelegate*) [UIApplication sharedApplication].delegate;
                    [delegate EnableExitRange];
                    
                }
            }];
            
        }
    }];
    
}

- (void)beaconManager:(id)manager didEnterRegion:(CLBeaconRegion *)region {
    
    NSLog(@"enter");
    //[self.beaconManager startRangingBeaconsInRegion:region];
}
- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons
             inRegion:(CLBeaconRegion *)region {
    if(beacons.count == 1)
    {
        CLBeacon *nearestBeacon = beacons.firstObject;
        if (nearestBeacon!= nil && nearestBeacon.accuracy != -1) {
            
            self.labelStatus.text = [NSString stringWithFormat:@"Status: In beacon Region"];
            self.labelDistance.text = [NSString stringWithFormat:@"Distance: ~%2.1f m", nearestBeacon.accuracy  ];
            NSLog(@"%f", nearestBeacon.accuracy);
        }
 
    }

}

- (void)beaconManager:(id)manager didExitRegion:(CLBeaconRegion *)region
{
    
    self.labelStatus.text = [NSString stringWithFormat:@"Status: Out beacon region"];
    self.labelDistance.text = [NSString stringWithFormat:@"Distance: Undifined"];
    [self.beaconManager startRangingBeaconsInRegion:region];
}

@end
