//
//  ViewController.h
//  geotrack
//
//  Created by James M. Shin on 8/20/13.
//  Copyright (c) 2013 James M. Shin. All rights reserved.
//

#import "Globals.h"

@interface GeoTagCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *localityLabel;
@property (nonatomic, weak) IBOutlet UILabel *geoCoordLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *batteryLabel;

@end

@interface TableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *mainTableView;  // table view to display GeoTag info

- (void)refreshButtonTap:(id)sender;

@end
