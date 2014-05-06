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

#define rootURL @"http://pinballmap.com/"

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
            regionRequest.predicate = [NSPredicate predicateWithFormat:@"fullName = %@",_regionInfo[@"full_name"]];
            regionRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES]];
            NSManagedObjectContext *context = [[CoreDataManager sharedInstance] managedObjectContext];
            NSArray *results = [context executeFetchRequest:regionRequest error:nil];
            if (results.count == 1){
                _currentRegion = results[0];
            }else{
                [self changeToRegion:@{@"full_name":@"Seattle",@"id":@3,@"lat":@48,@"lon":@(-122),@"name":@"seattle",@"primary_email_contact":@"morganshilling@gmail.com"}];
            }
        }else{
            [self changeToRegion:@{@"full_name":@"Seattle",@"id":@3,@"lat":@48,@"lon":@(-122),@"name":@"seattle",@"primary_email_contact":@"morganshilling@gmail.com"}];
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
- (void)importToCoreData:(NSDictionary *)pinballData{
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];
    [cdManager resetStore];
    dispatch_queue_t queue;
    queue = dispatch_queue_create("com.pinballmap.import", NULL);
    
    dispatch_sync(queue, ^{
        _currentRegion = [Region createRegionWithData:pinballData andContext:cdManager.privateObjectContext];
        NSDictionary *regionDic = @{@"fullName": _currentRegion.fullName,@"name": _currentRegion.name};
        [[NSUserDefaults standardUserDefaults] setObject:regionDic forKey:@"CurrentRegion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // Create all machines.
        // Save the machines to a array to be used when creating the MachineLocation objects to ref.
        NSMutableSet *machines = [NSMutableSet new];
        [pinballData[@"machines"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *machineData = obj[@"machine"];
            Machine *newMachine = [Machine createMachineWithData:machineData andContext:cdManager.privateObjectContext];
            [machines addObject:newMachine];
        }];
        [cdManager.privateObjectContext save:nil];
        // Add machines to region object.
        [_currentRegion addMachines:machines];
        // Create all locations
        NSMutableSet *locations = [NSMutableSet new];
        [pinballData[@"locations"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *location = obj[@"location"];
            Location *newLocation = [Location createLocationWithData:location andContext:cdManager.privateObjectContext];
            [location[@"machines"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *machineLocation = obj[@"machine"];
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"machineId = %@" argumentArray:@[machineLocation[@"id"]]];
                NSSet *found = [machines filteredSetUsingPredicate:pred];
                
                MachineLocation *locMachine = [MachineLocation createMachineLocationWithData:machineLocation andContext:cdManager.privateObjectContext];
                locMachine.machine = [found anyObject];
                locMachine.location = newLocation;
                [newLocation addMachinesObject:locMachine];
            }];
            [locations addObject:newLocation];
            [_currentRegion addLocationsObject:newLocation];
        }];
        machines = nil;
        [cdManager.privateObjectContext save:nil];
        // Craete all events
        [pinballData[@"events"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *event = obj[@"event"];
            Event *newEvent = [Event createEventWithData:event andContext:cdManager.privateObjectContext];
            if (![event[@"locationNo"] isKindOfClass:[NSNull class]]){
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"locationId = %@" argumentArray:@[event[@"locationNo"]]];
                NSSet *found = [locations filteredSetUsingPredicate:pred];
                newEvent.location = [found anyObject];
                newEvent.region = newEvent.location.region;
            }
        }];
        [cdManager.privateObjectContext save:nil];
    });
}
- (void)allRegions:(void (^)(NSArray *regions))regionBlock{
    NSData *cacheData = [self regionCacheData];
    
    if (cacheData){
        regionBlock([self parseRegions:cacheData]);
    }else{
        NSURL *regionURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/regions.json",rootURL]];
        NSURLSessionDataTask *regionData = [session dataTaskWithURL:regionURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data && !error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self saveRegionCache:data];
                    regionBlock([self parseRegions:data]);
                });
            }
        }];
        [regionData resume];
    }
}
- (NSArray *)parseRegions:(NSData *)apiData{
    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:apiData options:NSJSONReadingAllowFragments error:nil];
    if (jsonData){
        NSMutableArray *regions = [NSMutableArray new];
        [jsonData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [regions addObject:obj];
        }];
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"formalName" ascending:YES];
        return [regions sortedArrayUsingDescriptors:@[sorter]];
    }
    return nil;
}
- (NSData *)regionCacheData{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/regions.json",[NSFileManager documentsDirectory]]]){
        return [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/regions.json",[NSFileManager documentsDirectory]]];
    }
    return nil;
}
- (void)saveRegionCache:(NSData *)data{
    [data writeToFile:[NSString stringWithFormat:@"%@/regions.json",[NSFileManager documentsDirectory]] atomically:YES];
}
- (void)changeToRegion:(NSDictionary *)region{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatingRegion" object:nil];
    [self reloadRegionData:region];
//    NSURL *regionURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/all_region_data.json",rootURL,region[@"name"]]];
//    NSURLSessionDataTask *regionData = [session dataTaskWithURL:regionURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (data){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSDictionary *regionData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//                [self importToCoreData:regionData[@"data"][@"region"]];
//                NSLog(@"All done importing %@",regionData[@"data"][@"region"][@"fullName"]);
//            });
//        }
//    }];
//    [regionData resume];
}
- (void)refreshRegion{
    NSDictionary *region = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentRegion"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatingRegion" object:nil];
    NSURL *regionURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/all_region_data.json",rootURL,region[@"name"]]];
    NSURLSessionDataTask *regionData = [session dataTaskWithURL:regionURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *regionData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                [self importToCoreData:regionData[@"data"][@"region"]];
                NSLog(@"All done importing %@",regionData[@"data"][@"region"][@"fullName"]);
            });
        }
    }];
    [regionData resume];
}
- (void)reloadRegionData:(NSDictionary *)region{
    [[NSUserDefaults standardUserDefaults] setObject:region forKey:@"CurrentRegion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];
    [cdManager resetStore];
    // Create region.
    _currentRegion = [Region createRegionWithData:region andContext:cdManager.managedObjectContext];
    [cdManager saveContext];
    
    NSMutableArray *apiOperations = [NSMutableArray new];
    
    NSURLRequest *machineRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/machines.json",rootURL]]];
    AFHTTPRequestOperation *machineOperation = [[AFHTTPRequestOperation alloc] initWithRequest:machineRequest];
    machineOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [apiOperations addObject:machineOperation];
    NSURLRequest *locationRequests = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/region/%@/locations.json",rootURL,region[@"name"]]]];
    AFHTTPRequestOperation *locationsOperation = [[AFHTTPRequestOperation alloc] initWithRequest:locationRequests];
    locationsOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [apiOperations addObject:locationsOperation];
    NSURLRequest *eventsRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/region/%@/events.json",rootURL,region[@"name"]]]];
    AFHTTPRequestOperation *eventOperation = [[AFHTTPRequestOperation alloc] initWithRequest:eventsRequest];
    eventOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [apiOperations addObject:eventOperation];
    
    NSArray *api = [AFURLConnectionOperation batchOfRequestOperations:apiOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"Completed %lu of %lu",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        NSLog(@"All Done");
        __block NSMutableSet *createdMachines;
        __block NSMutableSet *createdLocations;
        [operations enumerateObjectsUsingBlock:^(AFHTTPRequestOperation *obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"%@",obj.request.URL);
            if (idx == 0){
                // Machines Data
                NSLog(@"%@",obj.responseObject);
                createdMachines = [self importMachines:obj.responseObject];
            }else if (idx == 1){
                // Loction
                createdLocations = [self importLocations:obj.responseObject withMachines:createdMachines];
            }else if (idx == 2){
                [self importEvents:obj.responseObject withLocations:createdLocations];
            }
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionUpdate" object:nil];
    }];
    NSLog(@"Started");
    [[NSOperationQueue mainQueue] addOperations:api waitUntilFinished:NO];
}
#pragma mark - CoreData import
- (NSMutableSet *)importMachines:(NSArray *)machineData{
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];

    // Create all machines.
    // Save the machines to a array to be used when creating the MachineLocation objects to ref.
    NSMutableSet *machines = [NSMutableSet new];
    [machineData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *machineData = obj;
        Machine *newMachine = [Machine createMachineWithData:machineData andContext:cdManager.managedObjectContext];
        [machines addObject:newMachine];
    }];
    [cdManager.privateObjectContext save:nil];
    return machines;
}
- (NSMutableSet *)importLocations:(NSArray *)locations withMachines:(NSMutableSet *)machines{
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];
    NSMutableSet *allLocations = [NSMutableSet new];
    [locations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *location = obj;
        Location *newLocation = [Location createLocationWithData:location andContext:cdManager.managedObjectContext];
        [location[@"machines"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *machineLocation = obj;
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"machineId = %@" argumentArray:@[machineLocation[@"id"]]];
            NSSet *found = [machines filteredSetUsingPredicate:pred];
            
            MachineLocation *locMachine = [MachineLocation createMachineLocationWithData:machineLocation andContext:cdManager.managedObjectContext];
            locMachine.machine = [found anyObject];
            locMachine.location = newLocation;
            [newLocation addMachinesObject:locMachine];
        }];
        [allLocations addObject:newLocation];
        [_currentRegion addLocationsObject:newLocation];
    }];
    machines = nil;
    [cdManager.managedObjectContext save:nil];
    return allLocations;
}
- (void)importEvents:(NSArray *)events withLocations:(NSMutableSet *)locations{
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];
    [events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *event = obj;
        Event *newEvent = [Event createEventWithData:event andContext:cdManager.managedObjectContext];
        if (![event[@"locationNo"] isKindOfClass:[NSNull class]]){
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"locationId = %@" argumentArray:@[event[@"location_id"]]];
            NSSet *found = [locations filteredSetUsingPredicate:pred];
            newEvent.location = [found anyObject];
            newEvent.region = newEvent.location.region;
        }
    }];
    [cdManager.managedObjectContext save:nil];
}
#pragma mark - Machines
- (void)createNewMachine:(NSDictionary *)machineData withCompletion:(void (^)(NSDictionary *))completionBlock{
    
}
#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"Location updated.");
    CLLocation *foundLocation = [locations lastObject];
    _userLocation = foundLocation;
    [manager stopUpdatingLocation];
}

@end
