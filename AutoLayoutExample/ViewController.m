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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.viewController = [[NaviActionController alloc] init];
    
    for (NSInteger i = 0; i < 6; i++) {
        NaviActionItem *item = NaviActionItem.new;
        item.title = @(i).stringValue;
        item.image = [UIImage imageNamed:@"icon_man"];
        [self.viewController addAction:item];
    }
    [self.view addSubview:self.viewController.view];
    self.viewController.view.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[viewController]|" options:kNilOptions metrics:nil views:@{@"viewController": self.viewController.view}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[viewController]|" options:kNilOptions metrics:nil views:@{@"viewController": self.viewController.view}]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
