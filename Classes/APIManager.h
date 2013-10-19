//
//  PBMDataManager.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/11/13.
//
//

#import <Foundation/Foundation.h>
#import "Region.h"

@class APIManager;
@protocol APIManagerDelegate <NSObject>
-(void)apiManager:(APIManager*)apiManager didCompleteWithClosestRegion:(Region*)region;


@end

@interface APIManager : NSObject
@property (nonatomic,weak) id <APIManagerDelegate> delegate;

- (void)fetchRegionDataForLocation:(CLLocation*)location inMOC:(NSManagedObjectContext*)moc;
- (void)fetchLocationData;

@end
