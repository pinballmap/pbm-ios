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

typedef void (^APIComplete)(NSDictionary *status);
@interface PinballManager : NSObject

@property (nonatomic) NSDictionary *regionInfo;
@property (nonatomic) Region *currentRegion;
@property (nonatomic,readonly) CLLocation *userLocation;

+ (id)sharedInstance;
- (void)allRegions:(void (^)(NSArray *regions))regionBlock;
- (void)loadRegionData:(Region *)region;
- (void)refreshRegion;
// Machine Routes
- (void)createNewMachine:(NSDictionary *)machineData withCompletion:(APIComplete)completionBlock;
- (void)createNewMachineLocation:(NSDictionary *)machineData withCompletion:(APIComplete)completionBlock;
- (void)updateMachineCondition:(MachineLocation *)machine withCondition:(NSString *)newCondition withCompletion:(APIComplete)completionBlock;
- (void)allScoresForMachine:(MachineLocation *)machine withCompletion:(APIComplete)completionBlock;
- (void)addScore:(NSDictionary *)scoreData forMachine:(MachineLocation *)machine withCompletion:(APIComplete)completionBlock;
// Location Routes
- (void)updateLocation:(Location *)location withData:(NSDictionary *)locationData andCompletion:(APIComplete)completionBlock;
- (void)suggestLocation:(NSDictionary *)locationData andCompletion:(APIComplete)completionBlock;
@end