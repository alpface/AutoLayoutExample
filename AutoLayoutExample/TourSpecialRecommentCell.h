//
//  TourSpecialRecommentCell.h
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/8/3.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBTourSpecialRecommentModel : NSObject

/// 头部视图的标题
@property (nonatomic, copy) NSAttributedString *attTitle;
/// 根据此属性创建buttons
@property (nonatomic, strong) NSArray<NSString *> *recomments;
/// cell的高度，会根据子控件的布局，计算其高度
@property (nonatomic, assign, readonly) CGFloat cellHeight;
/// 每个按钮的高度，如果不设置，则会让其自适应高度
@property (nonatomic, strong) NSNumber *buttonHeight;
/// 每行显示的最大列数, 默认为3个
@property (nonatomic, assign) NSInteger maxColumnCount;
/// 点击每个button的响应回调
@property (nonatomic, copy) void (^ clickButtonAction)(UIButton *btn);
/// buttons 距离 buttonContentView的边距, 默认为zero
@property (nonatomic, assign) UIEdgeInsets buttonMarginInsets;

@end


@interface TourSpecialRecommentCell : UITableViewCell

@property (nonatomic, strong) BBTourSpecialRecommentModel *model;

@end

NS_ASSUME_NONNULL_END
