//
//  NaviActionController2.h
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/13.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NaviActionContentView.h"

@interface NaviActionController2 : UIViewController

@property (nonatomic, strong, readonly) NaviActionContentView *containerView;
@property (nonatomic, strong) NSArray<NaviActionItem *> *items;
@property (nonatomic, weak) id<NaviActionContentViewrDelegate> delegate;

- (void)showWithAnimated:(BOOL)animated;
- (void)dismissWithAnimated:(BOOL)animated;

@end
