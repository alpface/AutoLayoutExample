//
//  SideslipViewController.h
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/30.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideslipTableView : UITableView <UIGestureRecognizerDelegate>

@end

@interface SideslipViewController : UIViewController

@property (nonatomic, strong) SideslipTableView *tableView;

+ (instancetype)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL isShow))completion;
+ (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(BOOL isShow))completion;

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL isShow))completion;
- (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(BOOL isShow))completion;
- (void)toggleWithAnimated:(BOOL)animated completion:(void (^)(BOOL isShow))completion;

+ (__kindof SideslipViewController *)displaySideslipViewController;
@end
