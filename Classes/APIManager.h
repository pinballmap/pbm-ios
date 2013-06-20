//
//  PBMDataManager.h
//  Portland Pinball Map
//
//  Created by Isaac Ruiz on 6/11/13.
//
//

#import <Foundation/Foundation.h>

@interface APIManager : NSObject

- (void)fetchRegionDataForLocation:(CLLocation*)location inMOC:(NSManagedObjectContext*)moc;

@end
