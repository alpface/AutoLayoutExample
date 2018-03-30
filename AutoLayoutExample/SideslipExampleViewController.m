//
//  SideslipExampleViewController.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/30.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "SideslipExampleViewController.h"
#import "SideslipViewController.h"

@interface SideslipExampleViewController ()
@property (nonatomic, strong) SideslipViewController *viewController;
@end

@implementation SideslipExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupViews];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"show" style:UIBarButtonItemStylePlain target:self action:@selector(toggle:)];
    item2.accessibilityIdentifier = @"second";
    self.navigationItem.rightBarButtonItems = @[item2];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.viewController showWithAnimated:YES completion:^(BOOL isShow) {
            if (isShow) {
                item2.title = @"dismiss";
            }
            else {
                item2.title = @"show";
            }
        }];
    });
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//}


- (void)setupViews {
    [self.view addSubview:self.viewController.view];
    self.viewController.view.translatesAutoresizingMaskIntoConstraints = false;
    
    CGFloat padding = 0;
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(padding)-[viewController]-(padding)-|" options:kNilOptions metrics:@{@"padding": @(padding)} views:@{@"viewController": self.viewController.view}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[viewController]|" options:kNilOptions metrics:nil views:@{@"viewController": self.viewController.view}]];
    
}
- (void)toggle:(UIBarButtonItem *)item {
    if ([item.accessibilityIdentifier isEqualToString:@"second"]) {
        if ([item.title isEqualToString:@"dismiss"]) {
            
            [self.viewController dismissWithAnimated:YES completion:^(BOOL isShow) {
                if (isShow) {
                    item.title = @"dismiss";
                }
                else {
                    item.title = @"show";
                }
            }];
        }
        else {
            
            [self.viewController showWithAnimated:YES completion:^(BOOL isShow) {
                if (isShow) {
                    item.title = @"dismiss";
                }
                else {
                    item.title = @"show";
                }
            }];
            
        }
    }
}
- (void)didChangeStatusBarOrientation:(NSNotification *)notif {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    });
}

- (SideslipViewController *)viewController {
    if (!_viewController) {
        _viewController = [[SideslipViewController alloc] init];
    }
    return _viewController;
}

@end
