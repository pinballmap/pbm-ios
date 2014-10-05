//
//  RegionProfileView.m
//  PinballMap
//
//  Created by Frank Michael on 10/5/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "RegionProfileView.h"
#import "UIAlertView+Application.h"
#import "RegionLink.h"

@interface RegionProfileView ()

@property (nonatomic) Region *currentRegion;
@property (nonatomic) NSMutableArray *regionLinks;
@property (nonatomic) NSString *regionMOTD;

- (IBAction)showAbout:(id)sender;

@end

@implementation RegionProfileView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(showAbout:)];
    self.navigationItem.leftBarButtonItem = aboutButton;
    UIBarButtonItem *changeRegionButton = [[UIBarButtonItem alloc] initWithTitle:@"Change" style:UIBarButtonItemStylePlain target:self action:@selector(changeRegion:)];
    self.navigationItem.rightBarButtonItem = changeRegionButton;
    
    self.currentRegion = [[PinballMapManager sharedInstance] currentRegion];
    self.navigationItem.title = self.currentRegion.fullName;
    
    self.regionLinks = [NSMutableArray new];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshRegionData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self refreshRegionData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)refreshRegionData{
    [[PinballMapManager sharedInstance] refreshBasicRegionData:^(NSDictionary *status) {
        if (status[@"errors"]){
            NSString *errors;
            if ([status[@"errors"] isKindOfClass:[NSArray class]]){
                errors = [status[@"errors"] componentsJoinedByString:@","];
            }else{
                errors = status[@"errors"];
            }
            [UIAlertView simpleApplicationAlertWithMessage:errors cancelButton:@"Ok"];
        }else{
            self.regionMOTD = status[@"region"][@"motd"];
            NSDictionary *links = status[@"region"][@"filtered_region_links"];
            [self.regionLinks removeAllObjects];
            
            [links enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *links, BOOL *stop) {
                NSMutableArray *linkCategories = [NSMutableArray new];
                for (NSDictionary *link in links) {
                    RegionLink *newLink = [[RegionLink alloc] initWithData:link];
                    [linkCategories addObject:newLink];
                }
                [self.regionLinks addObject:linkCategories];
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    }];
}
#pragma mark - Class Actions
- (IBAction)showAbout:(id)sender{
    
}
- (IBAction)changeRegion:(id)sender{
    
}
#pragma mark - TableView Datasource/Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // 0->MOTD
    // 1->Local Stuff
    // 2->High Scores
    return self.regionLinks.count+2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 1;
    }else if (section == 1){
        return 0;
    }else{
        return [self.regionLinks[section-2] count];
    }
    return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return @"Message of the Day";
    }else if (section == 1){
        return @"High Scores";
    }else{
        RegionLink *link = [self.regionLinks[section-2] firstObject];
        return link.category;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section > 1){
        RegionLink *link = [self.regionLinks[indexPath.section-2] objectAtIndex:indexPath.row];

        NSString *cellDetail = link.linkDescription;
        NSString *cellTitle = link.name;
        
        CGRect titleSize = [cellTitle boundingRectWithSize:CGSizeMake(290, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil];
        CGRect detailSize = [cellDetail boundingRectWithSize:CGSizeMake(290, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil];
        
        titleSize.size.height = titleSize.size.height+detailSize.size.height+10;   // Take into account the 10 points of padding within a cell.
        if (titleSize.size.height < 44){
            return 44;
        }else{
            return titleSize.size.height;
        }
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier;
    
    if (indexPath.section == 0){
        cellIdentifier = @"BasicCell";
    }else if (indexPath.section == 1){
        cellIdentifier = @"BasicCell";
    }else{
        cellIdentifier = @"DetailCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (indexPath.section == 0){
        cell.textLabel.text = self.regionMOTD;
    }else if (indexPath.section == 1){
        
    }else{
        RegionLink *link = [self.regionLinks[indexPath.section-2] objectAtIndex:indexPath.row];
        cell.detailTextLabel.numberOfLines = 0;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = link.name;
        cell.detailTextLabel.text = link.linkDescription;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
