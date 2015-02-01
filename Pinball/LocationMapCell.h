//
//  LocationMapCell.h
//  PinballMap
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationMapCell : UITableViewCell

@property (weak) IBOutlet MKMapView *mapView;
@property (nonatomic) Location *currentLocation;

@end
