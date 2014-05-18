//
//  PinballManager.m
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "PinballManager.h"
#import "NSFileManager+DocumentsDirectory.h"
#import <AFNetworking.h>

static const NSString *apiRootURL = @"http://pinballmap.com/";

typedef NS_ENUM(NSInteger, PBMDataAPI) {
    PBMDataAPIRegions = 0,
    PBMDataAPIMachines,
    PBMDataAPILocationTypes,
    PBMDataAPILocations,
    PBMDataAPIEvents
};


@interface PinballManager () <CLLocationManagerDelegate>{
    NSURLSession *session;
    CLLocationManager *locationManager;
}

@end


@implementation PinballManager

+ (id)sharedInstance{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p,^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}
- (id)init{
    self = [super init];
    if (self){
        [self getUserLocation];
        session = [NSURLSession sharedSession];
        _regionInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentRegion"];
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
        }else{
            _currentRegion = [self regionWithData:@{@"full_name":@"Seattle",@"id":@3,@"lat":@48,@"lon":@(-122),@"name":@"seattle",@"primary_email_contact":@"morganshilling@gmail.com"} shouldCreate:YES];
            [self loadRegionData:_currentRegion];
        }
    }
    return self;
}
- (void)getUserLocation{
    if (!locationManager){
        locationManager = [CLLocationManager new];
    }
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}
#pragma mark - Regions listing
- (void)allRegions:(void (^)(NSArray *regions))regionBlock{
    NSArray *currentRegions = [self coreDataRegions];
    NSLog(@"Existing Region Count: %i",currentRegions.count);
    NSMutableArray *regionIds = [NSMutableArray new];
    [currentRegions enumerateObjectsUsingBlock:^(Region *obj, NSUInteger idx, BOOL *stop) {
        [regionIds addObject:obj.regionId];
    }];
    currentRegions = nil;
    NSURLRequest *regionRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/regions.json",apiRootURL]]];
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
        NSLog(@"New Region Count: %i",[self coreDataRegions].count);
        regionBlock([self coreDataRegions]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:regionAPI];
}
#pragma mark - Region Data Load
- (void)refreshRegion{

    NSArray *apiOperations = @[[self requestForData:PBMDataAPILocations],[self requestForData:PBMDataAPIEvents]];
    
    NSArray *api = [AFURLConnectionOperation batchOfRequestOperations:apiOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"Completed %lu of %lu",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        NSFetchRequest *stackRequest = [NSFetchRequest fetchRequestWithEntityName:@"Machine"];
        stackRequest.predicate = nil;
        stackRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        __block NSMutableSet *machines = [NSMutableSet setWithArray:[[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:stackRequest error:nil]];
        __block NSMutableSet *createdLocations;
        [operations enumerateObjectsUsingBlock:^(AFHTTPRequestOperation *obj, NSUInteger idx, BOOL *stop) {
            if (idx == 0){
                createdLocations = [self importLocationsWithRequest:obj andMachines:machines];
            }else if (idx == 1){
                [self importEventsWithRequest:obj andLocations:createdLocations];
            }
            [[CoreDataManager sharedInstance] saveContext];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionUpdate" object:nil];
    }];
    [[NSOperationQueue mainQueue] addOperations:api waitUntilFinished:NO];
}
- (void)loadRegionData:(Region *)region{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatingRegion" object:nil];

    [[NSUserDefaults standardUserDefaults] setObject:@{@"name": region.name} forKey:@"CurrentRegion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Find region.
    _currentRegion = region;

    NSArray *apiOperations = @[[self requestForData:PBMDataAPIMachines],[self requestForData:PBMDataAPILocations],[self requestForData:PBMDataAPIEvents]];
    
    
    NSArray *api = [AFURLConnectionOperation batchOfRequestOperations:apiOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"Completed %lu of %lu",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        NSLog(@"All Done");
        __block NSMutableSet *createdMachines;
        __block NSMutableSet *createdLocations;
        [operations enumerateObjectsUsingBlock:^(AFHTTPRequestOperation *obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"%@",obj.request.URL);
            if (idx == 0){
                createdMachines = [self importMachinesWithRequest:obj];
            }else if (idx == 1){
                createdLocations = [self importLocationsWithRequest:obj andMachines:createdMachines];
            }else if (idx == 2){
                [self importEventsWithRequest:obj andLocations:createdLocations];
            }
            [[CoreDataManager sharedInstance] saveContext];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionUpdate" object:nil];
    }];
    NSLog(@"Started");
    [[NSOperationQueue mainQueue] addOperations:api waitUntilFinished:NO];
}
- (AFHTTPRequestOperation *)requestForData:(PBMDataAPI)apiType{
    NSURL *apiURL;
    switch (apiType) {
        case PBMDataAPIRegions:
            apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/regions.json",apiRootURL]];
            break;
        case PBMDataAPIMachines:
            apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/machines.json",apiRootURL]];
            break;
        case PBMDataAPILocationTypes:
            apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"api/v1/location_types.json"]];
            break;
        case PBMDataAPILocations:
            apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/region/%@/locations.json",apiRootURL,_currentRegion.name]];
            break;
        case PBMDataAPIEvents:
            apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/region/%@/events.json",apiRootURL,_currentRegion.name]];
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
        NSLog(@"Creating New Region");
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
- (NSMutableSet *)importLocationsWithRequest:(AFHTTPRequestOperation *)request andMachines:(NSMutableSet *)machines{
    if (![_currentRegion.locationsEtag isEqualToString:request.response.allHeaderFields[@"Etag"]]){
        NSLog(@"New Locations Etag");
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
            [allLocations addObject:newLocation];
            newLocation.machineCount = @(newLocation.machines.count);
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
- (void)createNewMachine:(NSDictionary *)machineData withCompletion:(void (^)(NSDictionary *))completionBlock{
    
}
- (void)createNewMachineLocation:(NSDictionary *)machineData withCompletion:(void (^)(NSDictionary *))completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:[NSString stringWithFormat:@"%@api/v1/location_machine_xrefs.json",apiRootURL] parameters:machineData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self refreshRegion];
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}
#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"Location updated.");
    CLLocation *foundLocation = [locations lastObject];
    _userLocation = foundLocation;
    [manager stopUpdatingLocation];
}

@end
