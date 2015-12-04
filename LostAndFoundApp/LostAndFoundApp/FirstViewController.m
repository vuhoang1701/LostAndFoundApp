//
//  FirstViewController.m
//  LostAndFoundApp
//
//  Created by HoangVu on 10/8/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import "FirstViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <Parse/Parse.h>
#import "NSDate+NVTimeAgo.h"
#import "DetailViewController.h"
#import "Item.h"
#import "AppDelegate.h"
#import <EstimoteSDK/EstimoteSDK.h>


@interface FirstViewController ()<ESTBeaconManagerDelegate>
@property (nonatomic) ESTBeaconManager *beaconManager;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) double longi;
@property (nonatomic) double lati;
@property (nonatomic)   AppDelegate *appDelegate;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.appDelegate.locationManager startUpdatingLocation];
    

    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self;
    [self.beaconManager requestAlwaysAuthorization];
    NSUUID *uuid = [[NSUUID alloc]
                    initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid  identifier:@"updateInRegion"];
  
    // Remove table cell separator
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    
    // Assign our own backgroud for the view
    //self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"common_bg"]];
   self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ibecon.png"]];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    // Add padding to the top of the table view
    //UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
   // self.tableView.contentInset = inset;

    
}




// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *objectToDel = [self.objects objectAtIndex:indexPath.row];
        
        [objectToDel deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if(succeeded)
            {
            UIAlertView *Alert = [[UIAlertView alloc]  initWithTitle:@"Item Was Deleted Successfully" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,  nil];
            [Alert show];
            }
            
        }];
       
    }
}
-(void)refreshView {
    
    [self viewDidLoad];
    [self viewWillAppear:YES];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadObjects];

}

-(void) viewWillAppear:(BOOL)animated
{
      [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}


-(void) checkAndUpdate: (NSNumber*)major withMinor: (NSNumber*) minor
{
    PFQuery *getItem = [PFQuery queryWithClassName:@"Item"];
    [getItem whereKey:@"Major" equalTo: major];
    [getItem whereKey:@"Minor" equalTo: minor];
    [getItem whereKey:@"UserId" equalTo: [PFUser currentUser].objectId];
    //NSError *error ;
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:getItem,nil]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object,NSError* error) {
        if (!object) {
            // Did not find any UserStats for the current user
            //NSLog(@"Item isn't lost");
        } else {
          
            self.longi = self.appDelegate.currentlocation.coordinate.longitude;
            self.lati = self.appDelegate.currentlocation.coordinate.latitude;
            [object setObject:[NSString stringWithFormat:@"%f",self.longi] forKey:@"Longitude"];
            [object setObject:[NSString stringWithFormat:@"%f",self.lati] forKey:@"Latitude"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded)
                {
                    NSLog(@"Location details are update");
                  [self.appDelegate.locationManager stopUpdatingLocation];
                }
            }];
            
        }
        if (error) {
            NSLog(@"%@", error);
        }
        
    }];
   }

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons
             inRegion:(CLBeaconRegion *)region {
    for(id item in beacons)
    {
        CLBeacon *nearestBeacon = item;
        if (nearestBeacon!= nil && nearestBeacon.accuracy != -1) {
            [self checkAndUpdate:nearestBeacon.major withMinor:nearestBeacon.minor];
            
                   }
        
    }
    
}


//Load Cell
- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *simpleTableIdentifier = @"ItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
   
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
    
    //Get image file
    PFFile *thumbnail = [object objectForKey:@"Image"];
    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:3];
    thumbnailImageView.image = [UIImage imageNamed:@"images.jpeg"];
    thumbnailImageView.file = thumbnail;
    thumbnailImageView.layer.cornerRadius = 10;
    thumbnailImageView.clipsToBounds = YES;
    [thumbnailImageView loadInBackground];
    
    //Get Item bame
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:1];
    nameLabel.text = [object objectForKey:@"ItemName"];
    
    
    //Get lastUpdate
    UILabel *timeUpdateLabel = (UILabel*) [cell viewWithTag:4];
    NSDate *updated = [object updatedAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
    timeUpdateLabel.text = [updated formattedAsTimeAgo];
    
    
    //Get address

    double latitude = [[object objectForKey:@"Latitude"] floatValue];
    double longitude = [[object objectForKey:@"Longitude"] floatValue];
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         UILabel *placeLabel = (UILabel*) [cell viewWithTag:2];
         placeLabel.text = locatedAt;
         
     }];
//    UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
//    
//    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
//    cellBackgroundView.image = background;
    //cell.backgroundView = cellBackgroundView;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UIImage *)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    UIImage *background = nil;
    
    if (rowIndex == 0) {
        background = [UIImage imageNamed:@"cell_top.png"];
    } else if (rowIndex == rowCount - 1) {
        background = [UIImage imageNamed:@"cell_bottom.png"];
    } else {
        background = [UIImage imageNamed:@"cell_middle.png"];
    }
    
    return background;
}


- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Item";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"ItemName";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
    }
    return self;
}


///Query syntax for tablecell
- (PFQuery *)queryForTable
{
    
    PFUser *myUser = [PFUser currentUser];
     PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    if([myUser objectId] == nil)
    {
       
        [query whereKey:@"UserId" equalTo:@" "];
    }
        else{
            [query whereKey:@"UserId" equalTo: [myUser objectId]];
        }
   
    return query;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showItemDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailViewController *destViewController = segue.destinationViewController;
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        Item *item = [[Item alloc] init];
        item.UUID = [object objectForKey:@"UIID"];
        item.minor = [object objectForKey:@"Minor"];
        item.major = [object objectForKey:@"Major"];
        item.name = [object objectForKey:@"ItemName"];
        item.userId = [object objectForKey:@"UserId"];
        item.longitude = [object objectForKey:@"Longitude"];
        item.latitude = [object objectForKey:@"Latitude"];
        item.isLost = [[object objectForKey:@"IsLost"] boolValue];
        item.notify = [[object objectForKey:@"Notify"] boolValue];
        item.imageFile = [object objectForKey:@"Image"];
        NSDate *updated = [object updatedAt];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
        item.lastUpdate = [updated formattedAsTimeAgo];
        destViewController.item = item;
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}





@end
