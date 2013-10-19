//
//  SplashViewController.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/10/13.
//
//

#import <CoreLocation/CoreLocation.h>
#import "SplashViewController.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "APIManager.h"
#import "MainMenuViewController.h"


@implementation SplashViewController

-(void)viewDidLoad
{
    NSLog(@"view did load");
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocationReady:) name:kNotificationLocationReady object:nil];
}

-(void)onLocationReady:(NSNotification*)notification
{
    CLLocation *loc = (CLLocation*)notification.object;
    NSLog(@"Loc found! %@ %@",loc,self.managedObjectContext);
    
    APIManager *dm = [[APIManager alloc] init];
    dm.delegate = self;
    [dm fetchRegionDataForLocation:loc inMOC:self.managedObjectContext];
}

-(void)apiManager:(APIManager *)apiManager didCompleteWithClosestRegion:(Region *)region
{
    
    APIManager *dm = [[APIManager alloc] init];
    [dm fetchLocationData];
    
    MainMenuViewController *main = [[MainMenuViewController alloc] initWithRegion:region];
    [self.navigationController pushViewController:main animated:YES];
}

@end
