//
//  PinballMapManager.h
//  PinballMap
//
//  Created by Frank Michael on 4/12/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import "PinballModels.h"

typedef enum : NSUInteger {
    ContactTypeRegionContact,
    ContactTypeRegionSuggest,
    ContactTypeEvent,
    ContactTypeAppFeedback
} ContactType;


typedef void (^APIComplete)(NSDictionary *status);
typedef void (^APICompleteWithStatusCode)(NSDictionary *response,NSUInteger statusCode);

@interface PinballMapManager : NSObject

@property (nonatomic) NSDictionary *regionInfo;
@property (nonatomic) Region *currentRegion;
@property (nonatomic) CLLocation *userLocation;

+ (id)sharedInstance;
- (void)allRegions:(void (^)(NSArray *regions))regionBlock;
- (void)refreshAllRegions;
- (void)loadRegionData:(Region *)region;
- (void)refreshRegion;
- (BOOL)shouldShowMessageOfDay;
- (void)showedMessageOfDay;
- (void)recentlyAddedMachinesWithCompletion:(APIComplete)completionBlock;
// Machine Routes
- (void)createNewMachine:(NSDictionary *)machineData withCompletion:(APIComplete)completionBlock;
- (void)createNewMachineWithData:(NSDictionary *)machineData andParentMachine:(Machine *)machine forLocation:(Location *)location withCompletion:(APICompleteWithStatusCode)completionBlock;
- (void)updateMachineCondition:(MachineLocation *)machine withCondition:(NSString *)newCondition withCompletion:(APIComplete)completionBlock;
- (void)allScoresForMachine:(MachineLocation *)machine withCompletion:(APIComplete)completionBlock;
- (void)addScore:(NSDictionary *)scoreData forMachine:(MachineLocation *)machine withCompletion:(APIComplete)completionBlock;
- (void)removeMachine:(MachineLocation *)machine withCompletion:(APIComplete)completionBlock;
// Location Routes
- (void)updateLocation:(Location *)location withData:(NSDictionary *)locationData andCompletion:(APIComplete)completionBlock;
- (void)suggestLocation:(NSDictionary *)locationData andCompletion:(APIComplete)completionBlock;
/**
    If location is nil the class will assume you want to use the userLocation
 */
- (void)nearestLocationWithLocation:(CLLocation *)location andCompletion:(APIComplete)completionBlock;
// General Routes
- (void)sendMessage:(NSDictionary *)messageData withType:(ContactType)contactType andCompletion:(APIComplete)completionBlock;
- (void)refreshBasicRegionData:(APIComplete)completionBlock;
- (void)cancelAllLoadingOperations;
@end