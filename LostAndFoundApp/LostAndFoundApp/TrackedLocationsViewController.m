//
//  TrackedLocationsViewController.m
//  LostAndFoundApp
//
//  Created by HoangVu on 1/23/16.
//  Copyright © 2016 HoangVu. All rights reserved.
//

#import "TrackedLocationsViewController.h"
#import "TrackedPoint.h"
#import "NSDate+NVTimeAgo.h"
#import "AppDelegate.h"
@interface TrackedLocationsViewController ()
@property (nonatomic)   AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray* listTrackedPoint;

@end

@implementation TrackedLocationsViewController
@synthesize item;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    }
- (void)viewWillAppear:(BOOL)animated {
     _appDelegate =(AppDelegate*) [UIApplication sharedApplication].delegate;
    [self queryForTable];
    [self loadObjects];
    [self.tableView.layer setBorderColor:[UIColor redColor].CGColor];
    [_appDelegate setbackground:self.parentViewController.view];
    self.view.backgroundColor = [UIColor clearColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return self.listTrackedPoint.count;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"trackedPoint";
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"trackedPoint"];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:@"trackedPoint"];
    }
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    
    NSLog(@"%@", [object objectForKey:@"Major"]);
    //Get lastUpdate
    //Get lastUpdate
    UILabel *timeUpdateLabel = (UILabel*) [cell viewWithTag:2];
    NSDate *updated = [object updatedAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
    timeUpdateLabel.text = [updated formattedAsTimeAgo];
    
    //Get address
    //Get address
    
    double latitude = [[object objectForKey:@"Lat"] floatValue];
    double longitude = [[object objectForKey:@"Long"] floatValue];
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         UILabel *placeLabel = (UILabel*) [cell viewWithTag:1];
         placeLabel.numberOfLines = 0;
         placeLabel.text = locatedAt;
         
     }];
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.cornerRadius = 10;
    [cell.contentView.layer setBorderWidth:2.0f];
    return cell;
}




- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"TrackingHistory";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"Major";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        //self.objectsPerPage = 5;
    }
    return self;
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}


///Query syntax for tablecell
- (PFQuery *)queryForTable
{
    
    PFUser *myUser = [PFUser currentUser];
    PFQuery *query;
    
    query = [PFQuery queryWithClassName:self.parseClassName];
    
    
  
        
    [query whereKey:@"Major" equalTo:item.major];
    [query whereKey:@"Minor" equalTo:item.minor];

    
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnDeleteAll:(id)sender {
    
    UIAlertView *alert=  [[UIAlertView alloc] initWithTitle:@"Delete All Tracking"
                                                    message:  [NSString stringWithFormat: @"Do you want to delete all Tracking?"]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK"];
    alert.tag = 101;
    [alert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1 && alertView.tag == 101) {
        PFQuery *query = [PFQuery queryWithClassName:@"TrackingHistory"];
        [query whereKey:@"Major" equalTo:item.major];
        [query whereKey:@"Minor" equalTo:item.minor];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                //NSLog(@"Successfully retrieved %d scores.", objects.count);
                // Do something with the found objects
                [PFObject deleteAllInBackground:objects];
                [self queryForTable];
                [self loadObjects];
                [self.tableView reloadData];
                UIAlertView *alert=  [[UIAlertView alloc] initWithTitle:@"Delete Successful"
                                                                message:  [NSString stringWithFormat: @"All Trackings are deleted"]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];

                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

@end
