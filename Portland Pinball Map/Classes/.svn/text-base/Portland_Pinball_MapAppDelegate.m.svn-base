//
//  Portland_Pinball_MapAppDelegate.m
//  Portland Pinball Map
//
//  Created by Isaac on 11/12/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "Portland_Pinball_MapAppDelegate.h"
#import "RootViewController.h"

@implementation Portland_Pinball_MapAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize allMachines;
@synthesize allLocations;
@synthesize locationProfileView;
@synthesize splashScreen;
@synthesize locationMap;
@synthesize showUserLocation;
@synthesize rootURL;
@synthesize activeRegion;
@synthesize regions;
@synthesize userLocation;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	
	userLocation = [[CLLocation alloc] initWithLatitude:45.52295 longitude:-122.66785];
	
	// Override point for customization after app launch 
	navigationController.navigationBar.barStyle = UIBarStyleBlack;	
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
	
	//[self showSplashScreen];
	
	/*UILabel *version = [[[UILabel alloc] init] autorelease];
	//version.text = @"0.3.4";
	version.text = @" ";
	version.textAlignment = UITextAlignmentRight;
	version.font = [UIFont fontWithName:@"Helvetica" size:12];
	version.frame = CGRectMake(0,480 - 12 - 13,320,12);
	version.textColor = [UIColor whiteColor];
	version.backgroundColor = [UIColor clearColor];
	
	[splashScreen addSubview:img];
	[splashScreen addSubview:img2];
	[splashScreen addSubview:version];
	[window addSubview:splashScreen];*/
	
	[self showSplashScreen];
}

-(void)showSplashScreen
{
	[self hideSplashScreen];
	
	NSLog(@"-> Show Splash Screen");
	NSLog(@"activeRegion %@:",activeRegion);
	
	splashScreen = [[UIView alloc] init];
	splashScreen.userInteractionEnabled = NO;
	
	UIImageView *pbm       = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pbm2.png"]] autorelease];
	UIImageView *base      = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"base_blank.png"]] autorelease];
	base.frame  = CGRectMake(0,20,320,460);
	
	if(activeRegion == nil)
	{
		//pbm.frame = CGRectMake(0,-10,320,460);
		[splashScreen addSubview:base];
		//[splashScreen addSubview:pbm];
	}
	else
	{
		
		NSString *splash_id = [NSString stringWithString:activeRegion.subdir];
		NSString    *imageName = [NSString stringWithFormat:@"%@_splash.png",splash_id];
		UIImageView *region    = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]] autorelease];
		
		
		NSArray *availableRegions = [[NSArray alloc] initWithObjects:@"",@"albuquerque",@"austin",@"bayarea",@"bc",@"boston", @"chicago",@"detroit",@"la", @"lasvegas",@"toronto",@"newyork", @"sandiego",@"seattle",nil];
		
		
		if([availableRegions containsObject:splash_id])
		{
			region.frame = CGRectMake(0,20,320,460);
			pbm.frame = CGRectMake(0,20,320,460);
			
			[splashScreen addSubview:base];
			[splashScreen addSubview:pbm];
			[splashScreen addSubview:region];
			
		}
		else
		{
			pbm.frame = CGRectMake(0,-10,320,460);
			[splashScreen addSubview:base];
			[splashScreen addSubview:pbm];
		}
		
		[availableRegions release];
	}

	[window addSubview:splashScreen];
	
}

-(void)hideSplashScreen
{
	NSLog(@"-> Hide Splash Screen");
	if(splashScreen != nil)
	{
		if(splashScreen.superview != nil)
			[splashScreen removeFromSuperview];
		
		splashScreen = nil;
		[splashScreen release];
	}
}

-(void)updateLocationDistances
{
	if([activeRegion.locations count] > 0)
	{
		for ( id key in activeRegion.locations)
		{
			LocationObject *loc = [activeRegion.locations objectForKey:key];
			[loc updateDistance];
		}
	}	
}

-(void) newActiveRegion:(RegionObject*)reobj
{
	
	NSString *baseURL = @"http://scottwainstock.com/ryandev/";
	//NSString *baseURL = @"http://pinballmap.com/";
	
	activeRegion = reobj;
	
	if (rootURL != nil)
	{
		[rootURL release];
		rootURL = nil;
	}
	rootURL = [[NSString alloc] initWithFormat:@"%@%@/iphone.html?",baseURL,activeRegion.subdir];
}

-(void) showMap:(NSArray*)array withTitle:(NSString *)newTitle
{
	
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	//NSLog(@"Get Me Out of Here!");
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	[userLocation release];
	[regions release];
	[activeRegion release];
	[regions release];
	[rootURL release];
	[locationMap release];
	[splashScreen release];
	[locationProfileView release];
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

