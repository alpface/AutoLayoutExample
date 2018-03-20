//
//  NaviActionContentView.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/16.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "NaviActionContentView.h"

static inline CGSize TextSize(NSString *text,
                              UIFont *font,
                              CGSize constrainedSize,
                              NSLineBreakMode lineBreakMode)
{
    if (!text) {
        return CGSizeZero;
    }
    CGSize size;
    if ([NSAttributedString instancesRespondToSelector:@selector(boundingRectWithSize:options:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = lineBreakMode;
        NSDictionary *attributes = @{
                                     NSFontAttributeName: font,
                                     NSParagraphStyleAttributeName: paragraphStyle,
                                     };
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        CGSize size = [attributedString boundingRectWithSize:constrainedSize
                                                     options:(NSStringDrawingUsesDeviceMetrics |
                                                              NSStringDrawingUsesLineFragmentOrigin |
                                                              NSStringDrawingUsesFontLeading)
                                                     context:NULL].size;
        return CGSizeMake(ceilf(size.width), ceilf(size.height));
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [text sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return CGSizeMake(ceilf(size.width), ceilf(size.height));
}

@interface NaviActionContentView ()
@property (nonatomic, assign) BOOL showbottomViewAnimated;
@property (nonatomic, assign) CGFloat bottomViewHeight;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation NaviActionContentView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // 初始化时预备10个子控件做为循环使用的，为了优化，
    // 如果多了就添加，少了就移除
    for (NSInteger i = 0; i < 10; i++) {
        NaviActionButton *button = [self createButton];
        button.tag = i;
        [self.buttonArray addObject:button];
        [self addSubview:button];
    }
    [self updatelineArray];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)reloadItems {
    NSArray *items = self.items;
    
    NSInteger totalCount = items.count;
    // 计算已有的子控件数量与需要展示的个数的差值
    NSInteger differencesCount = differencesCount = totalCount - self.buttonArray.count;
    if (differencesCount == 0) {
        // 没有差值，不需要创建新的，也不需要移除多余的
    }
    else if (differencesCount < 0) {
        // 多余的需要移除
        //        differencesCount = labs(differencesCount);
        while (differencesCount < 0) {
            NaviActionButton *button = self.buttonArray.lastObject;
            [button removeFromSuperview];
            [self.buttonArray removeObject:button];
            differencesCount++;
        }
    }
    else if (differencesCount > 0) {
        // 缺少控件，就创建
        while (differencesCount > 0) {
            NaviActionButton *button = [self createButton];
            [self.buttonArray addObject:button];
            [self addSubview:button];
            differencesCount--;
        }
    }
    
    NSParameterAssert(self.buttonArray.count == totalCount);
    //////////////////
    
    // 给控件设置值
    for (NSInteger i = 0; i < totalCount; ++i) {
        NaviActionButton *button = self.buttonArray[i];
        button.tag = i;
        NaviActionItem *node = items[i];
        
        [button setTitle:node.title forState:UIControlStateNormal];
        [button setImage:node.image forState:UIControlStateNormal];
    }
    
    [self updatelineArray];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    
    //    [self setNeedsLayout];
    //    [self layoutIfNeeded];
    //    // 获取contentView的size
    //    CGSize size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //    height = size.height;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)buttonClick:(NaviActionButton *)sender {
    if (self.buttonActionBlock) {
        self.buttonActionBlock(self.items[sender.tag]);
    }
    
}
/// 将buttonArray中的所有按钮，根据maxNumberOfLine按组拆分(按maxNumberOfLine一组进行分组,目的是为了使用AutoLayout布局)
- (NSMutableArray<NSMutableArray<NaviActionButton *> *> *)lineArray {
    if (!_lineArray) {
        _lineArray = @[].mutableCopy;
    }
    return _lineArray;
}

- (NSUInteger)maxNumberOfLine {
    return MAX(1, _maxNumberOfLine);
}

- (void)updatelineArray {
    [self.lineArray removeAllObjects];
    for (NSInteger i = 0; i < self.buttonArray.count; i++) {
        NSInteger rowIndex = i / self.maxNumberOfLine;
        NSMutableArray *rowArray = nil;
        if (rowIndex >= self.lineArray.count) {
            rowArray = [NSMutableArray array];
            [self.lineArray addObject:rowArray];
        }
        else {
            rowArray = [self.lineArray objectAtIndex:rowIndex];
        }
        NaviActionButton *btn = self.buttonArray[i];
        [rowArray addObject:btn];
    }
}

/// 此约束会根据子控件的高度，固定父控件的高度
- (void)updateConstraints {
    [super updateConstraints];
    // 最大的列数
    //    NSInteger columnCount = self.maxNumberOfLine;
    //NSInteger rowCount = ceil(self.buttonArray.count/(CGFloat)columnCount);
    NSArray *lineArray = self.lineArray;
    
    CGFloat hPadding = self.itemHPadding;
    CGFloat vPadiing = self.itemVPadding;
    [NSLayoutConstraint deactivateConstraints:self.viewConstraints];
    [self.viewConstraints removeAllObjects];
    NSMutableArray *constraints = self.viewConstraints;
    NSMutableDictionary *metrics = @{@"hPadding": @(hPadding), @"vPadiing": @(vPadiing)}.mutableCopy;
    
    for (NSInteger i = 0; i < lineArray.count; i++) {
        NSArray *rowArray = lineArray[i];
        NSMutableString *hFormat = @"".mutableCopy;
        NSDictionary *hSubviewsDict = @{}.mutableCopy;
        NaviActionButton *previousBtn = nil;
        NSString *previousBtnKey = nil;
        for (NSInteger j = 0; j < rowArray.count; j++) {
            NaviActionButton *btn = rowArray[j];
            NSString *buttonKey = [NSString stringWithFormat:@"button_row_%ld_section_%ld", j, i];
            [hSubviewsDict setValue:btn forKey:buttonKey];
            
            // 布局根据padding的大小，自适应button的宽度，每个button的宽度相同
            // 子控件之间的列约束
            [hFormat appendFormat:@"-(==hPadding)-[%@%@]", buttonKey, previousBtn?[NSString stringWithFormat:@"(%@)", previousBtnKey]:@""];
            if (j == rowArray.count - 1) {
                // 拼接最后一列的右侧间距
                [hFormat appendFormat:@"-(==hPadding)-"];
            }
            
            // 子控件之间的行约束
            // 取出当前btn顶部依赖的控件，如果没有依赖则为父控件
            NSMutableString *vFormat = @"".mutableCopy;
            NSMutableDictionary *vSubviewsDict = @{}.mutableCopy;
            // 上一行的index
            NSInteger previousRowIndex = i - 1;
            // 取出当前按钮上面的按钮
            NaviActionButton *dependentTopBtn = nil;
            if (previousRowIndex < lineArray.count) {
                // 取出上一行的所有按钮
                NSArray *previousRowArray = [lineArray objectAtIndex:previousRowIndex];
                dependentTopBtn = previousRowArray[j];
            }
            
            
            [vSubviewsDict addEntriesFromDictionary:hSubviewsDict];
            if (dependentTopBtn) {
                // 如果上面有按钮就添加和他底部之间的约束
                NSString *dependentButtonKey = [NSString stringWithFormat:@"dependent_button_%ld", previousRowIndex];
                [vSubviewsDict setValue:dependentTopBtn forKey:dependentButtonKey];
                // 拼接与顶部按钮底部的vfl
                [vFormat appendFormat:@"[%@]-(==vPadiing)-[%@%@]", dependentButtonKey, buttonKey, previousBtn?[NSString stringWithFormat:@"(%@)", previousBtnKey]:@""];
                
                // 控制每行高度相同的
                [constraints addObject:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:dependentTopBtn attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
            }
            else {
                // 第一行
                [vFormat appendFormat:@"|-(==vPadiing)-[%@%@]", buttonKey, previousBtn?[NSString stringWithFormat:@"(%@)", previousBtnKey]:@""];
            }
            
            if (i == lineArray.count - 1) {
                // 最后一行, 如果有bottomView，则拼接上，没有则拼接父底部
                if ([self showBottomView]) {
                    [vSubviewsDict setObject:self.bottomView forKey:@"bottomView"];
                    [vFormat appendFormat:@"-(==vPadiing)-[bottomView]-(0.0)-|"];
                }
                else {
                    [vFormat appendFormat:@"-(==vPadiing)-|"];
                }
            }
            
            if (vFormat.length) {
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:%@", vFormat] options:kNilOptions metrics:metrics views:vSubviewsDict]];
            }
            
            // 如果设置了高度，则高度不再自适应
            if (self.itemHeight > 0) {
                [constraints addObject:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.itemHeight]];
                if (self.isSquare) {
                    [constraints addObject:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:btn attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
                }
            }
            else {
                if (self.isSquare) {
                    [constraints addObject:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:btn attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
                }
            }
            
            previousBtn = btn;
            previousBtnKey = buttonKey;
        }
        if (hFormat.length) {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|%@|", hFormat] options:kNilOptions metrics:metrics views:hSubviewsDict]];
        }
        
    }
    
    NSLayoutConstraint *bottomHeightConstraint = nil;
    if ([self showBottomView]) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        bottomHeightConstraint = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.0];
        [constraints addObject:bottomHeightConstraint];
        
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    if ([self showBottomView]) {
        if (self.showbottomViewAnimated) {
            bottomHeightConstraint.constant = self.bottomViewHeight;
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:1.0 animations:^{
                    [self layoutIfNeeded];
                } completion:^(BOOL finished) {
                    
                }];
            });
        }
        else {
            bottomHeightConstraint.constant = self.bottomViewHeight;;
        }
    }
    
}

- (void)setBottomView:(UIView *)bottomView animated:(BOOL)animated height:(CGFloat)height {
    if (_bottomView == bottomView) {
        return;
    }
    self.showbottomViewAnimated = animated;
    self.bottomViewHeight = height;
    _bottomView = bottomView;
    [self addSubview:bottomView];
    bottomView.translatesAutoresizingMaskIntoConstraints = false;
    //    [self updateBottomViewConstraints];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)updateBottomViewConstraints {
    UIView *bottomView = self.bottomView;
    if (bottomView == nil) {
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        return;
    }
    BOOL animated = self.showbottomViewAnimated;
    if (self.viewConstraints.count == 0) {
        return;
    }
    NSArray *relativeParentViewBottomConstraints = [self getRelativeParentViewBottomConstraintsOfLastLineButtons];
    [NSLayoutConstraint deactivateConstraints:relativeParentViewBottomConstraints];
    [self.viewConstraints removeObjectsInArray:relativeParentViewBottomConstraints];
    NSMutableArray *bottomConstraints = @[].mutableCopy;
    [self.lineArray.lastObject enumerateObjectsUsingBlock:^(NaviActionButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [bottomConstraints addObject:[NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-self.itemVPadding]];
    }];
    [bottomConstraints addObject:[NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [bottomConstraints addObject:[NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    NSLayoutConstraint *bottomHeightConstraint = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.0];
    [bottomConstraints addObject:bottomHeightConstraint];
    [NSLayoutConstraint activateConstraints:bottomConstraints];
    [self.viewConstraints addObjectsFromArray:bottomConstraints];
    
    [self.viewConstraints addObject:bottomHeightConstraint];
    if (animated) {
        bottomHeightConstraint.constant = self.bottomView.frame.size.height;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1.0 animations:^{
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
        });
        
    }
    else {
        bottomHeightConstraint.constant = self.bottomView.frame.size.height;;
    }
}


/// 获取最后一行button相对俯视图的底部约束数组
- (NSArray *)getRelativeParentViewBottomConstraintsOfLastLineButtons {
    
    NSMutableArray *array = @[].mutableCopy;
    [self.viewConstraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.firstItem isEqual:self] &&
            obj.firstAttribute == NSLayoutAttributeBottom &&
            [self.lineArray.lastObject containsObject:obj.secondItem]) {
            [array addObject:obj];
        }
    }];
    return array;
    
}

