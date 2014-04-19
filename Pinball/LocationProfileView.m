//
//  LocationProfileView.m
//  Pinball
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "LocationProfileView.h"
#import "InformationCell.h"
#import "LocationMapCell.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Machine.h"
#import "MapView.h"
#import "MachineConditionView.h"
#import "NewMachineView.h"

@interface LocationProfileView () {
    NSArray *machines;
}

@end

@implementation LocationProfileView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = _currentLocation.name;
    // Sort the machines by name.
    NSSortDescriptor *asc = [NSSortDescriptor sortDescriptorWithKey:@"machine.name" ascending:YES];
    machines = [[_currentLocation.machines allObjects] sortedArrayUsingDescriptors:@[asc]];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 4;
    }else{
        return [_currentLocation.machineCount integerValue];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        if (indexPath.row  == 2){
            return 122;
        }else{
            return 67;
        }
    }else if (indexPath.section == 1){
        MachineLocation *currentMachine = machines[indexPath.row];
        NSString *cellTitle = currentMachine.machine.name;
        
        CGRect stringSize = [cellTitle boundingRectWithSize:CGSizeMake(290, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil];
        
        stringSize.size.height = stringSize.size.height+10;   // Take into account the 10 points of padding within a cell.
        if (stringSize.size.height+10 < 44){
            return 44;
        }else{
            return stringSize.size.height+10;
        }
    }
    return 44;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return _currentLocation.name;
    }else if (section == 1){
        return [NSString stringWithFormat:@"Machines: %@\n(Swipe to update condition)",_currentLocation.machineCount];
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        if (indexPath.row == 0 || indexPath.row == 1){
            InformationCell *cell = (InformationCell *)[tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
            if (indexPath.row == 0){
                cell.infoLabel.text = @"Phone";
                cell.dataLabel.text = _currentLocation.phone;
            }else if (indexPath.row == 1){
                cell.infoLabel.text = @"Location";
                cell.dataLabel.text = _currentLocation.street;
            }
            return cell;
        }else if (indexPath.row == 2){
            LocationMapCell *cell = (LocationMapCell *)[tableView dequeueReusableCellWithIdentifier:@"MapCell" forIndexPath:indexPath];
            [cell.loadingView startAnimating];
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([_currentLocation.latitude doubleValue],[_currentLocation.longitude doubleValue]);
            
            MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
            options.size = cell.mapImage.frame.size;
            options.region = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(.002, .002));
            options.mapType = MKMapTypeHybrid;
            options.showsPointsOfInterest = NO;
            MKMapSnapshotter *snapShooter2 = [[MKMapSnapshotter alloc] initWithOptions:options];
            [snapShooter2 startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
                NSLog(@"Loaded Snap");
                if (error){
                    NSLog(@"%@",error);
                }else{
                    [cell.loadingView stopAnimating];
                    cell.mapImage.image = snapshot.image;
                }
            }];
            return cell;
        }else if (indexPath.row == 3){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MachineCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Add Machine";
            cell.detailTextLabel.text = nil;
            return cell;
        }
    }else if (indexPath.section == 1){
        MachineLocation *currentMachine = machines[indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MachineCell" forIndexPath:indexPath];
        cell.textLabel.text = currentMachine.machine.name;
        // If no condition is available, just don't set the detail text label.
        if (![currentMachine.condition isEqualToString:@"N/A"]){
            cell.detailTextLabel.text = currentMachine.condition;
        }else{
            cell.detailTextLabel.text = nil;
        }
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            if (_currentLocation.phone.length > 0 && ![_currentLocation.phone isEqualToString:@"N/A"]){
                NSString *contactsPhoneNumber = [@"tel:+" stringByAppendingString:_currentLocation.phone];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contactsPhoneNumber]];
            }
        }else if (indexPath.row == 1){
            [self performSegueWithIdentifier:@"MapView" sender:[tableView cellForRowAtIndexPath:indexPath]];
        }else if (indexPath.row == 3){
            NewMachineView *vc = (NewMachineView *)[[[self.storyboard instantiateViewControllerWithIdentifier:@"NewMachineView"] viewControllers] lastObject];
            vc.machineLocation = _currentLocation;
            [self.navigationController presentViewController:vc.parentViewController animated:YES completion:nil];
        }
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"MapView"]){
        MapView *mapView = segue.destinationViewController;
        mapView.currentLocation = _currentLocation;
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1){
        return YES;
    }
    return NO;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Update";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        MachineConditionView *vc = (MachineConditionView *)[[[self.storyboard instantiateViewControllerWithIdentifier:@"MachineCondition"] viewControllers] lastObject];
        vc.currentMachine = machines[indexPath.row];
        [tableView setEditing:NO];
        [self.navigationController presentViewController:vc.parentViewController animated:YES completion:nil];
    }
}

@end
