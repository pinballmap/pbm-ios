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
#import "NSDate+DateFormatting.h"
#import "InputCell.h"

@interface LocationProfileView () {
    NSArray *machines;
    UIImage *mapSnapshot;
    BOOL isEditing;
}
- (IBAction)editLocation:(id)sender;
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
#pragma mark - Class Actions
- (IBAction)editLocation:(id)sender{
    if (!isEditing){
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editLocation:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveLocation:)];
        self.navigationItem.rightBarButtonItem = saveButton;
        isEditing = YES;
        [self.tableView setScrollEnabled:NO];
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0],[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }else{
        isEditing = NO;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = NO;
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editLocation:)];
        self.navigationItem.rightBarButtonItem = editButton;
        [self.tableView setScrollEnabled:YES];
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0],[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}
- (IBAction)saveLocation:(id)sender{
    #pragma message("TODO: API interaction to save new location information")
    [self editLocation:nil];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (isEditing){
        return 1;
    }else{
        return 2;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isEditing){
        return 3;
    }else{
        if (section == 0){
            return 5;
        }else{
            return [_currentLocation.machineCount integerValue];
        }
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isEditing){
        return 44;
    }else{
        if (indexPath.section == 0){
            if (indexPath.row  == 3){
                return 122;
            }else if (indexPath.row == 2){
                CGRect textLabel = [_currentLocation.locationDescription boundingRectWithSize:CGSizeMake(280, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]} context:nil];
                textLabel.size.height = textLabel.size.height+45;
                if (textLabel.size.height <= 67){
                    return 67;
                }
                return textLabel.size.height;
            }else{
                return 67;
            }
        }else if (indexPath.section == 1){
            MachineLocation *currentMachine = machines[indexPath.row];
            NSString *cellTitle = currentMachine.machine.name;
            NSString *cellDetail = [NSString stringWithFormat:@"%@ updated on %@",currentMachine.condition,[currentMachine.conditionUpdate monthDayYearPretty:YES]];
            
            CGRect textLabel = [cellTitle boundingRectWithSize:CGSizeMake(290, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil];
            CGRect detailLabel = [cellDetail boundingRectWithSize:CGSizeMake(290, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil];
            // Add 6 pixel padding present in subtitle style.
            CGRect stringSize = CGRectMake(0, 0, 290, textLabel.size.height+detailLabel.size.height+6);

            if (stringSize.size.height+10 < 44){
                return 44;
            }else{
                return stringSize.size.height+10;
            }
        }
    }
    return 44;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (isEditing){
        return [NSString stringWithFormat:@"Edit %@",_currentLocation.name];
    }else{
        if (section == 0){
            return _currentLocation.name;
        }else if (section == 1){
            return [NSString stringWithFormat:@"Machines: %@\n(Swipe to update condition)",_currentLocation.machineCount];
        }
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isEditing){
        InputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InputCell"];
        cell.inputField.keyboardType = UIKeyboardTypeDefault;
        if (indexPath.row == 0){
            cell.inputField.placeholder = @"Phone";
            cell.inputField.keyboardType = UIKeyboardTypeNamePhonePad;
            if (![_currentLocation.phone isEqualToString:@"N/A"]){
                cell.inputField.text = _currentLocation.phone;
            }
        }else if (indexPath.row == 1){
            cell.inputField.placeholder = @"Location";
            if (![_currentLocation.street isEqualToString:@"N/A"]){
                cell.inputField.text = [NSString stringWithFormat:@"%@, %@, %@",_currentLocation.street,_currentLocation.state,_currentLocation.zip];
            }
        }else if (indexPath.row == 2){
            cell.inputField.placeholder = @"Description";
            if (![_currentLocation.locationDescription isEqualToString:@"N/A"]){
                cell.inputField.text = _currentLocation.locationDescription;
            }
        }

        return cell;
    }else{
        if (indexPath.section == 0){
            if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2){
                InformationCell *cell = (InformationCell *)[tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
                if (indexPath.row == 0){
                    cell.infoLabel.text = @"Phone";
                    cell.dataLabel.text = _currentLocation.phone;
                }else if (indexPath.row == 1){
                    cell.infoLabel.text = @"Location";
                    cell.dataLabel.text = _currentLocation.street;
                }else if (indexPath.row == 2){
                    cell.infoLabel.text = @"Description";
                    cell.dataLabel.text = _currentLocation.locationDescription;
                }
                return cell;
            }else if (indexPath.row == 3){
                LocationMapCell *cell = (LocationMapCell *)[tableView dequeueReusableCellWithIdentifier:@"MapCell" forIndexPath:indexPath];
                if (!mapSnapshot){
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
                            mapSnapshot = snapshot.image;
                            [cell addAnnotation];
                        }
                    }];
                }else{
                    cell.mapImage.image = mapSnapshot;
                }
                return cell;
            }else if (indexPath.row == 4){
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MachineCell" forIndexPath:indexPath];
                cell.textLabel.text = @"Add Machine";
                cell.detailTextLabel.text = nil;
                return cell;
            }
        }else if (indexPath.section == 1){
            MachineLocation *currentMachine = machines[indexPath.row];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MachineCell" forIndexPath:indexPath];
            cell.textLabel.text = currentMachine.machine.name;
            cell.detailTextLabel.numberOfLines = 0;
            // If no condition is available, just don't set the detail text label.
            if (![currentMachine.condition isEqualToString:@"N/A"]){
                if (currentMachine.conditionUpdate){
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ updated on %@",currentMachine.condition,[currentMachine.conditionUpdate monthDayYearPretty:YES]];
                }else{
                    cell.detailTextLabel.text = currentMachine.condition;
                }
            }else{
                cell.detailTextLabel.text = nil;
            }
            return cell;
        }
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
        }else if (indexPath.row == 4){
            NewMachineView *vc = (NewMachineView *)[[[self.storyboard instantiateViewControllerWithIdentifier:@"NewMachineView"] viewControllers] lastObject];
            vc.location = _currentLocation;
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
