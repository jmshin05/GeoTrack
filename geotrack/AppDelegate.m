//
//  AppDelegate.m
//  geotrack
//
//  Created by James M. Shin on 8/20/13.
//  Copyright (c) 2013 James M. Shin. All rights reserved.
//

#import "AppDelegate.h"

const double KEEPALIVE_INTERVAL = 530.0;

@interface AppDelegate ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, strong) NSTimer *keepAliveTimer;  // timer to enable/disable geolocation so that time for background task resets
@property (nonatomic, strong) CLLocationManager *locationManager;

- (void)setupBackgroundTask:(UIApplication *)application;
- (void)keepAliveTimerFire:(id)sender;

@end

@implementation AppDelegate

@synthesize bgTask;
@synthesize keepAliveTimer;
@synthesize locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // set up Parse; no sign in, will be accessing data as anonymous user
    [Parse setApplicationId:@"KWeoW3oNZDsJ4O0jMKRtfWu1yeg1eHMAZFvE5TkH"
                  clientKey:@"6hwjRmqEHFIMNslPGioca7HXl4YpI2rSZK3oLaHp"];

    // Override point for customization after application launch.

    // initialize location manager
    // check for previous locationManager and stop
    if (application.applicationState == UIApplicationStateBackground) {
        if (self.locationManager) {
            [self.locationManager stopMonitoringSignificantLocationChanges];
            self.locationManager = nil;
        }
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        
        if (self.bgTask != UIBackgroundTaskInvalid) {
            [application endBackgroundTask:self.bgTask];
            self.bgTask = UIBackgroundTaskInvalid;
        }
        if (self.keepAliveTimer) {
            [self.keepAliveTimer invalidate];
            self.keepAliveTimer = nil;
            PFObject *testObject = [PFObject objectWithClassName:@"GeoTag"];
            [testObject setObject:@"keepAliveNotNil" forKey:@"foo"];
            [testObject save];
        }
        [self setupBackgroundTask:application];
    } else {
        self.bgTask = UIBackgroundTaskInvalid;
        self.keepAliveTimer = nil;
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    }

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [self setupBackgroundTask:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    // clean up background task
    if (self.bgTask != UIBackgroundTaskInvalid) {
        [self.locationManager stopMonitoringSignificantLocationChanges];
        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }

    // clean up keepAliveTimer
    if (self.keepAliveTimer) {
        [self.keepAliveTimer invalidate];
        self.keepAliveTimer = nil;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // activating significant location change monitoring will activate the app after reboot
    [self.locationManager startMonitoringSignificantLocationChanges];
}

#pragma mark - Background processing handlers
- (void)setupBackgroundTask:(UIApplication *)application
{
    // set up background processing
    self.bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
    
    [self.locationManager startUpdatingLocation];
    
    // setup keepAliveTimer to fire 15 seconds before the backgroundTimeRemaining expires
    self.keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:KEEPALIVE_INTERVAL target:self selector:@selector(keepAliveTimerFire:) userInfo:nil repeats:YES];
}

- (void)keepAliveTimerFire:(id)sender
{
    // start/stop locationManager to reset application.backgroundTimeRemaining
    [self.locationManager startUpdatingLocation];
    [self.locationManager stopUpdatingLocation];
    
    NSLog(@"%.2f",[UIApplication sharedApplication].backgroundTimeRemaining);
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // no need to do anything
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // no need to do anything
}

@end
