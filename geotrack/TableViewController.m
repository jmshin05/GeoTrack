//
//  ViewController.m
//  geotrack
//
//  Created by James M. Shin on 8/20/13.
//  Copyright (c) 2013 James M. Shin. All rights reserved.
//

#import "TableViewController.h"


@implementation GeoTagCell

@synthesize localityLabel;
@synthesize geoCoordLabel;
@synthesize dateLabel;
@synthesize batteryLabel;

@end


@interface TableViewController ()

@property (nonatomic, assign) BOOL isQuerying;  // flag for checking if refresh in progress
@property (nonatomic, assign) BOOL isNeedLocation;  // flag to prevent calling didUpdateLocations multiple times
@property (nonatomic, strong) NSMutableArray *geoTagArray;  // array of PFObjects of GeoTag class
@property (nonatomic, strong) PFQuery *geoTagQuery;  // array of PFObjects of GeoTag class
@property (nonatomic, strong) NSTimer *geoTagTimer;  // timer to record geolocation info, batter level, etc.
@property (nonatomic, strong) CLLocationManager *locationManager;  // core location object for getting geocoords
@property (nonatomic, strong) NSString *userID;  // hashed UDID


- (void)geoTagTimerFire:(id)sender;
- (void)refreshButtonTap:(id)sender;

@end

@implementation TableViewController

@synthesize isQuerying;
@synthesize isNeedLocation;
@synthesize geoTagArray;
@synthesize geoTagTimer;
@synthesize locationManager;
@synthesize userID;
@synthesize mainTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.geoTagArray = [NSMutableArray array];
    self.userID = md5hash([[UIDevice currentDevice] uniqueIdentifier]);
    
    // set up parse query for most recent geotags, up to MAX_QUERY_SIZE
    self.geoTagQuery = [PFQuery queryWithClassName:@"GeoTag"];
    [self.geoTagQuery whereKey:@"userID" equalTo:self.userID];
    [self.geoTagQuery orderByDescending:@"createdAt"];
    self.geoTagQuery.skip = 0;
    self.geoTagQuery.limit = MAX_QUERY_SIZE;
    self.isQuerying = YES;
    [self.geoTagQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            self.geoTagArray = [NSMutableArray arrayWithArray:objects];
        } else {
            // if no objects, geoTagArray will be empty better error handling needed here
            self.geoTagArray = [NSMutableArray array];
        }
        self.isQuerying = NO;
        [self.mainTableView reloadData];
    }];
    
    // set title for navbar
    self.title = @"geotrack";
    
    // add refresh button to nav bar
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshButtonTap:)];
    self.navigationItem.rightBarButtonItem = barButton;
    
    self.navigationItem.hidesBackButton = YES;  // the back button is not necessary for this view
    
    // setup geotracking
    // initialize location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.isNeedLocation = YES;
    [self.locationManager startUpdatingLocation];
    
    // setup timer for geotagging; 1 hour intervals
    self.geoTagTimer = [NSTimer scheduledTimerWithTimeInterval:GEOTAG_INTERVAL target:self selector:@selector(geoTagTimerFire:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Geotagging handlers

- (void)geoTagTimerFire:(id)sender
{
    self.isNeedLocation = YES;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    self.isNeedLocation = NO;  // prevent unwanted calls to didUpdateLocations
    
    if ([locations count] > 0) {
        // save geoTag to Parse
        CLLocation *location = [locations lastObject];
        CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];  // use reverse geocoding to get locality
        [reverseGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                PFObject *geoTag = [PFObject objectWithClassName:@"GeoTag"];
                [geoTag setObject:placemark.locality forKey:@"locality"];
                PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:location];
                [geoTag setObject:geoPoint forKey:@"geoPoint"];
                [geoTag setObject:[NSDate date] forKey:@"tagDate"];
                [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];  // enable battery monitoring temporarily
                [geoTag setObject:[NSNumber numberWithFloat:[UIDevice currentDevice].batteryLevel*100.0] forKey:@"batteryLevel"];
                [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
                // save UDID hash as well; must be hashed to adhere to Apple policy
                [geoTag setObject:self.userID forKey:@"userID"];
                [geoTag saveInBackground];  // need error handling; save to file and try uploading later
            }
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // add error handling; possibly add GeoTag to Parse with failed flag or reduce geotag time interval and try again sooner.
}

#pragma mark - User interaction handlers

- (void)refreshButtonTap:(id)sender
{
    if (!self.isQuerying) {
        self.isQuerying = YES;
        [self.geoTagQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects) {
                self.geoTagArray = [NSMutableArray arrayWithArray:objects];
            } else {
                // if no objects, geoTagArray will be empty better error handling needed here
                self.geoTagArray = [NSMutableArray array];
            }
            self.isQuerying = NO;
            [self.mainTableView reloadData];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.geoTagArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GeoTagCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GeoTagCell" forIndexPath:indexPath];
    
    PFObject *object = [self.geoTagArray objectAtIndex:indexPath.row];
    // show locality
    cell.localityLabel.text = [object objectForKey:@"locality"];
    // show coordinates
    PFGeoPoint *geoPoint = [object objectForKey:@"geoPoint"];
    cell.geoCoordLabel.text = [NSString stringWithFormat:@"%.5f, %.5f",geoPoint.latitude,geoPoint.longitude];
    // show date in local format
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy h:mm a"];
    NSDate *date = [object objectForKey:@"tagDate"];
    cell.dateLabel.text = [NSString stringWithFormat:@"Tagged on %@",[formatter stringFromDate:date]];
    // show battery level
    cell.batteryLabel.text = [NSString stringWithFormat:@"Battery Level: %.1f",[[object objectForKey:@"batteryLevel"] floatValue]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}
 */

@end
