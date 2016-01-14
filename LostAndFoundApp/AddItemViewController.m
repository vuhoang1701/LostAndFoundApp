//
//  AddItemViewController.m
//  LostAndFoundApp
//
//  Created by HoangVu on 10/12/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//
#import <EstimoteSDK/EstimoteSDK.h>
#import "AddItemViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"




@interface AddItemViewController ()<ESTBeaconManagerDelegate>

@property (nonatomic) ESTBeaconManager *beaconManager;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic)   AppDelegate *appDelegate;
@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     _appDelegate =(AppDelegate*) [UIApplication sharedApplication].delegate;
    self.labelMajor.text = nil;
    self.labelMinor.text = nil;
    

    //Init and set delegate for beaconManager
    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self;
    NSUUID *uuid = [[NSUUID alloc]
                    initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"regionAddbeacon"];
    [self.beaconManager requestAlwaysAuthorization];
    [_appDelegate setbackground:self.parentViewController.view];
    self.view.backgroundColor = [UIColor clearColor];
    self.imageItem.layer.cornerRadius = 5;
    self.imageItem.clipsToBounds = YES;
    
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void) viewDidAppear:(BOOL)animated{
    
    UIImage *image = [UIImage imageNamed:@"images.png"];
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.viewAnimation.frame.size.width/2-125, self.viewAnimation.frame.size.height/2 -125, 250,250)];
    imgView.image = image;
    
    CABasicAnimation* animation;
    animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 1;
    animation.repeatCount = MAXFLOAT;
    animation.fromValue = [NSNumber numberWithFloat:0.8];
    animation.toValue = [NSNumber numberWithFloat:0.1];
    [imgView.layer addAnimation:animation forKey:@"animateOpacity"];
    
    CABasicAnimation* animation1;
    animation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation1.duration = 1;
    animation1.repeatCount = MAXFLOAT;
    animation1.fromValue = [NSNumber numberWithFloat:1.0];
    animation1.toValue = [NSNumber numberWithFloat:1.6];
    [imgView.layer addAnimation:animation1 forKey:@"zoom"];
    
    //self.viewAnimation.center = self.view.center;
    
    [self.viewAnimation addSubview:imgView];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons
             inRegion:(CLBeaconRegion *)region {
    if(beacons.count >= 1){
        CLBeacon *nearestBeacon = beacons.firstObject;
        if (nearestBeacon.accuracy < 0.4 &&  nearestBeacon!= nil && nearestBeacon.accuracy >0) {
            NSLog(@"enterbeacon");
            self.labelMajor.text = [NSString stringWithFormat:@"%@", nearestBeacon.major];
            self.labelMinor.text = [NSString stringWithFormat:@"%@", nearestBeacon.minor];
            NSLog(@"%f", nearestBeacon.accuracy);
        }
        if(nearestBeacon.accuracy == -1)
        {
            
            
            self.labelMinor.text = nil;
            self.labelMajor.text = nil;
            
            
        }

        
    }
   }



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tapBtnDone:(id)sender {
    [self.view endEditing:YES];
    if (self.txtItemName.text==nil || [self.txtItemName.text  isEqual:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name item empty"
                                                        message:@"Please input name of Item"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
    else if(self.labelMajor.text != nil || self.labelMinor.text != nil)
    {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Adding";
        [hud show:YES];
        
       


    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    double longi = appDelegate.currentlocation.coordinate.longitude;
    double lat = appDelegate.currentlocation.coordinate.latitude;
    NSNumber *major= [NSNumber numberWithInt: [self.labelMajor.text intValue]];
    NSNumber *minor= [NSNumber numberWithInt: [self.labelMinor.text intValue]];
      PFUser *user = [PFUser currentUser];
    
    PFObject *item = [PFObject objectWithClassName:@"Item"];
    [item setObject:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D" forKey:@"UUID"];
    [item setObject: major forKey:@"Major"];
    [item setObject: minor forKey:@"Minor"];
    [item setObject: self.txtItemName.text forKey:@"ItemName"];
    [item setObject:[NSString stringWithFormat:@"%f",longi] forKey:@"Longitude"];
    [item setObject:[NSString stringWithFormat:@"%f",lat] forKey:@"Latitude"];
    [item setObject:user.objectId forKey:@"UserId"];
    [item setObject:[NSNumber numberWithBool:NO] forKey:@"IsLost" ];
    [item setObject:[NSNumber numberWithBool:NO] forKey:@"Notify" ];
    if(self.imageItem != nil)
    {
        NSData* data = UIImageJPEGRepresentation(self.imageItem.image, 0.5f);
        PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
        [item setObject:imageFile forKey:@"Image" ];
    }
    [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded)
        {            NSLog(@"Added Item");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                            message:@"Your Item has been added."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            

            [alert show];
            NSUUID *uuid = [[NSUUID alloc]
                            initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
            CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:self.txtItemName.text];
            [self.beaconManager startMonitoringForRegion:region];

            self.labelMinor.text = nil;
            self.labelMajor.text = nil;

            PFRelation *relation = [user relationForKey:@"listItem"];
            [relation addObject:item];
            [user saveInBackground];
            [hud hide:YES];
          
        }
        else{
            NSLog(@"%@",error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                            message: [NSString stringWithFormat:@"%@", error.localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
            self.labelMinor.text = nil;
            self.labelMajor.text = nil;
            [hud hide:YES];
        }
    }];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No beacon found"
                                                        message:@"You must place your beacon near your phone"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
 
}
- (IBAction)tapLoadImage:(id)sender {
    
          if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
          {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
          }
    

}

- (IBAction)tapselectImage:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];

}
#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageItem.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    

          
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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




@end
