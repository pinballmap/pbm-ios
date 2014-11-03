//
//  RecentlyAddedView.m
//  PinballMap
//
//  Created by Frank Michael on 9/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "RecentlyAddedView.h"
#import "UIAlertView+Application.h"
#import "RecentMachine.h"
#import "LocationProfileView.h"

@interface RecentlyAddedView ()

@property (nonatomic) NSMutableArray *recentMachines;

@end

@implementation RecentlyAddedView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recentMachines = [NSMutableArray new];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    [[PinballMapManager sharedInstance] recentlyAddedMachinesWithCompletion:^(NSDictionary *status) {
        if (status[@"errors"]){
            NSString *errors;
            if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                errors = [status[@"errors"] componentsJoinedByString:@","];
            }else{
                errors = status[@"errors"];
            }
            [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
        }else{
            NSArray *recentMachines = status[@"location_machine_xrefs"];
            NSMutableArray *recentMachinesObj = [NSMutableArray new];
            [recentMachines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                RecentMachine *machine = [[RecentMachine alloc] initWithData:obj];
                if (machine != nil && machine.location){
                    [recentMachinesObj addObject:machine];
                }
            }];
            [self.recentMachines removeAllObjects];
            [self.recentMachines addObjectsFromArray:[recentMachinesObj sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdOn" ascending:NO]]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Class Actions
- (IBAction)dismissView:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - TableView Datasource/Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.recentMachines.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecentMachine *recentMachine = self.recentMachines[indexPath.row];
    
    CGRect stringSize = [recentMachine.displayText boundingRectWithSize:CGSizeMake(290, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    stringSize.size.height = stringSize.size.height+20;   // Take into account the 10 points of padding within a cell.
    if (stringSize.size.height < 44){
        return 44;
    }else{
        return stringSize.size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"RecentMachineCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    RecentMachine *machine = [self.recentMachines objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.attributedText = machine.displayText;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)",machine.location.name,machine.location.city];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RecentMachine *machine = [self.recentMachines objectAtIndex:indexPath.row];
    LocationProfileView *profileView = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationProfileView"];
    profileView.currentLocation = machine.location;
    profileView.showMapSnapshot = true;
    
    [self.navigationController pushViewController:profileView animated:YES];
    
}

@end
