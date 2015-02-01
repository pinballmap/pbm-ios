//
//  LocationMapCell.m
//  PinballMap
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "LocationMapCell.h"
#import "Location+Annotation.h"

@interface LocationMapCell ()

@property (nonatomic) MKPointAnnotation *annotation;

@end

@implementation LocationMapCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurrentLocation:(Location *)currentLocation{
    _currentLocation = currentLocation;
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([_currentLocation.latitude doubleValue],[_currentLocation.longitude doubleValue]);
    self.mapView.region = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.002, 0.002));
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.userInteractionEnabled = NO;
    self.mapView.showsUserLocation = YES;
    if (self.annotation.coordinate.latitude != _currentLocation.annotation.coordinate.latitude && self.annotation.coordinate.longitude != _currentLocation.annotation.coordinate.longitude){
        self.annotation = _currentLocation.annotation;
        [self.mapView addAnnotation:_currentLocation.annotation];
    }
}

@end
