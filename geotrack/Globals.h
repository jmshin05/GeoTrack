//
//  Globals.h
//  geotrack
//
//  Created by James M. Shin on 8/20/13.
//  Copyright (c) 2013 James M. Shin. All rights reserved.
//

#ifndef _GLOBALS   // check if Globals.h has already been linked
#define _GLOBALS   // define _GLOBALS so that Globals.h is not linked again

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

extern const double KEEPALIVE_INTERVAL;
extern const double GEOTAG_INTERVAL;
extern const int ROW_HEIGHT;
extern const int MAX_QUERY_SIZE;


NSString *md5hash(NSString *str);

#endif  // end #ifndef _GLOBALS