//
//  HighScore.m
//  PinballMap
//
//  Created by Frank Michael on 10/7/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "HighScore.h"

@implementation HighScore

- (instancetype)initWithData:(NSDictionary *)scoreData{
    self = [super init];
    if (self){
        self.score = scoreData[@"score"];
        self.rank = [scoreData[@"rank"] stringValue];
        
        // Find Machine info
        NSFetchRequest *machineFetch = [NSFetchRequest fetchRequestWithEntityName:@"MachineLocation"];
        machineFetch.predicate = [NSPredicate predicateWithFormat:@"machineLocationId = %@",scoreData[@"location_machine_xref_id"]];
        machineFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"machineLocationId" ascending:YES]];
        NSArray *foundMachines = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:machineFetch error:nil];
        if (foundMachines.count == 1){
            self.machine = [(MachineLocation *)[foundMachines firstObject] machine];
        }else{
            self.machine = nil;
        }
    }
    return self;
}

@end
