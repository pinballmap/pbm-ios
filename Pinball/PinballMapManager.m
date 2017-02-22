
//  PinballMapManager.m
//  PinballMap
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "PinballMapManager.h"
#import "NSFileManager+DocumentsDirectory.h"
#import "AFNetworking.h"
#import "NSDate+CupertinoYankee.h"

static const NSString *apiRootURL = @"https://pinballmap.com/";

NSString * const motdKey = @"motd";
NSString * const motdRegionKey = @"region_id";
NSString * const appGroup = @"group.com.pbm";

typedef NS_ENUM(NSInteger, PBMDataAPI) {
    PBMDataAPIRegions = 0,
    PBMDataAPIMachines,
    PBMDataAPILocationTypes,
    PBMDataAPILocations,
    PBMDataAPIEvents,
    PBMDataAPIZones,
    PBMDataAPIOperators
};


@interface PinballMapManager () <CLLocationManagerDelegate>

@property (nonatomic) NSURLSession *session;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSMutableArray *apiOperations;

@end


@implementation PinballMapManager

+ (NSString *)getApiRootURL {
    return apiRootURL;
}

+ (NSString *)apiQueryWithLoginCredentials:(NSString *)query {
    User *currentUser = [[PinballMapManager sharedInstance] currentUser];
    
    NSLog(@"MASSAGED QUERY: %@", [NSString stringWithFormat:@"%@?user_token=%@;user_email=%@", query, currentUser.token, currentUser.email]);
    return [NSString stringWithFormat:@"%@?user_token=%@;user_email=%@", query, currentUser.token, currentUser.email];
}