- (BOOL)showBottomView {
    if (_bottomView && _bottomView.superview) {
        return YES;
    }
    return NO;
}

- (NaviActionButton *)createButton {
    NaviActionButton *btn = [NaviActionButton new];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}
@synthesize items = _items;

- (NSMutableArray<NaviActionItem *> *)items {
    if (!_items) {
        _items = @[].mutableCopy;
    }
    return _items;
}

- (NSMutableArray<NSLayoutConstraint *> *)viewConstraints {
    if (!_viewConstraints) {
        _viewConstraints = @[].mutableCopy;
    }
    return _viewConstraints;
}

@end

@interface NaviActionButton ()

@property (nonatomic, strong) UIView *cornerView;

@end

@implementation NaviActionButton {
    CGSize _titleLabelSize;
    CGFloat _middlePadding;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.cornerView];
        _middlePadding = 20.0;
    }
    return self;
}


// 图片太大，文本显示不出来，控制button中image的尺寸
// imageRectForContentRect:和titleRectForContentRect:不能互相调用self.imageView和self.titleLael,不然会死循环
- (CGRect)imageRectForContentRect:(CGRect)bounds {
    CGRect rect = CGRectZero;
    if (CGSizeEqualToSize(_titleLabelSize, CGSizeZero)) {
        rect = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    }
    CGFloat imageScal = 0.3;
    CGFloat width = MAX(0, MIN(bounds.size.width, bounds.size.height-_titleLabelSize.height-_middlePadding)) * imageScal;
    CGFloat x = (self.bounds.size.width - width) * 0.5;
    CGFloat y = (self.bounds.size.height - width - _titleLabelSize.height - _middlePadding) * 0.5;
    rect = CGRectMake(x, y, width, width);
    
    return rect;
}

