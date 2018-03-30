//
//  NaviActionContentView.h
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/16.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NaviActionContentView, NaviActionItem;

@protocol NaviActionContentViewrDelegate<NSObject>

@optional
- (void)naviActionViewDidShow:(NaviActionContentView *)view;
- (void)naviActionViewDidDismiss:(NaviActionContentView *)view;
- (void)naviActionView:(NaviActionContentView *)view didClickItem:(NaviActionItem *)item;

@end

@interface NaviActionItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void (^ clickBlock)(NaviActionItem *item);
- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                   clickBlock:(void (^)(NaviActionItem *item))clickBlock;

@end

@interface NaviActionButton : UIButton

@end

@interface  NaviActionContentView : UIView
@property (nonatomic, strong) NSMutableArray<NaviActionButton *> *buttonArray;
@property (nonatomic, strong) NSMutableArray<NaviActionItem *> *items;
/// item高度
@property (nonatomic, assign) CGFloat itemHeight;
/// 每行item的个数, 此方法会根据设置的间距itemHPadding值，自适应item的宽度, 最小为1
@property (nonatomic, assign) IBInspectable NSUInteger maxNumberOfLine;
/// 正方形，设置此属性后，宽高相同
/// @note 当设置itemHeight时，且square==YES 则宽度=高度
@property (assign, nonatomic, getter = isSquare) BOOL square;
/// 当这一行的显示数据没有maxNumberOfLine多时，是否按照当前行的大小自适应宽度
/// 当为YES时，不管这一行有多少个都是平分行的宽度，反之，不自适应宽度
/// 如果只有一行且数量不足maxNumberOfLine时也是会自适应宽度
/// default is NO
@property (nonatomic, assign, getter=isSizeAdaptive) IBInspectable BOOL sizeAdaptive;
@property (nonatomic, assign) IBInspectable CGFloat itemHPadding;
@property (nonatomic, assign) IBInspectable CGFloat itemVPadding;
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *viewConstraints;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NaviActionButton *> *> *lineArray;
@property (nonatomic, copy) void (^ buttonActionBlock)(NaviActionItem *item);
- (void)reloadItems;
- (void)setBottomView:(UIView *)bottomView animated:(BOOL)animated height:(CGFloat)height;
- (void)setSizeAdaptive:(BOOL)sizeAdaptive animated:(BOOL)animated;
@end

