//
//  PinballManager.h
//  Pinball
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import "PinballModels.h"

@interface PinballManager : NSObject

@property (nonatomic) NSDictionary *regionInfo;
@property (nonatomic) Region *currentRegion;
@property (nonatomic,readonly) CLLocation *userLocation;

+ (id)sharedInstance;
- (void)allRegions:(void (^)(NSArray *regions))regionBlock;
- (void)loadRegionData:(Region *)region;
- (void)refreshRegion;
// Machine Routes
- (void)createNewMachine:(NSDictionary *)machineData withCompletion:(void(^)(NSDictionary *status))completionBlock;
- (void)createNewMachineLocation:(NSDictionary *)machineData withCompletion:(void(^)(NSDictionary *status))completionBlock;
- (void)updateMachineCondition:(MachineLocation *)machine withCondition:(NSString *)newCondition withCompletion:(void(^)(NSDictionary *status))completionBlock;
@end