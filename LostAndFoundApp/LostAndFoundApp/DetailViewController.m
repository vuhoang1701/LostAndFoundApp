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
#import <AVFoundation/AVFoundation.h>
@interface DetailViewController ()<ESTBeaconManagerDelegate>
@property (nonatomic) ESTBeaconManager *beaconManager;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic)   AppDelegate *delegate;
@end

@implementation DetailViewController
{
    CLLocationCoordinate2D  locationitem;
    AVAudioPlayer *_audioPlayer;
    NSTimer* timerPlay;
    BOOL isPlay;

}

@synthesize imageItem;
@synthesize labelDistance;
@synthesize labelColor;
@synthesize labelStatus;
@synthesize labelTime;
@synthesize item;
- (void)viewDidLoad {
    isPlay = false;
    _delegate =(AppDelegate*) [UIApplication sharedApplication].delegate;
    [super viewDidLoad];
    //Init and set dele for beaconmanager
    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self; 
    NSUUID *uuid = [[NSUUID alloc]
                    initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:[item.major intValue] minor: [item.minor intValue] identifier:@"regiondetail"];
     [self.beaconManager requestAlwaysAuthorization];
    [_delegate setbackground:self.parentViewController.view];
       self.view.backgroundColor = [UIColor clearColor];

    isPlay =  false;
    // Construct URL to sound file
    NSString *path = [NSString stringWithFormat:@"%@/peep.wav", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    // Create audio player object and initialize with URL to sound
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [self initDetailItem];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
     [self stopLoop];
}

- (void)viewDidUnload
{
    [self setImageItem:nil];
    [self setLabelTime:nil];
    [self stopLoop];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
   
    // Region struct defines the map to show based on center coordinate and span.
    MKCoordinateRegion region;
    locationitem.latitude = [item.latitude floatValue];
    locationitem.longitude = [item.longitude floatValue];
    region.center = locationitem;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.5;
    span.longitudeDelta = 0.5;
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)btnDeleteTap:(id)sender {
    
    if ([CLLocationManager locationServicesEnabled] == YES) {
         [self getallpoint];
        //AudioServicesPlaySystemSound(1003);
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Location is disable, please enable location service"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
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
                    [_delegate EnableExitRange];
                    
                }
            }];
            
        }
    }];
    
}

- (void)getallpoint
{
    MKPlacemark *source = [[MKPlacemark   alloc]initWithCoordinate:locationitem   addressDictionary: nil];
    MKMapItem *srcMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    [srcMapItem setName:@""];
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:self.currentlocation.coordinate addressDictionary:nil ];
    
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    [request setTransportType:MKDirectionsTransportTypeWalking];
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        NSLog(@"response = %@",response);
        NSArray *arrRoutes = [response routes];
        [arrRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MKRoute *rout = obj;
            
            MKPolyline *line = [rout polyline];
            [self.mapView addOverlay:line];
            NSLog(@"Rout Name : %@",rout.name);
            NSLog(@"Total Distance (in Meters) :%f",rout.distance);
            
            NSArray *steps = [rout steps];
            
            NSLog(@"Total Steps : %d",[steps count]);
            
            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSLog(@"Rout Instruction : %@",[obj instructions]);
                NSLog(@"Rout Distance : %f",[obj distance]);
            }];
        }];
    }];
}

- (void)showDirection
{
    CLLocationCoordinate2D *pointsCoordinate = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * 2);
    pointsCoordinate[0] = locationitem;
    pointsCoordinate[1] = self.currentlocation.coordinate;
    
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:pointsCoordinate count:2];
    free(pointsCoordinate);
    
    [self.mapView addOverlay:polyline];
}

- (MKPolylineRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay{
    
    // create a polylineView using polyline overlay object
    MKPolylineRenderer *polylineView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    
    // Custom polylineView
    polylineView.strokeColor =  [UIColor blueColor];
    polylineView.lineWidth = 2.0;
    polylineView.alpha = 0.5;
    
    return polylineView;
}


 #pragma mark - Beacon
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
             if(nearestBeacon.accuracy <= 20)
             {
                 float range = 1 - (nearestBeacon.accuracy/20);
                 [_audioPlayer setVolume: 1.0];
             }
            if(isPlay== false && nearestBeacon.accuracy <= 20)
            {
            
                [self loopSound];
                isPlay = true;
            }
            
            self.labelStatus.text = [NSString stringWithFormat:@"Status: In beacon Region"];
            self.labelDistance.text = [NSString stringWithFormat:@"Distance: ~%2.1f m", nearestBeacon.accuracy  ];
            NSLog(@"%f", nearestBeacon.accuracy);
        }
 
    }
    else
    {
        self.labelStatus.text = [NSString stringWithFormat:@"Status: Out beacon Region"];
        self.labelDistance.text = [NSString stringWithFormat:@"Distance: Undefined"];
        [self stopLoop];
    }
        

}
-(void) loopSound
{
    timerPlay = [NSTimer scheduledTimerWithTimeInterval:(1.0)
                                                 target:self
                                               selector:@selector(playSound)
                                               userInfo:nil
                                                repeats:YES];
}

-(void) stopLoop
{
    [timerPlay invalidate];
    timerPlay = nil;
    isPlay = false;
}

-(void) playSound {
    if(_LostSwitch.isOn == YES)
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        [_audioPlayer play];
    }
}

- (void)beaconManager:(id)manager didExitRegion:(CLBeaconRegion *)region
{
    [self stopLoop];
    [_audioPlayer play];
    self.labelStatus.text = [NSString stringWithFormat:@"Status: Out beacon region"];
    self.labelDistance.text = [NSString stringWithFormat:@"Distance: Undefined"];
    [self.beaconManager startRangingBeaconsInRegion:region];
}



@end
