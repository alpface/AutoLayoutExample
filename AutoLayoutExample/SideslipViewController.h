//
//  SideslipViewController.h
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/30.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideslipViewController : UIViewController
- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL isShow))completion;
- (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(BOOL isShow))completion;
@end
