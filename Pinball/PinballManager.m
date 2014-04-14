//
//  PinballManager.m
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "PinballManager.h"
#import "NSFileManager+DocumentsDirectory.h"

#define rootURL @"http://pinballmap.com/"

@interface PinballManager () {
    NSURLSession *session;
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
        session = [NSURLSession sharedSession];
        NSDictionary *region = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentRegion"];
        if (region){
            NSFetchRequest *regionRequest = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
            regionRequest.predicate = [NSPredicate predicateWithFormat:@"fullName = %@",region[@"fullName"]];
            regionRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES]];
            NSManagedObjectContext *context = [[CoreDataManager sharedInstance] managedObjectContext];
            NSArray *results = [context executeFetchRequest:regionRequest error:nil];
            if (results.count == 1){
                _currentRegion = results[0];
            }else{
                [self changeToRegion:@{@"name": @"seattle"}];
            }
        }else{
            [self changeToRegion:@{@"name": @"seattle"}];
        }
    }
    return self;
}
- (void)importToCoreData:(NSDictionary *)pinballData{
    CoreDataManager *cdManager = [CoreDataManager sharedInstance];
    [cdManager resetStore];
    
    _currentRegion = [Region createRegionWithData:pinballData];
    NSDictionary *regionDic = @{@"fullName": _currentRegion.fullName,@"name": _currentRegion.name};
    [[NSUserDefaults standardUserDefaults] setObject:regionDic forKey:@"CurrentRegion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Create all machines.
    // Save the machines to a array to be used when creating the MachineLocation objects to ref.
    NSMutableSet *machines = [NSMutableSet new];
    [pinballData[@"machines"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *machineData = obj[@"machine"];
        Machine *newMachine = [Machine createMachineWithData:machineData];
        [machines addObject:newMachine];
    }];
    [cdManager saveContext];
    // Add machines to region object.
    [_currentRegion addMachines:machines];
    // Create all locations
    NSMutableSet *locations = [NSMutableSet new];
    [pinballData[@"locations"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *location = obj[@"location"];
        Location *newLocation = [Location createLocationWithData:location];
        [location[@"machines"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *machineLocation = obj[@"machine"];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"machineId = %@" argumentArray:@[machineLocation[@"id"]]];
            NSSet *found = [machines filteredSetUsingPredicate:pred];
            
            MachineLocation *locMachine = [MachineLocation createMachineLocationWithData:machineLocation];
            locMachine.machine = [found anyObject];
            locMachine.location = newLocation;
            [newLocation addMachinesObject:locMachine];
        }];
        [locations addObject:newLocation];
        [_currentRegion addLocationsObject:newLocation];
    }];
    machines = nil;
    [cdManager saveContext];
    // Craete all events
    [pinballData[@"events"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *event = obj[@"event"];
        Event *newEvent = [Event createEventWithData:event];
        if (![event[@"locationNo"] isKindOfClass:[NSNull class]]){
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"locationId = %@" argumentArray:@[event[@"locationNo"]]];
            NSSet *found = [locations filteredSetUsingPredicate:pred];
            newEvent.location = [found anyObject];
            newEvent.region = newEvent.location.region;
        }
    }];
    [cdManager saveContext];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionUpdate" object:nil];
}
- (void)allRegions:(void (^)(NSArray *regions))regionBlock{
    NSData *cacheData = [self regionCacheData];
    
    if (cacheData){
        regionBlock([self parseRegions:cacheData]);
    }else{
        NSURL *regionURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@portland/regions.json",rootURL]];
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
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:apiData options:NSJSONReadingAllowFragments error:nil];
    if (jsonData){
        NSMutableArray *regions = [NSMutableArray new];
        [jsonData[@"regions"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *region = obj[@"region"];
            [regions addObject:@{@"formalName": region[@"formalName"],@"name": region[@"name"]}];
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
@end
