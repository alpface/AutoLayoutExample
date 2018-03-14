//
//  NaviActionController.h
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/13.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NaviActionItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;

@end


@interface NaviActionController : UIViewController

@property (nonatomic, strong, readonly) NSMutableArray<NaviActionItem *> *items;
- (void)addAction:(NaviActionItem *)item;

@end
