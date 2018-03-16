//
//  NaviActionController.h
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/13.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NaviActionController, NaviActionItem;

@protocol NaviActionControllerDelegate<NSObject>

@optional
- (void)naviActionControllerDidShow:(NaviActionController *)controller;
- (void)naviActionControllerDidDismiss:(NaviActionController *)controller;
- (void)naviActionController:(NaviActionController *)controller didClickItem:(NaviActionItem *)item;

@end

@interface NaviActionItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void (^ clickBlock)(NaviActionItem *item);
- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                   clickBlock:(void (^)(NaviActionItem *item))clickBlock;

@end

@interface  NaviActionContentView : UIView

@end


@interface NaviActionController : UIViewController

@property (nonatomic, strong, readonly) NaviActionContentView *containerView;
@property (nonatomic, strong) NSArray<NaviActionItem *> *items;
@property (nonatomic, weak) id<NaviActionControllerDelegate> delegate;

- (void)showWithAnimated:(BOOL)animated;
- (void)dismissWithAnimated:(BOOL)animated;

@end
