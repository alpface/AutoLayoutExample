//
//  ViewController.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/14.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "ViewController.h"
#import "NaviActionController.h"

@interface ViewController ()
@property (nonatomic, strong) NaviActionController *viewController;
@property (nonatomic, strong) UIView *leftView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupViews];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"show" style:UIBarButtonItemStylePlain target:self action:@selector(toggle:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (NaviActionController *)viewController {
    if (!_viewController) {
        _viewController = [[NaviActionController alloc] init];
        
        for (NSInteger i = 0; i < 6; i++) {
            NaviActionItem *item = NaviActionItem.new;
            item.title = @(i).stringValue;
            item.image = [UIImage imageNamed:@"icon_man"];
            [_viewController addAction:item];
        }
    }
    return _viewController;
}

- (UIView *)leftView {
    if (_leftView == nil) {
        UIView *leftView = [UIView new];
        leftView.translatesAutoresizingMaskIntoConstraints = false;
        _leftView = leftView;
        leftView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
        leftView.layer.cornerRadius = 5.0;
        leftView.layer.masksToBounds = YES;
    }
    return _leftView;
}

- (void)toggle:(UIBarButtonItem *)item {
    if ([item.title isEqualToString:@"dismiss"]) {
        item.title = @"show";
        [self.viewController dismiss];
    }
    else {
        item.title = @"dismiss";
        [self.viewController show];
        
    }
}

- (void)setupViews {
    [self.view addSubview:self.viewController.view];
    [self.view addSubview:self.leftView];
    self.viewController.view.translatesAutoresizingMaskIntoConstraints = false;
    self.view.backgroundColor = [UIColor blueColor];
    
    CGFloat padding = 10.0;
    CGFloat leftViewWidth = 35.0;
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        padding = 0.0;
        leftViewWidth = 0.0;
    }
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(padding)-[leftView(==leftViewWidth)]-(padding)-[viewController]-(0.0)-|" options:kNilOptions metrics:@{@"padding": @(padding), @"leftViewWidth": @(leftViewWidth)} views:@{@"viewController": self.viewController.view, @"leftView": self.leftView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[viewController]|" options:kNilOptions metrics:nil views:@{@"viewController": self.viewController.view}]];
    [NSLayoutConstraint constraintWithItem:self.leftView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewController.containerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.leftView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewController.containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    
     [self updateLeftViewConstraints];
}

- (NSLayoutConstraint *)leftViewLeftConstraint {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem==%@ AND firstAttribute==%ld", self.leftView, NSLayoutAttributeLeading];
    NSLayoutConstraint *constraint = [self.view.constraints filteredArrayUsingPredicate:predicate].firstObject;
    return constraint;
}

- (NSLayoutConstraint *)leftViewRightConstraint {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem==%@ AND secondItem==%@ AND firstAttribute==%ld", self.viewController.view, self.leftView, NSLayoutAttributeLeading];
    NSLayoutConstraint *constraint = [self.view.constraints filteredArrayUsingPredicate:predicate].firstObject;
    return constraint;
}

- (NSLayoutConstraint *)leftViewWidthConstraint {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem==%@ AND firstAttribute==%ld", self.leftView, NSLayoutAttributeWidth];
    NSLayoutConstraint *constraint = [self.leftView.constraints filteredArrayUsingPredicate:predicate].firstObject;
    return constraint;
}

- (void)updateLeftViewConstraints {
    CGFloat padding = 10.0;
    CGFloat leftViewWidth = 35.0;
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        padding = 0.0;
        leftViewWidth = 0.0;
    }
    [self leftViewLeftConstraint].constant = padding;
    [self leftViewRightConstraint].constant = padding;
    self.leftViewWidthConstraint.constant = leftViewWidth;
}

- (void)didChangeStatusBarOrientation:(NSNotification *)notif {
    [self updateLeftViewConstraints];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
