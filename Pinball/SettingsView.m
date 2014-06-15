//
//  SettingsView.m
//  PinballMap
//
//  Created by Frank Michael on 4/14/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "SettingsView.h"

@interface SettingsView () {
    IBOutlet UILabel *regionLabel;
}
- (void)updateRegion;
@end

@implementation SettingsView

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRegion) name:@"RegionUpdate" object:nil];
    [self updateRegion];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)updateRegion{
    regionLabel.text = [[[PinballMapManager sharedInstance] currentRegion] fullName];
}
#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

@end
