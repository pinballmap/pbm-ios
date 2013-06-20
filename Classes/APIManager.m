//
//  PBMDataManager.m
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/11/13.
//
//

#import <CoreLocation/CoreLocation.h>
#import "APIManager.h"
#import "Portland_Pinball_MapAppDelegate.h"
#import "LocationMachineXref.h"
#import "Zone.h"
#import "Utils.h"



#define SAVE_MOC { NSError *_error;if (![moc save:&_error]) { NSLog(@"Sub MOC Error %@",[_error localizedDescription]); } [mainMOC performBlock:^{ NSError *e = nil;  if (![mainMOC save:&e]) {  NSLog(@"Main MOC Error");}}]; }


@implementation APIManager

- (NSDictionary *)fetchedData:(NSData *)data {
    
    //NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"string %@",string);
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    return json;
}

- (NSMutableSet*)updateRegionData:(NSData *)data inMOC:(NSManagedObjectContext*)moc{
    NSDictionary *json = [self fetchedData:data];
    NSArray *regions = json[@"regions"];
    
    NSMutableSet *regionSet;
    for (NSDictionary *regionContainer in regions) {
        NSDictionary *regionData = regionContainer[@"region"];
        
        Region *region = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:moc];
        
        NSString *lat = regionData[@"lat"];
        NSString *lon = regionData[@"lon"];
        
        if (lat == (NSString *)[NSNull null]) {
            lat = @"1";
        }
        
        if (lon == (NSString *)[NSNull null]) {
            lon = @"1";
        }
        
        [region setIdNumber:regionData[@"id"]];
        [region setName:regionData[@"name"]];
        [region setFormalName:regionData[@"formalName"]];
        [region setSubdir:regionData[@"subdir"]];
        [region setLat:[NSNumber numberWithInt:[lat intValue]]];
        [region setLon:[NSNumber numberWithInt:[lon intValue]]];
        [region setNMachines:@4];
        
        //[self saveContext];
        [regionSet addObject:region];
    }
    
    return [NSSet setWithSet:regionSet];
}

#pragma mark - Region Data

- (void)fetchRegionDataForLocation:(CLLocation*)location inMOC:(NSManagedObjectContext*)moc {
    UIApplication *app = [UIApplication sharedApplication];
	[app setNetworkActivityIndicatorVisible:YES];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL, @"portland/regions.json"]]];
    NSSet *regions = [self updateRegionData:data inMOC:moc];
    
    Region *closestRegion = nil;
    CLLocationDistance closestDistance = 24901.55;
    for (Region *region in regions) {
        CLLocationDistance distance = [location distanceFromLocation:[region coordinates]] / METERS_IN_A_MILE;
        
        if(distance < closestDistance) {
            closestRegion   = region;
            closestDistance = distance;
        }
    } 
    
    //[self setActiveRegion:closestRegion];
}

#pragma mark Location Data