+ (id)sharedInstance{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p,^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}
+ (NSUserDefaults *)userDefaultsForApp{
    return [[NSUserDefaults alloc] initWithSuiteName:appGroup];
}
- (void)migrateUserDefaults{
    NSNumber *shouldMigrate = [[PinballMapManager userDefaultsForApp] objectForKey:@"shouldMigrate"];
    if (![shouldMigrate isEqualToNumber:@(-1)]){
        // Pull over current settings
        id region = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentRegion"];
        [[PinballMapManager userDefaultsForApp] setObject:region forKey:@"CurrentRegion"];
        NSDate *lastShownDate = [[NSUserDefaults standardUserDefaults] objectForKey:motdKey];
        [[PinballMapManager userDefaultsForApp] setObject:lastShownDate forKey:motdKey];
        NSNumber *regionID = [[NSUserDefaults standardUserDefaults] objectForKey:motdRegionKey];
        [[PinballMapManager userDefaultsForApp] setObject:regionID forKey:motdRegionKey];
        id user = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentUser"];
        [[PinballMapManager userDefaultsForApp] setObject:user forKey:@"CurrentUser"];
        // No longer need to migrate
        [[PinballMapManager userDefaultsForApp] setObject:@(-1) forKey:@"shouldMigrate"];
        [[PinballMapManager userDefaultsForApp] synchronize];
    }
}
- (id)init{
    self = [super init];
    if (self){
        self.apiOperations = [[NSMutableArray alloc] init];
        [self getUserLocation];
        self.session = [NSURLSession sharedSession];
        [self migrateUserDefaults];
        _regionInfo = [[PinballMapManager userDefaultsForApp] objectForKey:@"CurrentRegion"];
        _userInfo = [[PinballMapManager userDefaultsForApp] objectForKey:@"CurrentUser"];

        if (_regionInfo){
            NSFetchRequest *regionRequest = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
            regionRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@",_regionInfo[@"name"]];
            regionRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES]];
            NSManagedObjectContext *context = [[CoreDataManager sharedInstance] managedObjectContext];
            NSArray *results = [context executeFetchRequest:regionRequest error:nil];
            if (results.count == 1){
                _currentRegion = results[0];
            }else{
                _currentRegion = [self regionWithData:@{@"full_name":@"Seattle",@"id":@3,@"lat":@48,@"lon":@(-122),@"name":@"seattle",@"primary_email_contact":@"morganshilling@gmail.com"} shouldCreate:YES];
                [self loadRegionData:_currentRegion];
            }
        }
        
        if (_userInfo) {
            NSFetchRequest *userRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
            userRequest.predicate = [NSPredicate predicateWithFormat:@"username = %@", _userInfo[@"username"]];
            NSManagedObjectContext *userContext = [[CoreDataManager sharedInstance] managedObjectContext];
            NSArray *userResults = [userContext executeFetchRequest:userRequest error:nil];
            
            if (userResults.count > 0) {
                _currentUser = userResults[0];
            }
        }
    }
    
    return self;
}
- (void)getUserLocation{
    if (!self.locationManager){
        self.locationManager = [CLLocationManager new];
    }
    // iOS 8 Support for location updating
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways){
        [self.locationManager requestAlwaysAuthorization];
    }
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 5;
    [self.locationManager startUpdatingLocation];
}
- (BOOL)shouldShowMessageOfDay{
    NSDate *lastShownDate = [[PinballMapManager userDefaultsForApp] objectForKey:motdKey];
    if (!lastShownDate){
        return YES;
    }
    NSNumber *regionID = [[PinballMapManager userDefaultsForApp] objectForKey:motdRegionKey];
    BOOL shouldShowForDate = ![[[NSDate date] endOfDay] isEqualToDate:lastShownDate];
    if (!shouldShowForDate){
        if (regionID != self.currentRegion.regionId){
            return YES;
        }else{
            return NO;
        }
    }
    return YES;
}
- (void)showedMessageOfDay{
    [[PinballMapManager userDefaultsForApp] setObject:self.currentRegion.regionId forKey:motdRegionKey];
    [[PinballMapManager userDefaultsForApp] setObject:[[NSDate date] endOfDay] forKey:motdKey];
    [[PinballMapManager userDefaultsForApp] synchronize];
}
#pragma mark - Regions listing
- (void)allRegions:(void (^)(NSArray *regions))regionBlock{
    NSArray *currentRegions = [self coreDataRegions];
    
    if (currentRegions.count > 0){
        regionBlock(currentRegions);
    }
    
    NSMutableArray *regionIds = [NSMutableArray new];
    [currentRegions enumerateObjectsUsingBlock:^(Region *obj, NSUInteger idx, BOOL *stop) {
        [regionIds addObject:obj.regionId];
    }];
    currentRegions = nil;
    NSURLRequest *regionRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[PinballMapManager apiQueryWithLoginCredentials:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/regions.json",apiRootURL]]]]];
    AFHTTPRequestOperation *regionAPI = [[AFHTTPRequestOperation alloc] initWithRequest:regionRequest];
    regionAPI.responseSerializer = [AFJSONResponseSerializer serializer];
    [regionAPI setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *regions = operation.responseObject[@"regions"];
        [regions enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            if (![regionIds containsObject:obj[@"id"]]){
                [Region createRegionWithData:obj andContext:[[CoreDataManager sharedInstance] managedObjectContext]];
            }
        }];
        [[CoreDataManager sharedInstance] saveContext];

        regionBlock([self coreDataRegions]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:regionAPI];
}
- (void)refreshAllRegions{
    NSArray *currentRegions = [self coreDataRegions];

    NSMutableArray *regionNames = [NSMutableArray new];
    [currentRegions enumerateObjectsUsingBlock:^(Region *obj, NSUInteger idx, BOOL *stop) {
        [regionNames addObject:obj.name];
    }];
    currentRegions = nil;
    NSURLRequest *regionRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[PinballMapManager apiQueryWithLoginCredentials:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/regions.json",apiRootURL]]]]];
    AFHTTPRequestOperation *regionAPI = [[AFHTTPRequestOperation alloc] initWithRequest:regionRequest];
    regionAPI.responseSerializer = [AFJSONResponseSerializer serializer];
    [regionAPI setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *regions = operation.responseObject[@"regions"];
        
        for (NSDictionary *region in regions) {
            if (![regionNames containsObject:region[@"name"]]){
                [Region createRegionWithData:region andContext:[[CoreDataManager sharedInstance] managedObjectContext]];
            }else{
                // Remove any existing IDs the server responded with
                // so that once we are done we can remove any local regions that
                // no longer exist on the server
                [regionNames removeObject:region[@"name"]];
            }
        }
        // Code to remove regions that still exist after
        // processing.
        NSArray *currentRegions = [self coreDataRegions];
        for (NSString *regionName in regionNames) {
            for (Region *existingRegion in currentRegions) {
                if ([regionName isEqual:existingRegion.name]){
                    [[[CoreDataManager sharedInstance] managedObjectContext] deleteObject:existingRegion];
                }
            }
        }
        
        [[CoreDataManager sharedInstance] saveContext];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshedRegions" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:regionAPI];
}
- (void)cancelAllLoadingOperations{
    if (self.apiOperations.count > 0){
        for (AFHTTPRequestOperation *operation in self.apiOperations) {
            [operation cancel];
        }
        [self.apiOperations removeAllObjects];
    }
}

#pragma mark - Region Data Load
- (void)refreshRegion{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatingRegion" object:nil];
    [self.apiOperations removeAllObjects];
    [self.apiOperations addObjectsFromArray:@[[self requestForData:PBMDataAPIMachines],[self requestForData:PBMDataAPILocationTypes],[self requestForData:PBMDataAPIZones],[self requestForData:PBMDataAPIOperators],[self requestForData:PBMDataAPILocations],[self requestForData:PBMDataAPIEvents]]];

    NSArray *api = [AFURLConnectionOperation batchOfRequestOperations:self.apiOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"Completed %lu of %lu",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
        NSDictionary *progress = @{
                                   @"completed": [NSNumber numberWithLongLong:numberOfFinishedOperations],
                                   @"total": [NSNumber numberWithLongLong:totalNumberOfOperations]
                                   };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatingProgress" object:progress];
    } completionBlock:^(NSArray *operations) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatingProgress" object:nil];
        });
        BOOL canceledRequests = false;
        for (AFHTTPRequestOperation *operation in operations) {
            if (operation.isCancelled){
                canceledRequests = true;
            }
        }
        NSLog(@"Did cancel: %i",canceledRequests);
        if (!canceledRequests){
            NSLog(@"Started proccessing");
            __block NSMutableSet *createdMachines;
            __block NSMutableSet *createdLocationTypes;
            __block NSMutableSet *createdZones;
            __block NSMutableSet *createdOperators;
            __block NSMutableSet *createdLocations;
            [operations enumerateObjectsUsingBlock:^(AFHTTPRequestOperation *obj, NSUInteger idx, BOOL *stop) {
                if (idx == 0){
                    createdMachines = [self importMachinesWithRequest:obj];
                }else if (idx == 1){
                    createdLocationTypes = [self importLocationTypesWithRequest:obj];
                }else if (idx == 2){
                    createdZones = [self importZonesWithRequest:obj];
                }else if (idx == 3){
                    createdOperators = [self importOperatorsWithRequest:obj];
                }else if (idx == 4){
                    createdLocations = [self importLocationsWithRequest:obj andMachines:createdMachines andLocationTypes:createdLocationTypes andZones:createdZones andOperators:createdOperators];
                }else if (idx == 5){
                    [self importEventsWithRequest:obj andLocations:createdLocations];
                }
                [[CoreDataManager sharedInstance] saveContext];
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.apiOperations removeAllObjects];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionUpdate" object:nil];
            NSLog(@"Ended proccessing");
        });
    }];
    [[NSOperationQueue mainQueue] addOperations:api waitUntilFinished:NO];
}
- (void)refreshBasicRegionData:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:[PinballMapManager apiQueryWithLoginCredentials:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/regions/%@.json",apiRootURL,self.currentRegion.regionId]]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         completionBlock(@{@"errors": error.localizedDescription});
     }];
}
- (void)deleteAllEntities:(NSString *)entityName{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSError *error;
    NSArray *fetchedObjects = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObjects) {
        [[[CoreDataManager sharedInstance] managedObjectContext] deleteObject:object];
    }
    
    [[CoreDataManager sharedInstance] saveContext];
}
- (void)loadRegionData:(Region *)region{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatingRegion" object:nil];

    [[PinballMapManager userDefaultsForApp] setObject:@{@"name": region.name} forKey:@"CurrentRegion"];
    [[PinballMapManager userDefaultsForApp] synchronize];
    
    _currentRegion = region;
    
    NSArray *apiOperations = @[[self requestForData:PBMDataAPIMachines],[self requestForData:PBMDataAPILocationTypes],[self requestForData:PBMDataAPIZones],[self requestForData:PBMDataAPIOperators],[self requestForData:PBMDataAPILocations],[self requestForData:PBMDataAPIEvents]];
    
    NSArray *api = [AFURLConnectionOperation batchOfRequestOperations:apiOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"Completed %lu of %lu",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatingProgress" object:nil];
        });
        NSLog(@"Started proccessing");
        __block NSMutableSet *createdMachines;
        __block NSMutableSet *createdLocationTypes;
        __block NSMutableSet *createdZones;
        __block NSMutableSet *createdOperators;
        __block NSMutableSet *createdLocations;
        [operations enumerateObjectsUsingBlock:^(AFHTTPRequestOperation *obj, NSUInteger idx, BOOL *stop) {
            if (idx == 0){
                createdMachines = [self importMachinesWithRequest:obj];
            }else if (idx == 1){
                createdLocationTypes = [self importLocationTypesWithRequest:obj];
            }else if (idx == 2){
                createdZones = [self importZonesWithRequest:obj];
            }else if (idx == 3){
                createdOperators = [self importOperatorsWithRequest:obj];
            }else if (idx == 4){
                createdLocations = [self importLocationsWithRequest:obj andMachines:createdMachines andLocationTypes:createdLocationTypes andZones:createdZones andOperators:createdOperators];
            }else if (idx == 5){
                [self importEventsWithRequest:obj andLocations:createdLocations];
            }
            [[CoreDataManager sharedInstance] saveContext];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionUpdate" object:nil];
        });

        [self loadUserData:self.currentUser];
        NSLog(@"Finished proccessing");
    }];
    [[NSOperationQueue mainQueue] addOperations:api waitUntilFinished:NO];
}
- (void)loadUserData:(User *)user{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatingUser" object:nil];

    [[PinballMapManager sharedInstance] loadUserProfileData:user andCompletion:^(NSDictionary *status) {
        if (status[@"errors"]) {
            NSString *errors;
            if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                errors = [status[@"errors"] componentsJoinedByString:@","];
            }else{
                errors = status[@"errors"];
            }
        } else {
            CoreDataManager *cdManager = [CoreDataManager sharedInstance];

            user.numLocationsSuggested = [status[@"profile_info"][@"num_locations_suggested"] stringValue];
            user.numMachinesRemoved = [status[@"profile_info"][@"num_machines_removed"] stringValue];
            user.numLocationsEdited = [status[@"profile_info"][@"num_locations_edited"] stringValue];
            user.numMachinesAdded = [status[@"profile_info"][@"num_machines_added"] stringValue];
            user.numCommentsLeft = [status[@"profile_info"][@"num_lmx_comments_left"] stringValue];
            
            if (![status[@"profile_info"][@"created_at"] isKindOfClass:[NSNull class]]){
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"YYYY-MM-dd"];
                
                NSString *createdString = status[@"profile_info"][@"created_at"];
                createdString = [createdString substringToIndex:[createdString rangeOfString:@"T"].location];
                user.dateCreated = [df dateFromString:createdString];
            }
            
            [self.currentUser.userProfileEditedLocations enumerateObjectsUsingBlock:^(UserProfileEditedLocation *obj, BOOL *stop) {
                [cdManager.managedObjectContext deleteObject:obj];
            }];
            
            [self.currentUser.userProfileHighScores enumerateObjectsUsingBlock:^(UserProfileHighScore *obj, BOOL * stop) {
                [cdManager.managedObjectContext deleteObject:obj];
            }];
            
            [cdManager saveContext];
            
            NSArray *editedLocations = status[@"profile_info"][@"profile_list_of_edited_locations"];
            if (![editedLocations isKindOfClass:[NSNull class]]) {
                for (int i = 0; i < [editedLocations count]; i++) {
                    NSNumber *regionId = editedLocations[i][2];
                    
                    if (regionId == self.currentRegion.regionId) {
                        UserProfileEditedLocation *location = [NSEntityDescription insertNewObjectForEntityForName:@"UserProfileEditedLocation" inManagedObjectContext:cdManager.managedObjectContext];
                        
                        NSNumber *locationId = editedLocations[i][0];
                        NSFetchRequest *locationFetch = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
                        locationFetch.predicate = [NSPredicate predicateWithFormat:@"locationId = %@",locationId];
                        locationFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
                        NSArray *foundLocations = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:locationFetch error:nil];
                        if (foundLocations.count == 1){
                            location.location = [foundLocations firstObject];
                        }
                        
                        NSFetchRequest *regionFetch = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
                        regionFetch.predicate = [NSPredicate predicateWithFormat:@"regionId = %@",regionId];
                        regionFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
                        NSArray *foundRegions = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:regionFetch error:nil];
                        if (foundRegions.count == 1){
                            location.region = [foundRegions firstObject];
                        }
                        
                        location.locationId = locationId;
                        location.regionId = regionId;
                        location.userId = user.userId;
                        location.user = user;
                    }
                }
            }
            
            NSArray *highScores = status[@"profile_info"][@"profile_list_of_high_scores"];
            if (![highScores isKindOfClass:[NSNull class]]) {
                for (int i = 0; i < [highScores count]; i++) {
                    UserProfileHighScore *score = [NSEntityDescription insertNewObjectForEntityForName:@"UserProfileHighScore" inManagedObjectContext:cdManager.managedObjectContext];
                    score.locationName = highScores[i][0];
                    score.machineName = highScores[i][1];
                    score.score = highScores[i][2];
                    
                    NSDateFormatter* myFormatter = [[NSDateFormatter alloc] init];
                    [myFormatter setDateFormat:@"MM-dd-yyyy"];
                    score.dateCreated = [myFormatter dateFromString:highScores[i][3]];
                    score.user = user;
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedIn" object:nil];
        }
    }];
    
    [[PinballMapManager userDefaultsForApp] setObject:@{@"username": user.username} forKey:@"CurrentUser"];
    [[PinballMapManager userDefaultsForApp] synchronize];
    
     _currentUser = user;
    
    [[CoreDataManager sharedInstance] saveContext];
}

