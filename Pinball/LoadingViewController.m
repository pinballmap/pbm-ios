//
//  LoadingViewController.m
//  PinballMap
//
//  Created by Frank Michael on 1/31/15.
//  Copyright (c) 2015 Frank Michael Sanchez. All rights reserved.
//

#import "LoadingViewController.h"

@interface LoadingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *loadingProgressLabel;

@end

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completedUpdate) name:@"RegionUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatingProgress:) name:@"UpdatingProgress" object:nil];
    [[PinballMapManager sharedInstance] refreshRegion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelRefresh:(id)sender {
    [[PinballMapManager sharedInstance] cancelAllLoadingOperations];
}
- (void)completedUpdate{
    [self dismissViewControllerAnimated:true completion:nil];
}
- (void)updatingProgress:(NSNotification *)note{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *progress = note.object;
        if (progress[@"total"] == nil){
            self.loadingProgressLabel.text = @"Completed!";
        }else{
            self.loadingProgressLabel.text = [NSString stringWithFormat:@"%@ of %@ completed",progress[@"completed"],progress[@"total"]];
        }
    });
}

@end
