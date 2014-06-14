//
//  MachineProfileView.m
//  Pinball
//
//  Created by Frank Michael on 4/13/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "MachineProfileView.h"
#import "MachineLocation.h"
#import "InformationCell.h"
#import "MapView.h"
#import "LocationProfileView.h"
#import <ReuseWebView.h>
#import "LocationProfileView-iPad.h"

@interface MachineProfileView () {
    NSArray *machineLocations;
}

@end

@implementation MachineProfileView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (_currentMachine){
        [self setupUI];
    }
    
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class
- (void)setupUI{
    self.navigationItem.title = _currentMachine.name;

    NSFetchRequest *locationRequest = [NSFetchRequest fetchRequestWithEntityName:@"MachineLocation"];
    locationRequest.predicate = [NSPredicate predicateWithFormat:@"location.region = %@ AND machine = %@" argumentArray:@[[[PinballManager sharedInstance] currentRegion],_currentMachine]];
    locationRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"location.name" ascending:YES]];
    machineLocations = [[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:locationRequest error:nil];
    [self.tableView reloadData];
    
}
- (void)setCurrentMachine:(Machine *)currentMachine{
    _currentMachine = currentMachine;
    [self setupUI];
}
- (void)setIsModal:(BOOL)isModal{
    _isModal = isModal;
    if (_isModal){
        UIBarButtonItem *dismiss = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissProfile:)];
        self.navigationItem.leftBarButtonItem = dismiss;
    }
}
- (IBAction)dismissProfile:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_currentMachine){
        return 2;
    }else{
        return 0;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 3;
    }else if (section == 1){
        return machineLocations.count+1;
    }
    return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return @"Machine";
    }else if (section == 1){
        return @"Locations";
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 67;
    }else{
        if (indexPath.section == 1 && indexPath.row > 0){
            MachineLocation *machine = machineLocations[indexPath.row-1];
            CGRect stringSize = [machine.location.name boundingRectWithSize:CGSizeMake(290, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil];
            
            stringSize.size.height = stringSize.size.height+10;   // Take into account the 10 points of padding within a cell.
            if (stringSize.size.height+10 < 44){
                return 44;
            }else{
                return stringSize.size.height+10;
            }
        }else{
            return 44;
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        InformationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
        if (indexPath.row == 0){
            cell.infoLabel.text = @"Manufacturer";
            cell.dataLabel.text = _currentMachine.manufacturer;
        }else if (indexPath.row == 1){
            cell.infoLabel.text = @"Year";
            cell.dataLabel.text = [NSString stringWithFormat:@"%@",_currentMachine.year];
        }else if (indexPath.row == 2){
            cell.infoLabel.text = @"Internet Pinball Database";
            if (![_currentMachine.ipdbLink isEqualToString:@"N/A"]){
                cell.dataLabel.text = @"View";
            }else{
                cell.dataLabel.text = @"N/A";
            }
        }
        [cell.dataLabel updateConstraints];
        return cell;
    }else if (indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
        if (indexPath.row == 0){
            cell.textLabel.text = @"View on Map";
            cell.detailTextLabel.text = nil;
        }else if (indexPath.row > 0){
            MachineLocation *machine = machineLocations[indexPath.row-1];
            cell.textLabel.text = machine.location.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",machine.location.street,machine.location.city];
        }
        return cell;

    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        if (indexPath.row == 2){
            ReuseWebView *webView = [[ReuseWebView alloc] initWithURL:[NSURL URLWithString:_currentMachine.ipdbLink]];
            webView.webTitle = @"IPDB";
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webView];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0){
            MapView *map = [[[self.storyboard instantiateViewControllerWithIdentifier:@"MapView"] viewControllers] lastObject];
            map.currentMachine = _currentMachine;
            [self.navigationController presentViewController:map.parentViewController animated:YES completion:nil];
        }else{
            MachineLocation *machine = machineLocations[indexPath.row-1];
            if (![UIDevice iPad]){
                LocationProfileView *locationProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationProfileView"];
                locationProfile.currentLocation = machine.location;
                [self.navigationController pushViewController:locationProfile animated:YES];
            }else{
                [self.tabBarController setSelectedIndex:0];
                LocationProfileView_iPad *locationView = (LocationProfileView_iPad *)[[self.tabBarController.viewControllers firstObject] navigationRootViewController];
                [locationView setCurrentLocation:machine.location];
            }
        }
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

}

@end