- (void)loadUserProfileData:(User *)user andCompletion:(APIComplete)completionBlock{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatingUserProfileInfo" object:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *userProfileQuery = [PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/users/%@/profile_info.json",apiRootURL,[user.userId stringValue]]];
    
    [manager GET:userProfileQuery parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}

- (void)recentlyAddedMachinesWithCompletion:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *parameters = @{@"limit": @"25"};

    [manager GET:[PinballMapManager apiQueryWithLoginCredentials:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/region/%@/location_machine_xrefs.json",apiRootURL,self.currentRegion.name]]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}
- (void)nearestLocationWithLocation:(CLLocation *)location andCompletion:(APIComplete)completionBlock{
    CLLocation *userLocation;
    if (location == nil){
        userLocation = self.userLocation;
    }else{
        userLocation = location;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:[PinballMapManager apiQueryWithLoginCredentials:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/locations/closest_by_lat_lon.json?lat=%@&lon=%@",apiRootURL,[@(userLocation.coordinate.latitude) stringValue],[@(userLocation.coordinate.longitude) stringValue]]]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}
- (AFHTTPRequestOperation *)requestForData:(PBMDataAPI)apiType{
    NSURL *apiURL;
    switch (apiType) {
        case PBMDataAPIRegions:
            apiURL = [NSURL URLWithString:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/regions.json",apiRootURL]]];
            break;
        case PBMDataAPIMachines:
            apiURL = [NSURL URLWithString:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/machines.json",apiRootURL]]];
            break;
        case PBMDataAPILocationTypes:
            apiURL = [NSURL URLWithString:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/location_types.json",apiRootURL]]];
            break;
        case PBMDataAPILocations:
            apiURL = [NSURL URLWithString:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/region/%@/locations.json",apiRootURL,_currentRegion.name]]];
            break;
        case PBMDataAPIEvents:
            apiURL = [NSURL URLWithString:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/region/%@/events.json",apiRootURL,_currentRegion.name]]];
            break;
        case PBMDataAPIZones:
            apiURL = [NSURL URLWithString:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/region/%@/zones.json",apiRootURL,_currentRegion.name]]];
            break;
        case PBMDataAPIOperators:
            apiURL = [NSURL URLWithString:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/region/%@/operators.json",apiRootURL,_currentRegion.name]]];
            break;
        default:
            break;
    }
    NSURLRequest *apiRequest = [NSURLRequest requestWithURL:apiURL];
    AFHTTPRequestOperation *apiOperation = [[AFHTTPRequestOperation alloc] initWithRequest:apiRequest];
    apiOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    return apiOperation;
}
#pragma mark - Region Model Interaction
- (NSArray *)coreDataRegions{
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];
    NSFetchRequest *regionsFetch = [self fetchRequestForModel:@"Region"];
    regionsFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES]];
    NSArray *regions = [cdManager.managedObjectContext executeFetchRequest:regionsFetch error:nil];
    
    return regions;
}
// Will look for a region with the given name. If one does not exist it will create it and return it.
- (Region *)regionWithData:(NSDictionary *)region shouldCreate:(BOOL)create{
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];
    NSFetchRequest *regionRequest = [self fetchRequestForModel:@"Region"];
    regionRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@",region[@"name"]];
    regionRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSArray *foundRegions = [cdManager.managedObjectContext executeFetchRequest:regionRequest error:nil];
    Region *foundRegion;
    if (foundRegions.count == 0 && create){
        // Create region
        foundRegion = [Region createRegionWithData:region andContext:cdManager.managedObjectContext];
        [cdManager saveContext];
    }else{
        foundRegion = [foundRegions lastObject];
    }
    return foundRegion;
}

- (void)clearData:(PBMDataAPI)dataType forRegion:(Region *)region{
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];
    if (dataType == PBMDataAPILocations){
        [region.locations enumerateObjectsUsingBlock:^(Location *obj, BOOL *stop) {
            [cdManager.managedObjectContext deleteObject:obj];
        }];
    }else if (dataType == PBMDataAPIEvents){
        [region.events enumerateObjectsUsingBlock:^(Event *obj, BOOL *stop) {
            [cdManager.managedObjectContext deleteObject:obj];
        }];
    }else if (dataType == PBMDataAPIZones){
        [region.zones enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            [cdManager.managedObjectContext deleteObject:obj];
        }];
    }
    [cdManager saveContext];
}
#pragma mark - CoreData import
- (NSMutableSet *)importMachinesWithRequest:(AFHTTPRequestOperation *)request{
    
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];
    // All current machine ids.
    NSFetchRequest *machineFetch = [self fetchRequestForModel:@"Machine"];
    NSArray *machinesExisting = [[cdManager managedObjectContext] executeFetchRequest:machineFetch error:nil];
    NSMutableArray *existingMachineIds = [NSMutableArray new];
    [machinesExisting enumerateObjectsUsingBlock:^(Machine *obj, NSUInteger idx, BOOL *stop) {
        [existingMachineIds addObject:obj.machineId];
    }];
    machinesExisting = nil;
    machineFetch = nil;
    // Create all machines.
    [request.responseObject[@"machines"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *machineData = obj;
        if (![existingMachineIds containsObject:machineData[@"id"]]){
            [Machine createMachineWithData:machineData andContext:cdManager.managedObjectContext];
        }
    }];
    [cdManager saveContext];
    NSMutableSet *machines = [NSMutableSet new];
    if (machines.count == 0){
        // No new machines so pull them all from CoreData
        NSFetchRequest *machineFetch = [self fetchRequestForModel:@"Machine"];
        NSArray *machinesExisting = [[cdManager managedObjectContext] executeFetchRequest:machineFetch error:nil];
        [machines addObjectsFromArray:machinesExisting];
    }
    return machines;

}
- (NSMutableSet *)importZonesWithRequest:(AFHTTPRequestOperation *)request{
    if (![_currentRegion.zonesEtag isEqualToString:request.response.allHeaderFields[@"Etag"]]){
        CoreDataManager *cdManager = [CoreDataManager sharedInstance];
        // Clear existing
        [self clearData:PBMDataAPIZones forRegion:_currentRegion];
        NSMutableSet *allZones = [NSMutableSet new];
        Zone *emptyZone = [Zone createZoneWithData:@{@"id": @(-1),@"name": @"Unclassified"} andContext:cdManager.managedObjectContext];
        [allZones addObject:emptyZone];
        // Create all zones
        [request.responseObject[@"zones"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Zone *newZone = [Zone createZoneWithData:obj andContext:cdManager.managedObjectContext];
            newZone.region = _currentRegion;
            [allZones addObject:newZone];
        }];
        _currentRegion.zonesEtag = request.response.allHeaderFields[@"Etag"];
        [cdManager saveContext];
        
        return allZones;
    }else{
        NSLog(@"Zones same Etag");
        NSFetchRequest *zonesFetch = [NSFetchRequest fetchRequestWithEntityName:@"Zone"];
        zonesFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        
        NSMutableSet *zones = [[NSMutableSet alloc] initWithArray:[[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:zonesFetch error:nil]];
        return zones;
    }
}
- (NSMutableSet *)importOperatorsWithRequest:(AFHTTPRequestOperation *)request{
    if (![_currentRegion.operatorsEtag isEqualToString:request.response.allHeaderFields[@"Etag"]]){
        CoreDataManager *cdManager = [CoreDataManager sharedInstance];
        // Clear existing
        [self clearData:PBMDataAPIOperators forRegion:_currentRegion];
        NSMutableSet *allOperators = [NSMutableSet new];
        Operator *emptyOperator = [Operator createOperatorWithData:@{@"id": @(-1),@"name": @"Unclassified"} andContext:cdManager.managedObjectContext];
        [allOperators addObject:emptyOperator];
        // Create all operators
        [request.responseObject[@"operators"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Operator *newOperator = [Operator createOperatorWithData:obj andContext:cdManager.managedObjectContext];
            newOperator.region = _currentRegion;
            [allOperators addObject:newOperator];
        }];
        _currentRegion.operatorsEtag = request.response.allHeaderFields[@"Etag"];
        [cdManager saveContext];
        
        return allOperators;
   }else{
        NSLog(@"Operators same Etag");
        NSFetchRequest *operatorsFetch = [NSFetchRequest fetchRequestWithEntityName:@"Operator"];
        operatorsFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        
        NSMutableSet *operators = [[NSMutableSet alloc] initWithArray:[[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:operatorsFetch error:nil]];
        return operators;
    }
}

- (NSMutableSet *)importLocationTypesWithRequest:(AFHTTPRequestOperation *)request{
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];
    // All current location type ids.
    NSFetchRequest *locationTypesFetch = [self fetchRequestForModel:@"LocationType"];
    NSArray *locationTypesExisting = [[cdManager managedObjectContext] executeFetchRequest:locationTypesFetch error:nil];
    NSMutableArray *existingLocationTypes = [NSMutableArray new];
    [locationTypesExisting enumerateObjectsUsingBlock:^(LocationType *obj, NSUInteger idx, BOOL *stop) {
        [existingLocationTypes addObject:obj.locationTypeId];
    }];
    locationTypesExisting = nil;
    locationTypesFetch = nil;
    [request.responseObject[@"location_types"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *locationTypeData = obj;
        if (![existingLocationTypes containsObject:locationTypeData[@"id"]]){
            [LocationType createLocationTypeWithData:locationTypeData andContext:cdManager.managedObjectContext];
        }
    }];
    if (![existingLocationTypes containsObject:@(-1)]){
        [LocationType createLocationTypeWithData:@{@"name": @"Unclassified",@"id": @(-1)} andContext:cdManager.managedObjectContext];
    }
    [cdManager saveContext];
    NSMutableSet *locationTypes = [NSMutableSet new];
    if (locationTypes.count == 0){
        NSFetchRequest *locationTypeFetch = [self fetchRequestForModel:@"LocationType"];
        NSArray *locationTypesExisting = [[cdManager managedObjectContext] executeFetchRequest:locationTypeFetch error:nil];
        [locationTypes addObjectsFromArray:locationTypesExisting];
    }
    
    return locationTypes;
}
- (NSMutableSet *)importLocationsWithRequest:(AFHTTPRequestOperation *)request andMachines:(NSMutableSet *)machines andLocationTypes:(NSMutableSet *)locationTypes andZones:(NSMutableSet *)zones andOperators:(NSMutableSet *)operators{
    if (![_currentRegion.locationsEtag isEqualToString:request.response.allHeaderFields[@"Etag"]]){
        [self clearData:PBMDataAPILocations forRegion:_currentRegion];
        
        CoreDataManager *cdManager = [CoreDataManager sharedInstance];
        NSMutableSet *allLocations = [NSMutableSet new];
        
        [request.responseObject[@"locations"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *location = obj;
            Location *newLocation = [Location createLocationWithData:location andContext:cdManager.managedObjectContext];
            [location[@"location_machine_xrefs"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *machineLocation = obj;
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"machineId = %@" argumentArray:@[machineLocation[@"machine_id"]]];
                NSSet *found = [machines filteredSetUsingPredicate:pred];
                
                MachineLocation *locMachine = [MachineLocation createMachineLocationWithData:machineLocation andContext:cdManager.managedObjectContext];
                locMachine.machine = [found anyObject];
                locMachine.location = newLocation;
                [newLocation addMachinesObject:locMachine];
            }];
            // Set the zone object to the location
            NSPredicate *zonePred = [NSPredicate predicateWithFormat:@"zoneId = %@" argumentArray:@[newLocation.zoneNo]];
            NSSet *foundZones = [zones filteredSetUsingPredicate:zonePred];
            
            if (foundZones.count > 0){
                newLocation.parentZone = [foundZones anyObject];
            }
            
            [allLocations addObject:newLocation];
            newLocation.machineCount = @(newLocation.machines.count);
            
            NSNumber *locationType = location[@"location_type_id"];
            if ([locationType isKindOfClass:[NSNull class]]){
                locationType = @(-1);
            }
            
            NSPredicate *locationTypePred = [NSPredicate predicateWithFormat:@"locationTypeId = %@" argumentArray:@[locationType]];
            NSSet *found = [locationTypes filteredSetUsingPredicate:locationTypePred];
            if (found.count > 0){
                newLocation.locationType = [found anyObject];
            }
            
            NSNumber *operatorId = location[@"operator_id"];
            if ([operatorId isKindOfClass:[NSNull class]]){
                operatorId = @(-1);
            }
            
            NSPredicate *operatorPred = [NSPredicate predicateWithFormat:@"operatorId = %@" argumentArray:@[operatorId]];
            found = [operators filteredSetUsingPredicate:operatorPred];
            if (found.count > 0){
                newLocation.operator = [found anyObject];
            }
            
            [_currentRegion addLocationsObject:newLocation];
        }];
        machines = nil;
        _currentRegion.locationsEtag = request.response.allHeaderFields[@"Etag"];
        [cdManager saveContext];
        return allLocations;
    }else{
        NSLog(@"Locations Same Etag");
        return nil;
    }
}
- (void)importEventsWithRequest:(AFHTTPRequestOperation *)request andLocations:(NSMutableSet *)locations{
    if (![_currentRegion.eventsEtag isEqualToString:request.response.allHeaderFields[@"Etag"]]){
        NSLog(@"New Events Etag");
        [self clearData:PBMDataAPIEvents forRegion:_currentRegion];

        CoreDataManager *cdManager = [CoreDataManager sharedInstance];
        [request.responseObject[@"events"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *event = obj;
            Event *newEvent = [Event createEventWithData:event andContext:cdManager.managedObjectContext];
            if (![event[@"locationNo"] isKindOfClass:[NSNull class]]){
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"locationId = %@" argumentArray:@[event[@"location_id"]]];
                NSSet *found = [locations filteredSetUsingPredicate:pred];
                newEvent.location = [found anyObject];
                newEvent.region = newEvent.location.region;
            }
            [_currentRegion addEventsObject:newEvent];
        }];
        _currentRegion.eventsEtag = request.response.allHeaderFields[@"Etag"];
        [cdManager saveContext];
    }else{
        NSLog(@"Events Same Etag");
    }
}
#pragma mark - Object Fetch Requests
- (NSFetchRequest *)fetchRequestForModel:(NSString *)model{
    NSFetchRequest *modelFetch = [NSFetchRequest new];
    modelFetch.entity = [NSEntityDescription entityForName:model inManagedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext]];
    
    return modelFetch;
}
#pragma mark - Machines
- (void)createNewMachine:(NSDictionary *)machineData withCompletion:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/machines.json",apiRootURL]] parameters:machineData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}
- (void)createNewMachineWithData:(NSDictionary *)machineData andParentMachine:(Machine *)machine forLocation:(Location *)location withCompletion:(APICompleteWithStatusCode)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/location_machine_xrefs.json",apiRootURL]] parameters:machineData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSUInteger statusCode = operation.response.statusCode;
        if (statusCode == 201){
            NSDictionary *machineLocation = responseObject[@"location_machine"];
            MachineLocation *newMachine = [MachineLocation createMachineLocationWithData:machineLocation andContext:[[CoreDataManager sharedInstance] managedObjectContext]];
            newMachine.location = location;
            newMachine.machine = machine;
            [location addMachinesObject:newMachine];
            [[CoreDataManager sharedInstance] saveContext];
        }
        
        completionBlock(responseObject,statusCode);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription},500);
    }];
}
- (void)updateMachineCondition:(MachineLocation *)machine withCondition:(NSString *)newCondition withCompletion:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager PUT:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/location_machine_xrefs/%@.json",apiRootURL,machine.machineLocationId]] parameters:@{@"condition": newCondition} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}
- (void)machineLocationInfo:(MachineLocation *)machine withCompletion:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/location_machine_xrefs/%@.json",apiRootURL,machine.machineLocationId]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}
- (void)allScoresForMachine:(MachineLocation *)machine withCompletion:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/machine_score_xrefs/%@.json",apiRootURL,machine.machineLocationId]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}
- (void)addScore:(NSDictionary *)scoreData forMachine:(MachineLocation *)machine withCompletion:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/machine_score_xrefs.json",apiRootURL]] parameters:scoreData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}
- (void)checkIfCurrentRegionExistsWithCompletion:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@api/v1/regions/does_region_exist.json?name=%@",apiRootURL,self.currentRegion.name] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}

