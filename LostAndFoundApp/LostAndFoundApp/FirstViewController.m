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
{
    UITextField* fakeTextField;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) ESTBeaconManager *beaconManager;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) double longi;
@property (nonatomic) double lati;
@property (nonatomic)   AppDelegate *appDelegate;
@property (nonatomic, assign) BOOL canSearch;




@end

@implementation FirstViewController

@synthesize searchBar;
@synthesize canSearch;


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
        //self.objectsPerPage = 5;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
    self.listener = [[Listener alloc] initWithCustomDisplay:@"SineWaveViewController"];
    [self.listener setDelegate:self];
    
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.appDelegate.locationManager startUpdatingLocation];
    

    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self;
    [self.beaconManager requestAlwaysAuthorization];
    NSUUID *uuid = [[NSUUID alloc]
                    initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid  identifier:@"updateInRegion"];
    [_appDelegate setbackground:self.parentViewController.view];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    fakeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    [fakeTextField setHidden:YES];
    [self.view addSubview:fakeTextField];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self queryForTable];
    [self loadObjects];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
     self.canSearch = 0;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [self clear];
    
    self.canSearch = 1;
    
    [self.searchBar resignFirstResponder];
    
    [self queryForTable];
    [self loadObjects];
    
}
-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        canSearch = 0;
        [self queryForTable];
        [self loadObjects];
        
    
    }
    else
    {
        canSearch = 1;
        
        //[self.searchedBar resignFirstResponder];
        
        [self queryForTable];
        [self loadObjects];
    }
    
}


#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}


///Query syntax for tablecell
- (PFQuery *)queryForTable
{
    
    PFUser *myUser = [PFUser currentUser];
    PFQuery *query;
    
    if (self.canSearch == 0) {
        query = [PFQuery queryWithClassName:self.parseClassName];
    } else {
        query = [PFQuery queryWithClassName:self.parseClassName];
        NSString *searchThis = [searchBar.text lowercaseString];
#warning key you wanted to search here
        [query whereKey:@"ItemName" containsString:searchThis];
    }
    
    if([myUser objectId] == nil)
    {
        
        [query whereKey:@"UserId" equalTo:@" "];
    }
    else{
        [query whereKey:@"UserId" equalTo: [myUser objectId]];
    }

    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    return query;
    
}




// - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
// {
//    if (searchResults == nil) {
//    return 0;
//    } else if ([searchResults count] == 0) {
//        return 1;
//    } else {
//        return [self.objects count];
//    }
// }
// 



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [searchBar resignFirstResponder];
    
    if ([self.objects count] == indexPath.row) {
        [self loadNextPage];
    } else {
        PFObject *photo = [self.objects objectAtIndex:indexPath.row];
        NSLog(@"%@", photo);
        
        // Do something you want after selected the cell
    }
}




#pragma mark - UIScrollViewDelegate


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}



-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"ItemCell";
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:@"ItemCell"];
    }

    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    
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
                [self queryForTable];
                [self loadObjects];
                [self.tableView reloadData];
               
            }
            
        }];
       
    }
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showItemDetail"]) {
        
        NSIndexPath *indexPath = nil;
        
        if ([self.searchDisplayController isActive]) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            
        } else{
            indexPath = [self.tableView indexPathForSelectedRow];
        }
        
        
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





#pragma mark - SpeechToTextModule Delegate -
- (BOOL)didReceiveVoiceResponse:(NSData *)data
{
    
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // handle responsesString:
    NSArray* arrayOfString = [responseString  componentsSeparatedByString:@"\""];
    if ([arrayOfString count] < 9) {
        [self.listener beginRecording];
        return NO;
    }
    NSLog(@"responseString: %@",arrayOfString[9]);
        canSearch = 1;
        
        //[self.searchedBar resignFirstResponder];
        searchBar.text = arrayOfString[9];
        [self queryForTable];
        [self loadObjects];
    return YES;
}
- (void)showSineWaveView:(SineWaveViewController *)view
{
    [fakeTextField setInputView:view.view];
    [fakeTextField becomeFirstResponder];
}
- (void)dismissSineWaveView:(SineWaveViewController *)view cancelled:(BOOL)wasCancelled
{
    [fakeTextField resignFirstResponder];
}
- (void)showLoadingView
{
    NSLog(@"show loadingView");
}
- (void)requestFailedWithError:(NSError *)error
{
    NSLog(@"error: %@",error);
}


- (IBAction)btnVoice:(id)sender {
    searchBar.text = nil;
    [self.listener beginRecording];
}
@end
