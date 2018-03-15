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

@end

@interface  NaviActionContentView : UIView

@end


@interface NaviActionController : UIViewController

@property (nonatomic, strong, readonly) NaviActionContentView *containerView;
@property (nonatomic, strong, readonly) NSMutableArray<NaviActionItem *> *items;
@property (nonatomic, weak) id<NaviActionControllerDelegate> delegate;
- (void)addAction:(NaviActionItem *)item;

- (void)show;
- (void)dismiss;
@end
