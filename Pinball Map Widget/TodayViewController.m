//
//  TodayViewController.m
//  Pinball Map Widget
//
//  Created by Frank Michael on 10/5/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

NSString * const apiRootURL = @"http://pinballmap.com/";
NSString * const appGroup = @"group.net.isaacruiz.ppm";

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic) NSString *regionName;
@property (nonatomic) NSMutableArray *recentMachines;

+ (NSUserDefaults *)userDefaultsForApp;

@end

@implementation TodayViewController

- (void)viewDidLoad {
//    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *regionInfo = [[TodayViewController userDefaultsForApp] objectForKey:@"CurrentRegion"];
    self.regionName = regionInfo[@"name"];
    self.regionName = @"seattle";
    self.recentMachines = [NSMutableArray new];

    self.preferredContentSize = self.tableView.contentSize;
    self.tableView.backgroundColor = [UIColor clearColor];
}
+ (NSUserDefaults *)userDefaultsForApp{
    return [[NSUserDefaults alloc] initWithSuiteName:appGroup];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)refreshRecentlyWithCompletion:(void (^)(BOOL shouldReload))block{
    NSURL *recentURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/region/%@/location_machine_xrefs.json?limit=5",apiRootURL,self.regionName]];
    NSURLRequest *recentRequest = [NSURLRequest requestWithURL:recentURL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *recentTask = [session dataTaskWithRequest:recentRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error){
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSArray *machines = jsonData[@"location_machine_xrefs"];
            
            NSMutableArray *recentMachinesObj = [NSMutableArray new];
            for (NSDictionary *machine in machines) {
                
                NSDictionary *locationData = machine[@"location"];
                NSDictionary *machineData = machine[@"machine"];
                
                NSMutableAttributedString *displayText = [[NSMutableAttributedString alloc] initWithString:machineData[@"name"] attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16]}];
                [displayText appendAttributedString:[[NSAttributedString alloc] initWithString:@" was added to " attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}]];
                [displayText appendAttributedString:[[NSAttributedString alloc] initWithString:locationData[@"name"] attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16]}]];
                [displayText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)",locationData[@"city"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}]];
                                                                                                                                             
                
                
                NSString *createdOn = machine[@"created_at"];
                
                NSDictionary *recentMachine = @{
                                                @"displayText": displayText,
                                                @"craetedOn": createdOn
                                              };
                
                [recentMachinesObj addObject:recentMachine];
            }
            [self.recentMachines removeAllObjects];
            [self.recentMachines addObjectsFromArray:[recentMachinesObj sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdOn" ascending:NO]]]];
            block(true);
        }else{
            block(false);
        }
    }];
    [recentTask resume];
}
#pragma mark - NCWidget Delegate
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    [self refreshRecentlyWithCompletion:^(BOOL shouldReload) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.preferredContentSize = self.tableView.contentSize;
            completionHandler(NCUpdateResultNewData);
        });
    }];
    
    
    
}
#pragma mark - TableView Datasource/Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.recentMachines.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *recentMachine = self.recentMachines[indexPath.row];
    NSAttributedString *cellTitle = recentMachine[@"displayText"];

//    CGRect stringSize = [cellTitle boundingRectWithSize:CGSizeMake(290, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil];
    CGRect stringSize = [cellTitle boundingRectWithSize:CGSizeMake(290, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];

    stringSize.size.height = stringSize.size.height+10;   // Take into account the 10 points of padding within a cell.
    if (stringSize.size.height < 44){
        return 44;
    }else{
        return stringSize.size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"BasicCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSDictionary *recentMachine = self.recentMachines[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.attributedText = recentMachine[@"displayText"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
