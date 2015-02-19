//
//  LocationProfileView.m
//  PinballMap
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "LocationProfileView.h"
@import CoreLocation;
@import MapKit;
@import AddressBook;
#import "InformationCell.h"
#import "LocationMapCell.h"
#import "Machine.h"
#import "MapView.h"
#import "MachineConditionView.h"
#import "NewMachineLocationView.h"
#import "NSDate+DateFormatting.h"
#import "InputCell.h"
#import "MachineProfileView.h"
#import "TextEditorView.h"
#import "ReuseWebView.h"
#import "UIAlertView+Application.h"
#import "LocationTypesView.h"
#import "MachineLocationProfileView.h"
#import "UIDevice+Model.h"
#import "Location+Annotation.h"

typedef enum : NSUInteger {
    LocationEditingTypePhone,
    LocationEditingTypeDescription,
    LocationEditingTypeWebsite,
} LocationEditingType;

@interface LocationProfileView () <TextEditorDelegate,NSFetchedResultsControllerDelegate,UIAlertViewDelegate,LocationTypeSelectDelegate>

@property (nonatomic) NSFetchedResultsController *machinesFetch;
@property (nonatomic) UIImage *mapSnapshot;
@property (nonatomic) LocationEditingType editingType;
@property (nonatomic) UIAlertView *deleteConfirm;
@property (nonatomic) NSIndexPath *deletePath;
@property (nonatomic) UISegmentedControl *dataSetSeg;
@property (nonatomic) UIAlertView *openInMapsConfirm;

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

    // Sort the machines by name.
    self.dataSetSeg = [[UISegmentedControl alloc] init];
    self.dataSetSeg.translatesAutoresizingMaskIntoConstraints = NO;
    self.dataSetSeg.frame = CGRectMake(0, 0, self.view.frame.size.width+10, 29);
    [self.dataSetSeg insertSegmentWithTitle:@"Machines" atIndex:0 animated:YES];
    [self.dataSetSeg insertSegmentWithTitle:@"Info" atIndex:1 animated:YES];
    [self.dataSetSeg addTarget:self action:@selector(changeData:) forControlEvents:UIControlEventValueChanged];
    [self.dataSetSeg setSelectedSegmentIndex:0];

    if (_currentLocation){
        [self setupUI];
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class
- (void)setupUI{
    self.navigationItem.title = _currentLocation.name;

    NSFetchRequest *locationMachines = [NSFetchRequest fetchRequestWithEntityName:@"MachineLocation"];
    locationMachines.predicate = [NSPredicate predicateWithFormat:@"location.locationId = %@",_currentLocation.locationId];
    locationMachines.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"machine.name" ascending:YES]];
    self.machinesFetch = nil;
    self.machinesFetch = [[NSFetchedResultsController alloc] initWithFetchRequest:locationMachines managedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    self.machinesFetch.delegate = self;
    [self.machinesFetch performFetch:nil];
    self.dataSetSeg.selectedSegmentIndex = 0;
    self.tableView.allowsSelectionDuringEditing = YES;
    [self setupRightBarButton];
    [self.tableView reloadData];
}
- (void)setupRightBarButton{
    if (_currentLocation){
        if (![UIDevice iPad]){
            if (self.dataSetSeg.selectedSegmentIndex == 0){
                UIBarButtonItem *addMachine = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewMachine:)];
                if ([UIDevice currentModel] == ModelTypeiPad){
                    self.parentViewController.navigationItem.rightBarButtonItem = addMachine;
                }else{
                    self.navigationItem.rightBarButtonItem = addMachine;
                }
            }else{
                UIBarButtonItem *editLocation = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editLocation:)];
                if ([UIDevice currentModel] == ModelTypeiPad){
                    self.parentViewController.navigationItem.rightBarButtonItem = editLocation;
                }else{
                    self.navigationItem.rightBarButtonItem = editLocation;
                }
            }
        }else{
            if (self.tableView.editing){
                UIBarButtonItem *editLocation = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editLocation:)];
                UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                fixedSpace.width = 250.0;
                
                self.parentViewController.navigationItem.rightBarButtonItems = nil;
                self.parentViewController.navigationItem.rightBarButtonItems = @[fixedSpace,editLocation];
            }else{
                UIBarButtonItem *addMachine = [[UIBarButtonItem alloc] initWithTitle:@"Add Machine" style:UIBarButtonItemStylePlain target:self action:@selector(addNewMachine:)];
                
                UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                fixedSpace.width = 160.0;
                UIBarButtonItem *editLocation = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editLocation:)];
                self.parentViewController.navigationItem.rightBarButtonItems = @[addMachine,fixedSpace,editLocation];
            }
        }
    }else{
        if ([UIDevice iPad]){
            self.parentViewController.navigationItem.rightBarButtonItems = nil;
        }
    }
}
- (void)showMap{
    MapView *map = [[[[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"MapView"] viewControllers] lastObject];
    map.currentLocation = _currentLocation;
    [self.navigationController pushViewController:map animated:YES];
}
- (void)setCurrentLocation:(Location *)currentLocation{
    _currentLocation = currentLocation;
    self.mapSnapshot = nil;
    [self setupUI];
}
#pragma mark - Class Actions
- (IBAction)changeData:(id)sender{
    [self.tableView setEditing:NO];
    [self setupRightBarButton];
    [self.tableView reloadData];
}
- (IBAction)addNewMachine:(id)sender{
    NewMachineLocationView *vc = (NewMachineLocationView *)[[[[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"NewMachineLocationView"] viewControllers] lastObject];
    vc.location = _currentLocation;
    [self.navigationController presentViewController:vc.parentViewController animated:YES completion:nil];
}
- (IBAction)editLocation:(id)sender{
    [self.dataSetSeg setSelectedSegmentIndex:1];
    BOOL editing = YES;
    if (self.tableView.editing){
        editing = NO;
    }
    [self.tableView setEditing:editing];
    [self setupRightBarButton];
    [self.tableView reloadData];
}
#pragma mark - TextEditor Delegate
- (void)editorDidComplete:(NSString *)text{
    NSDictionary *editedData;
    switch (self.editingType) {
        case LocationEditingTypeWebsite:
            editedData = @{@"website": text};
            break;
        case LocationEditingTypeDescription:
            editedData = @{@"description": text};
            break;
        case LocationEditingTypePhone:
            editedData = @{@"phone": text};
            break;
        default:
            break;
    }
    [[PinballMapManager sharedInstance] updateLocation:_currentLocation withData:editedData andCompletion:^(NSDictionary *status) {
        if (status[@"errors"]){
            NSString *errors;
            if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                errors = [status[@"errors"] componentsJoinedByString:@","];
            }else{
                errors = status[@"errors"];
            }
            [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
        }else{
            switch (self.editingType) {
                case LocationEditingTypeWebsite:
                    _currentLocation.website = text;
                    break;
                case LocationEditingTypeDescription:
                    _currentLocation.locationDescription = text;
                    break;
                case LocationEditingTypePhone:
                    _currentLocation.phone = text;
                    break;
                default:
                    break;
            }
            self.editingType = -1;
            [[CoreDataManager sharedInstance] saveContext];
            [self.tableView setEditing:NO];
            if ([UIDevice currentModel] == ModelTypeiPhone){
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            }else{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }];
    
}
- (void)editorDidCancel{
    
}
#pragma mark - Locaiton Type Delegate
- (void)selectedLocationType:(LocationType *)type{
    if (type){
        [[PinballMapManager sharedInstance] updateLocation:_currentLocation withData:@{@"location_type": type.locationTypeId} andCompletion:^(NSDictionary *status) {
            _currentLocation.locationType = type;
            [[CoreDataManager sharedInstance] saveContext];
            [self.tableView reloadData];
        }];
    }
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex){
        if (alertView == self.deleteConfirm){
            MachineLocation *machine = [self.machinesFetch objectAtIndexPath:[NSIndexPath indexPathForItem:self.deletePath.row inSection:0]];
            [[PinballMapManager sharedInstance] removeMachine:machine withCompletion:^(NSDictionary *status) {
                if (status[@"errors"]){
                    NSString *errors;
                    if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                        errors = [status[@"errors"] componentsJoinedByString:@","];
                    }else{
                        errors = status[@"errors"];
                    }
                    [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
                }else{
                    [[[CoreDataManager sharedInstance] managedObjectContext] deleteObject:machine];
                    [[CoreDataManager sharedInstance] saveContext];
                    self.deletePath = nil;
                    [UIAlertView simpleApplicationAlertWithMessage:@"Removed machine!" cancelButton:@"Ok"];
                }
            }];
        }else if (alertView == self.openInMapsConfirm){
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([_currentLocation.latitude doubleValue],[_currentLocation.longitude doubleValue]);
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[_currentLocation.street,_currentLocation.city,_currentLocation.state,_currentLocation.zip] forKeys:[NSArray arrayWithObjects:(NSString *)kABPersonAddressStreetKey,kABPersonAddressCityKey,kABPersonAddressStateKey,kABPersonAddressZIPKey, nil]];
            
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:dic];
            MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
            [MKMapItem openMapsWithItems:@[item] launchOptions:nil];
        }
    }
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_currentLocation){
        if (self.showMapSnapshot){
            return 2;
        }else{
            return 1;
        }
    }
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 && self.showMapSnapshot){
        return 1;
    }else{
        if (self.dataSetSeg.selectedSegmentIndex == 0){
            NSInteger rows = 0;
            if ([[self.machinesFetch sections] count] > 0) {
                id <NSFetchedResultsSectionInfo> sectionInfo = [[self.machinesFetch sections] objectAtIndex:0];
                rows = [sectionInfo numberOfObjects];
            }
            return rows;
        }else if (self.dataSetSeg.selectedSegmentIndex == 1){
            return 5;
        }
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    // Set a height for the seg control if the section is 1, meaning we are showing a map snapshot, or if section is 0
    if (section == 1 || (section == 0 && !self.showMapSnapshot)){
        return 29;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1 || (section == 0 && !self.showMapSnapshot)){
        UIView *dataSegView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 29)];
        [dataSegView setBackgroundColor:[UIColor whiteColor]];
        [dataSegView addSubview:self.dataSetSeg];
        if (self.dataSetSeg){
            NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-5)-[seg]-(-5)-|" options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"seg": self.dataSetSeg}];
            [dataSegView addConstraints:verticalConstraints];
        }
        return dataSegView;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && self.showMapSnapshot){
        // Map image.
        return 122;
    }else{
        if (self.dataSetSeg.selectedSegmentIndex == 0){
            MachineLocation *currentMachine = [self.machinesFetch objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            CGRect titleLabel = [currentMachine.machine.machineTitle boundingRectWithSize:CGSizeMake(238, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            CGRect detailLabel = [currentMachine.conditionWithUpdateDate boundingRectWithSize:CGSizeMake(238, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil];
            if ([currentMachine.condition rangeOfString:@"N/A" options:NSCaseInsensitiveSearch].location != NSNotFound || currentMachine.condition == nil || currentMachine.condition.length == 0){
                detailLabel = CGRectMake(0, 0, 0, 0);
            }
            // Add 6 pixel padding present in subtitle style.
            CGRect stringSize = CGRectMake(0, 0, 238, titleLabel.size.height+detailLabel.size.height+6);

            if (stringSize.size.height+10 < 44){
                return 44;
            }else{
                return stringSize.size.height+10;
            }
        }else if (self.dataSetSeg.selectedSegmentIndex == 1){
            NSString *detailText;
            if (indexPath.row == 0){
                detailText = _currentLocation.fullAddress;
            }else if (indexPath.row == 1){
                detailText = _currentLocation.phone;
            }else if (indexPath.row == 2){
                detailText = _currentLocation.website;
            }else if (indexPath.row == 3){
                detailText = _currentLocation.locationType.name;
            }else if (indexPath.row == 4){
                detailText = _currentLocation.locationDescription;
            }
            
            CGRect textLabel = [detailText boundingRectWithSize:CGSizeMake(280, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]} context:nil];
            textLabel.size.height = textLabel.size.height+45;
            if (textLabel.size.height <= 67){
                return 67;
            }
            return textLabel.size.height;
            
        }
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && self.showMapSnapshot){
        // Map Cell
        LocationMapCell *cell = (LocationMapCell *)[tableView dequeueReusableCellWithIdentifier:@"MapCell" forIndexPath:indexPath];
        [cell setCurrentLocation:self.currentLocation];
        return cell;
    }else{
        if (self.dataSetSeg.selectedSegmentIndex == 0){
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MachineCell"];
            // Machine cell.
            MachineLocation *currentMachine = [self.machinesFetch objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            cell.textLabel.attributedText = currentMachine.machine.machineTitle;
            cell.detailTextLabel.numberOfLines = 0;
            if (currentMachine.condition != nil && currentMachine.condition.length > 0 && [currentMachine.condition rangeOfString:@"N/A" options:NSCaseInsensitiveSearch].location == NSNotFound){
                cell.detailTextLabel.text = currentMachine.conditionWithUpdateDate;
            }else{
                cell.detailTextLabel.text = @"";
            }
            return cell;
            
        }else if (self.dataSetSeg.selectedSegmentIndex == 1){
            // Profile data with InfoCell
            InformationCell *cell = (InformationCell *)[tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
            cell.dataLabel.numberOfLines = 0;
            if (indexPath.row == 0){
                if ([_currentLocation.currentDistance isEqual:@(0)]){
                    cell.infoLabel.text = @"Address";
                }else{
                    cell.infoLabel.text = [NSString stringWithFormat:@"Address (%.02f miles)",[_currentLocation.currentDistance floatValue]];
                }
                cell.dataLabel.text = _currentLocation.fullAddress;
            }else if (indexPath.row == 1){
                cell.infoLabel.text = @"Phone";
                cell.dataLabel.text = _currentLocation.phone;
            }else if (indexPath.row == 2){
                cell.infoLabel.text = @"Website";
                cell.dataLabel.text = _currentLocation.website;
            }else if (indexPath.row == 3){
                cell.infoLabel.text = @"Type";
                if (!_currentLocation.locationType || [_currentLocation.locationType.name isEqualToString:@"Unclassified"]){
                    cell.dataLabel.text = @"Tap to edit";
                }else{
                    cell.dataLabel.text = _currentLocation.locationType.name;
                }
            }else  if (indexPath.row == 4){
                cell.infoLabel.text = @"Description";
                cell.dataLabel.text = _currentLocation.locationDescription;
            }
            [cell.dataLabel updateConstraints];

            return cell;
        }
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && self.showMapSnapshot){
        [self showMap];
    }else{
        
        
        if (self.dataSetSeg.selectedSegmentIndex == 0){
            MachineLocationProfileView *vc = [[[[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"MachineLocationProfileView"] viewControllers] lastObject];
            vc.currentMachine = [self.machinesFetch objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            [tableView setEditing:NO];
            if ([UIDevice currentModel] == ModelTypeiPad){
                [self.parentViewController presentViewController:vc.parentViewController animated:YES completion:nil];
            }else{
                [self.navigationController presentViewController:vc.parentViewController animated:YES completion:nil];
            }
        }else if (self.dataSetSeg.selectedSegmentIndex == 1){
            if (indexPath.row == 0){
                // Address
                if ([UIDevice currentModel] == ModelTypeiPhone){
                    [self showMap];
                }else{
                    self.openInMapsConfirm = [UIAlertView applicationAlertWithMessage:@"Do you want to open this location in Maps?" delegate:self cancelButton:@"No" otherButtons:@"Yes", nil];
                    [self.openInMapsConfirm show];
                }
            }else if (indexPath.row == 1){
                // Phone
                if (_currentLocation.phone.length > 0 && ![_currentLocation.phone isEqualToString:@"Tap to edit"] && !self.tableView.editing){
                    NSString *contactsPhoneNumber = [@"tel:" stringByAppendingString:_currentLocation.phone];
                    contactsPhoneNumber = [contactsPhoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                    contactsPhoneNumber = [contactsPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    contactsPhoneNumber = [contactsPhoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
                    contactsPhoneNumber = [contactsPhoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];

                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contactsPhoneNumber]];
                }else{
                    TextEditorView *editor = [[[[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"TextEditorView"] viewControllers] lastObject];
                    editor.delegate = self;
                    editor.editorTitle = @"Location Phone";
                    if (![_currentLocation.phone isEqualToString:@"Tap to edit"]){
                        editor.textContent = _currentLocation.phone;
                    }
                    self.editingType = LocationEditingTypePhone;
                    if ([UIDevice currentModel] == ModelTypeiPad){
                        [self.parentViewController.navigationController presentViewController:editor.parentViewController animated:YES completion:nil];
                    }else{
                        [self.navigationController presentViewController:editor.parentViewController animated:YES completion:nil];
                    }
                }
            }else if (indexPath.row == 2){
                // Website
                if (_currentLocation.website.length > 0 && ![_currentLocation.website isEqualToString:@"N/A"] && !self.tableView.editing){
                    if ([_currentLocation.website rangeOfString:@"facebook.com"].location != NSNotFound){
                        // Facebook links should open in Safari
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_currentLocation.website]];
                    }else{
                        ReuseWebView *webView = [[ReuseWebView alloc] initWithURL:[NSURL URLWithString:_currentLocation.website]];
                        webView.webTitle = _currentLocation.name;
                        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webView];
                        navController.modalPresentationStyle = UIModalPresentationFormSheet;
                        if ([UIDevice currentModel] == ModelTypeiPad){
                            [self.parentViewController.navigationController presentViewController:navController animated:YES completion:nil];
                        }else{
                            [self.navigationController presentViewController:navController animated:YES completion:nil];
                        }
                    }
                }
            }
            else if (indexPath.row == 3){
                // Type
                LocationTypesView *typesView = (LocationTypesView *)[[[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"LocationTypesView"] navigationRootViewController];
                typesView.delegate = self;
                if ([UIDevice currentModel] == ModelTypeiPad){
                    [self.parentViewController.navigationController presentViewController:typesView.parentViewController animated:YES completion:nil];
                }else{
                    [self.navigationController presentViewController:typesView.parentViewController animated:YES completion:nil];
                }
            }else if (indexPath.row == 4){
                // Description
                TextEditorView *editor = [[[[UIStoryboard storyboardWithName:@"SecondaryControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"TextEditorView"] viewControllers] lastObject];
                editor.delegate = self;
                editor.editorTitle = @"Location Description";
                self.editingType = LocationEditingTypeDescription;
                if (![_currentLocation.locationDescription isEqualToString:@"Tap to edit"]){
                    editor.textContent = _currentLocation.locationDescription;
                }
                if ([UIDevice currentModel] == ModelTypeiPad){
                    [self.parentViewController.navigationController presentViewController:editor.parentViewController animated:YES completion:nil];
                }else{
                    [self.navigationController presentViewController:editor.parentViewController animated:YES completion:nil];
                }
            }
        }
        
        
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section == 1 && [UIDevice currentModel] == ModelTypeiPhone) || (indexPath.section == 0 && [UIDevice currentModel] == ModelTypeiPad)){
        if (self.dataSetSeg.selectedSegmentIndex == 1){
            return UITableViewCellEditingStyleInsert;
        }
    }
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section == 1 && [UIDevice currentModel] == ModelTypeiPhone) || (indexPath.section == 0 && [UIDevice currentModel] == ModelTypeiPad)){
        MachineLocation *currentMachine = [self.machinesFetch objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        if (currentMachine.machine != nil){
            MachineProfileView *machineProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"MachineProfile"];
            machineProfile.currentMachine = currentMachine.machine;
            if ([UIDevice currentModel] == ModelTypeiPad){
                machineProfile.isModal = YES;
                UINavigationController *machineNav = [[UINavigationController alloc] initWithRootViewController:machineProfile];
                machineNav.modalPresentationStyle = UIModalPresentationFormSheet;
                [self.parentViewController.navigationController presentViewController:machineNav animated:YES completion:nil];
            }else{
                [self.navigationController pushViewController:machineProfile animated:YES];
            }
        }else{
            [UIAlertView simpleApplicationAlertWithMessage:@"Invalid Machine Data. Try reloading your region data by going to the locations listing and pulling the list all the way down." cancelButton:@"Ok"];
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{    
    if ((indexPath.section == 1 && [UIDevice currentModel] == ModelTypeiPhone) || (indexPath.section == 0 && [UIDevice currentModel] == ModelTypeiPad)){
        if (self.dataSetSeg.selectedSegmentIndex == 0){
            return YES;
        }else{
            if (indexPath.row != 0 && indexPath.row != 2){
                return YES;
            }
        }
    }
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        self.deletePath = indexPath;
        self.deleteConfirm = [UIAlertView applicationAlertWithMessage:@"Are you sure you want to remove this machine." delegate:self cancelButton:@"No" otherButtons:@"Yes", nil];
        [self.deleteConfirm show];
    }
}
#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath{
    NSNumber *section = @1;
    if ([UIDevice currentModel] == ModelTypeiPad){
        section = @0;
    }
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:newIndexPath.row inSection:section.intValue]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:section.intValue]] withRowAnimation:UITableViewRowAnimationFade];
            break;            
        case NSFetchedResultsChangeUpdate:
            if (self.dataSetSeg.selectedSegmentIndex == 0){
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:section.intValue]] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
        case NSFetchedResultsChangeMove:
            break;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

@end
