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

@interface MachineProfileView ()

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
    
    self.navigationItem.title = _currentMachine.name;
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
        return 2;
    }else if (section == 1){
        return _currentMachine.machineLocations.count+1;
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
            MachineLocation *machine = _currentMachine.machineLocations[indexPath.row-1];
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
            cell.infoLabel.text = @"Manufacture";
            cell.dataLabel.text = _currentMachine.manufacturer;
        }else if (indexPath.row == 1){
            cell.infoLabel.text = @"Year";
            cell.dataLabel.text = [NSString stringWithFormat:@"%@",_currentMachine.year];
        }
        return cell;
    }else if (indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
        if (indexPath.row == 0){
            cell.textLabel.text = @"View on Map";
            cell.detailTextLabel.text = nil;
        }else if (indexPath.row > 0){
            MachineLocation *machine = _currentMachine.machineLocations[indexPath.row-1];
            cell.textLabel.text = machine.location.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",machine.location.street,machine.location.city];
        }
        return cell;

    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1){
        if (indexPath.row == 0){
            MapView *map = [self.storyboard instantiateViewControllerWithIdentifier:@"MapView"];
            map.currentMachine = _currentMachine;
            [self.navigationController pushViewController:map animated:YES];
        }else{
            MachineLocation *machine = _currentMachine.machineLocations[indexPath.row-1];
            LocationProfileView *locationProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationProfileView"];
            locationProfile.currentLocation = machine.location;
            [self.navigationController pushViewController:locationProfile animated:YES];
        }
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