- (void)removeMachine:(MachineLocation *)machine withCompletion:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager DELETE:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/location_machine_xrefs/%@.json",apiRootURL,machine.machineLocationId]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}
#pragma mark - Locations
- (void)updateLocation:(Location *)location withData:(NSDictionary *)locationData andCompletion:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager PUT:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/locations/%@.json",apiRootURL,location.locationId]] parameters:locationData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedLocation" object:nil];

        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}
- (void)suggestLocation:(NSDictionary *)locationData andCompletion:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/locations/suggest.json",apiRootURL]] parameters:locationData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"confirmedLocation" object:nil];

        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}
- (void)confirmLocationInformation:(Location *)location andCompletion:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:[PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/locations/%@.json",apiRootURL,location.locationId]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}
#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"Location updated.");
    CLLocation *foundLocation = [locations lastObject];
    self.userLocation = foundLocation;
    if (self.currentRegion){
        [Location updateAllForRegion:self.currentRegion];
    }
    [manager stopUpdatingLocation];
}
#pragma mark - Contact
- (void)sendMessage:(NSDictionary *)messageData withType:(ContactType)contactType andCompletion:(APIComplete)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *contactRoute;
    
    switch (contactType) {
        case ContactTypeRegionContact:
            contactRoute = [PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/regions/contact.json",apiRootURL]];
            break;
        case ContactTypeRegionSuggest:
            contactRoute = [PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/regions/suggest.json",apiRootURL]];
            break;
        case ContactTypeEvent:
            contactRoute = [PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/regions/contact.json",apiRootURL]];
            break;
        case ContactTypeAppFeedback:
            contactRoute = [PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/regions/app_comment.json",apiRootURL]];
            break;
        default:
            break;
    }
    
    
    [manager POST:contactRoute parameters:messageData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}

#pragma mark - Login
- (void)login:(NSDictionary *)loginData andCompletion:(APIComplete)completionBlock{    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *loginRoute = [PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/users/auth_details.json",apiRootURL]];
    
    [manager GET:loginRoute parameters:loginData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}

- (BOOL)isLoggedInAsGuest {
    User *user = self.currentUser;
    
    if ([user.username isEqualToString:[User guestUsername]]) {
        return true;
    } else {
        return false;
    }
}

- (void)confirmLocation:(Location *)location andCompletion:(APIComplete)completionBlock {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *confirmLocationUrl = [PinballMapManager apiQueryWithLoginCredentials:[NSString stringWithFormat:@"%@api/v1/locations/%@/confirm.json",apiRootURL, [location.locationId stringValue]]];
    
    [manager PUT:confirmLocationUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(@{@"errors": error.localizedDescription});
    }];
}

@end
