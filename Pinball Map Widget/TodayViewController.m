//
//  TodayViewController.m
//  Pinball Map Widget
//
//  Created by Frank Michael on 10/5/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "CoreDataManager.h"
#import "NSDate+CupertinoYankee.h"
#import "Event.h"
#import "Event+CellHelpers.h"

NSString * const apiRootURL = @"https://pinballmap.com/";
NSString * const appGroup = @"group.net.isaacruiz.ppm";
NSString * const etagKey = @"recentsEtag";

@interface TodayViewController () <NCWidgetProviding>
@property (weak, nonatomic) IBOutlet UISegmentedControl *dataType;

@property (nonatomic) NSString *regionName;
@property (nonatomic) NSMutableArray *recentMachines;
@property (nonatomic) NSMutableArray *events;

+ (NSUserDefaults *)userDefaultsForApp;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *regionInfo = [[TodayViewController userDefaultsForApp] objectForKey:@"CurrentRegion"];
    self.regionName = regionInfo[@"name"];
    self.events = [NSMutableArray new];

    NSLog(@"%@",[[CoreDataManager sharedInstance] managedObjectContext]);
    
    NSFetchRequest *eventsFetch = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    eventsFetch.predicate = [NSPredicate predicateWithFormat:@"region.name = %@ AND startDate >= %@",self.regionName,[[NSDate date] endOfDay]];
    eventsFetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:true]];
    eventsFetch.fetchLimit = 5;
    [self.events addObjectsFromArray:[[[CoreDataManager sharedInstance] managedObjectContext] executeFetchRequest:eventsFetch error:nil]];

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
            NSString *recentsEtag = [(NSHTTPURLResponse *)response allHeaderFields][@"Etag"];
            NSString *pastEtag = [[TodayViewController userDefaultsForApp] objectForKey:etagKey];
            
            NSData *recentsData;
            if (![recentsEtag isEqualToString:pastEtag]){
                [[TodayViewController userDefaultsForApp] setObject:recentsEtag forKey:etagKey];
                [[TodayViewController userDefaultsForApp] synchronize];
                [self saveData:data];
                recentsData = data;
            }else{
                recentsData = [self dataFromCache];
            }
            
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:recentsData options:NSJSONReadingAllowFragments error:nil];
            [self proccessRecentsData:jsonData];
            
            block(true);
        }else{
            block(false);
        }
    }];
    [recentTask resume];
}
- (void)saveData:(NSData *)data{
    [data writeToURL:[self cacheURLPath] atomically:true];
}
- (NSData *)dataFromCache{
    NSData *cacheData = [NSData dataWithContentsOfURL:[self cacheURLPath]];
    return cacheData;
}
- (NSURL *)cacheURLPath{
    NSURL *securityContainer = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:appGroup];
    securityContainer = [securityContainer URLByAppendingPathComponent:@"recents.cache"];
    return securityContainer;
}
- (void)proccessRecentsData:(NSDictionary *)jsonData{
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
}
- (IBAction)changeData:(id)sender {
    [self.tableView reloadData];
}
#pragma mark - NCWidget Delegate
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    if ([self dataFromCache]){
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[self dataFromCache] options:NSJSONReadingAllowFragments error:nil];
        [self proccessRecentsData:jsonData];
    }
    
    
    [self refreshRecentlyWithCompletion:^(BOOL shouldReload) {
        if (shouldReload){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                self.preferredContentSize = self.tableView.contentSize;
                completionHandler(NCUpdateResultNewData);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(NCUpdateResultNoData);
            });
        }
    }];
    
    completionHandler(NCUpdateResultNewData);
}
#pragma mark - TableView Datasource/Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataType.selectedSegmentIndex == 0){
        return self.recentMachines.count;
    }else{
        return self.events.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSAttributedString *cellTitle;
    if (self.dataType.selectedSegmentIndex == 0){
        NSDictionary *recentMachine = self.recentMachines[indexPath.row];
        cellTitle = recentMachine[@"displayText"];
    }else{
        Event *currentEvent = self.events[indexPath.row];
        cellTitle = currentEvent.eventTitle;
    }

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
    NSAttributedString *cellTitle;
    if (self.dataType.selectedSegmentIndex == 0){
        NSDictionary *recentMachine = self.recentMachines[indexPath.row];
        cellTitle = recentMachine[@"displayText"];
    }else{
        Event *currentEvent = self.events[indexPath.row];
        cellTitle = currentEvent.eventTitle;
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.attributedText = cellTitle;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.dataType.selectedSegmentIndex == 1){
        NSURL *appSchema = [[NSURL alloc] initWithScheme:@"pbmapp" host:nil path:@"/events"];
        [self.extensionContext openURL:appSchema completionHandler:nil];
    }
}

@end
