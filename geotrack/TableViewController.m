//
//  ViewController.m
//  geotrack
//
//  Created by James M. Shin on 8/20/13.
//  Copyright (c) 2013 James M. Shin. All rights reserved.
//

#import "TableViewController.h"


const int ROW_HEIGHT = 100;

@implementation GeoTagCell

@synthesize localityLabel;
@synthesize geoCoordLabel;
@synthesize dateLabel;
@synthesize batteryLabel;

@end


@interface TableViewController ()

@property (nonatomic, strong) NSArray *geoTagArray;  // holds PFObjects of GeoTag class

@end

@implementation TableViewController

@synthesize geoTagArray;
@synthesize mainTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.geoTagArray = @[@"hello"];
    
    // set title for navbar
    self.title = @"geotrack";
    
    // add refresh and sign out buttons to nav bar
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshButtonTap:)];
    self.navigationItem.rightBarButtonItem = barButton;
    
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(signOutButtonTap:)];
    self.navigationItem.leftBarButtonItem = barButton;

    self.navigationItem.hidesBackButton = YES;  // the back button is not necessary for this view
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User interaction handlers

- (void)refreshButtonTap:(id)sender
{
    // do stuff
}

- (void)signOutButtonTap:(id)sender
{
    // do stuff
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
    
    cell.localityLabel.text = [self.geoTagArray objectAtIndex:indexPath.row];
    
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