- (void)fetchLocationData {
    
    Portland_Pinball_MapAppDelegate *appDelegate = (Portland_Pinball_MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIApplication *app = [UIApplication sharedApplication];
    [app setNetworkActivityIndicatorVisible:YES];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@all_region_data.json", appDelegate.rootURL]]];
    [self fetchedLocationData:data forRegion:appDelegate.activeRegion];

}

- (void)fetchedLocationData:(NSData *)data forRegion:(Region*)region{
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterBehaviorDefault];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        
        NSMutableDictionary *zonesForLocations = [[NSMutableDictionary alloc] init];
        
        NSManagedObjectContext *mainMOC = region.managedObjectContext;
        NSManagedObjectContext *moc     = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        [moc setParentContext:mainMOC];
        [moc setUndoManager:nil];
        
        
        Region *subregion = (Region*)[moc objectWithID:region.objectID]; //get region from submoc
        
        NSDictionary *json = [self fetchedData:data][@"data"][@"region"];
        
        //Parse Machines First
        NSMutableSet *machineSet = [NSMutableSet set];
        NSArray *machines = json[@"machines"];
        for (NSDictionary *machineContainer in machines) {
            NSDictionary *machineData = machineContainer[@"machine"];
            
            if ([machineData[@"numLocations"] intValue] != 0) {
                Machine *machine = [NSEntityDescription insertNewObjectForEntityForName:@"Machine" inManagedObjectContext:moc];
                
                [machine setIdNumber:machineData[@"id"]];
                [machine setName:[machineData[@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                [machine addRegionObject:subregion];
                //[subregion addMachinesObject:machine]; //redundant
                
                [machineSet addObject:machine]; //save them for use with locations later
            }
        }
        
        SAVE_MOC;
        
        NSArray *locations = json[@"locations"];
        for (NSDictionary *locationContainer in locations) {
            NSDictionary *locationData = locationContainer[@"location"];
            
            if ([locationData[@"numMachines"] intValue] != 0) {
                
                NSString *locationID = locationData[@"id"];
                
                Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:moc];
                [location setStreet1:locationData[@"street"]];
                [location setCity:locationData[@"city"]];
                [location setState:locationData[@"state"]];
                [location setZip:locationData[@"zip"]];
                //[location setPhone:locationData[@"phone"]];
                
#warning TODO: Add zoneNo to allregiondata
                if (locationData[@"zoneNo"] && locationData[@"zoneNo"] != (NSString *)[NSNull null]) {
                    [zonesForLocations setValue:locationData[@"zoneNo"] forKey:locationID];
                }
                
                double lon = [locationData[@"lon"] doubleValue];
                double lat = [locationData[@"lat"] doubleValue];
                
                if (lat == 0.0 || lon == 0.0) {
                    lat = PDX_LAT;
                    lon = PDX_LON;
                }
                
                [location setIdNumber:[NSNumber numberWithInt:[locationID intValue]]];
                [location setTotalMachines:locationData[@"numMachines"]];
                [location setName:[locationData[@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                [location setLat:@(lat)];
                [location setLon:@(lon)];
                [location setRegion:subregion];
                [location updateDistance];
                
                NSArray *machines = locationData[@"machines"];
                for (NSDictionary *machineContainer in machines) {
                    NSDictionary *machineData = machineContainer[@"machine"];
                    
                    NSString *machineName = machineData[@"name"];
                    NSSet *quickset = [machineSet filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",machineName]];
                    if(quickset.count > 0) {
                        LocationMachineXref *xref = [NSEntityDescription insertNewObjectForEntityForName:@"LocationMachineXref" inManagedObjectContext:moc];
                        
                        if (machineData[@"condition"] && machineData[@"condition"] != ((NSString *)[NSNull null])) {
                            [xref setCondition:[Utils urlDecode:machineData[@"condition"]]];
                            [xref setConditionDate:[dateformatter dateFromString:machineData[@"condition_date"]]];
                        }
                        
                        [xref setMachine:[quickset anyObject]];
                        [location addLocationMachineXrefsObject:xref];
                    } else {
                        NSLog(@"Machine not found %@",machineName);
                    }
                    
                    SAVE_MOC;
                }
            }
        }
        
        SAVE_MOC;
        
        NSArray *zones = json[@"zones"];
        for (NSDictionary *zoneContainer in zones) {
            NSDictionary *zoneData = zoneContainer[@"zone"];
            
            Zone *zone = [NSEntityDescription insertNewObjectForEntityForName:@"Zone" inManagedObjectContext:moc];
            
            [zone setName:zoneData[@"name"]];
            [zone setIdNumber:zoneData[@"id"]];
            [zone setIsPrimary:@([zoneData[@"isPrimary"] intValue])];
            [zone setRegion:subregion];
            //[subregion addZonesObject:zone]; //redundant
        }
        
        SAVE_MOC;
        
        for (NSString *locationID in zonesForLocations.allKeys) {
            Zone *zone = (Zone *)[Utils fetchObject:@"Zone" where:@"idNumber" equals:[zonesForLocations objectForKey:locationID] inMOC:moc];
            Location *location = (Location *)[Utils fetchObject:@"Location" where:@"idNumber" equals:locationID inMOC:moc];
            
            [zone addLocationObject:location];
            [location setLocationZone:zone];
        }
        
        SAVE_MOC;
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           NSLog(@"Parse Compelte");
                       });
    });
}

@end