- (CGRect)titleRectForContentRect:(CGRect)bounds {
    if (self.imageView.image) {
        CGFloat width = _titleLabelSize.width + 10.0;
        return CGRectMake((self.bounds.size.width-width)*0.5, CGRectGetMaxY(self.imageView.frame)+_middlePadding, width, _titleLabelSize.height);
    }
    return CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    UILabel *titleLabel = self.titleLabel;
    _titleLabelSize = TextSize(title, titleLabel.font, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), titleLabel.lineBreakMode);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat wh = MIN(self.imageView.frame.size.width+20.0, self.bounds.size.width);
    self.cornerView.frame = CGRectMake(0, 0, wh, wh);
    self.cornerView.center = self.imageView.center;
    self.cornerView.layer.cornerRadius = self.cornerView.frame.size.width * 0.5;
}

- (UIView *)cornerView {
    if (_cornerView == nil) {
        UIView *view = [UIView new];
        _cornerView = view;
        view.layer.borderWidth   = 1;
        view.layer.masksToBounds = YES;
        view.userInteractionEnabled = NO;
        view.layer.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0].CGColor;
    }
    return _cornerView;
}
@end

@implementation NaviActionItem
- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                   clickBlock:(void (^)(NaviActionItem *item))clickBlock {
    if (self = [super init]) {
        _title = title;
        _image = image;
        _clickBlock = [clickBlock copy];
    }
    return self;
}
@end
