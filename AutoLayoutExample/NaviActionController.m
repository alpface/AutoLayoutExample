//
//  NaviActionController.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/13.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "NaviActionController.h"

#define CONTAINERVIEW_MARGIN 10.0
#define CONTAINERVIEW_TOP_MAX_MARGIN (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 75.0 : 55.0)

#define CONTAINERVIEW_MAX_ITEM_COUNT (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 3 : 5)

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

@interface NaviActionButton : UIButton

@end

@interface  NaviActionContentView ()
@property (nonatomic, strong) NSMutableArray<NaviActionButton *> *buttonArray;
@property (nonatomic, strong) NSMutableArray<NaviActionItem *> *items;
// item高度
@property (nonatomic, assign) IBInspectable CGFloat itemHeight;
/// 每行item的个数, 此方法会根据设置的间距itemHPadding值，自适应item的宽度, 最小为1
@property (nonatomic, assign) IBInspectable NSUInteger maxNumberOfLine;
/// 正方形，设置此属性后，宽高相同
/// @note 当设置itemHeight时，且square==YES 则宽度=高度
@property (assign, nonatomic, getter = isSquare) BOOL square;
@property (nonatomic, assign) IBInspectable CGFloat itemHPadding;
@property (nonatomic, assign) IBInspectable CGFloat itemVPadding;
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *viewConstraints;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NaviActionButton *> *> *lineArray;
@property (nonatomic, copy) void (^ buttonActionBlock)(NaviActionItem *item);
- (void)reloadItems;
- (void)setBottomView:(UIView *)bottomView animated:(BOOL)animated height:(CGFloat)height;
@end



@interface NaviActionController ()
@property (nonatomic, strong) NaviActionContentView *containerView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign, getter=isShow) BOOL show;
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *viewConstraints;
@end


@implementation NaviActionController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
    
    [self.containerView.items removeAllObjects];
    [self.containerView.items addObjectsFromArray:self.items];
    [self.containerView reloadItems];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews {

    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.containerView];
    self.view.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.alpha = 0.0;
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 5.0;
    self.containerView.layer.masksToBounds = true;
    self.containerView.maxNumberOfLine = CONTAINERVIEW_MAX_ITEM_COUNT;
    self.containerView.itemHPadding = 10.0;
    self.containerView.itemVPadding = 10.0;
    // 设置这两个属性会导致屏幕旋转时，containerView的高度会超出父视图
//    self.containerView.itemHeight = 100.0;
//    self.containerView.square = YES;
    
    
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundView]|" options:kNilOptions metrics:nil views:@{@"backgroundView": self.backgroundView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|" options:kNilOptions metrics:nil views:@{@"backgroundView": self.backgroundView}]];

    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    if (self.view.superview == nil) {
        return;
    }
    [NSLayoutConstraint deactivateConstraints:self.viewConstraints];
    [self.viewConstraints removeAllObjects];
    NSDictionary *metrics = @{@"margin": @(CONTAINERVIEW_MARGIN)};
    [self.viewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(margin)-[containerView]-(margin)-|" options:kNilOptions metrics:metrics views:@{@"containerView": self.containerView}]];
    [self.viewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[containerView]-(margin)-|" options:kNilOptions metrics:metrics views:@{@"containerView": self.containerView}]];
    CGFloat topMargin = CONTAINERVIEW_TOP_MAX_MARGIN;
    if (self.isShow == NO) {
        topMargin = [UIScreen mainScreen].bounds.size.height;
    }
    [self.viewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:topMargin]];
    [NSLayoutConstraint activateConstraints:self.viewConstraints];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Lazy
////////////////////////////////////////////////////////////////////////

- (NSMutableArray<NSLayoutConstraint *> *)viewConstraints {
    if (!_viewConstraints) {
        _viewConstraints = @[].mutableCopy;
    }
    return _viewConstraints;
}


- (NSLayoutConstraint *)containerViewTopConstraint {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem==%@ AND secondItem==%@ AND firstAttribute==%ld", self.containerView, self.view, NSLayoutAttributeTop];
    NSLayoutConstraint *constraint = [self.view.constraints filteredArrayUsingPredicate:predicate].firstObject;
    return constraint;
}

- (NaviActionContentView *)containerView {
    if (!_containerView) {
        NaviActionContentView *containerView = [[NaviActionContentView alloc] initWithFrame:CGRectZero];
        _containerView = containerView;
        containerView.translatesAutoresizingMaskIntoConstraints = false;
        __weak typeof(&*self) weakSelf = self;
        containerView.buttonActionBlock = ^(NaviActionItem *item) {
            __strong typeof(&*weakSelf) self = weakSelf;
            if (self.delegate && [self.delegate respondsToSelector:@selector(naviActionController:didClickItem:)]) {
                [self.delegate naviActionController:self didClickItem:item];
            }
        };
        UILabel *bottomView = [UILabel new];
        bottomView.backgroundColor = [UIColor greenColor];
        bottomView.text = @"this is bottom";
        bottomView.textAlignment = NSTextAlignmentCenter;
        [containerView setBottomView:bottomView animated:NO height:100.0];
    }
    return _containerView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        UIView *view = [UIView new];
        view.translatesAutoresizingMaskIntoConstraints = false;
        _backgroundView = view;
    }
    return _backgroundView;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (void)show {
    
    self.show = YES;
    
    // 执行此次layoutIfNeeded是为了防止下面的动画把所有的布局都执行了，会导致view从顶部开始出现的问题
//        [view layoutIfNeeded];
    // 另外一种方案：加入到主队列中执行本次动画
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backgroundView.alpha = 0.3;
        [self containerViewTopConstraint].constant = CONTAINERVIEW_TOP_MAX_MARGIN;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(naviActionControllerDidShow:)]) {
                [self.delegate naviActionControllerDidShow:self];
            }
        }];
    });
}

- (void)dismiss {
    self.show = NO;
    [self containerViewTopConstraint].constant = [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundView.alpha = 0.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(naviActionControllerDidDismiss:)]) {
            [self.delegate naviActionControllerDidDismiss:self];
        }
    }];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Notify
////////////////////////////////////////////////////////////////////////
- (void)didChangeStatusBarOrientation:(NSNotification *)notif {
    NSInteger maxCount = CONTAINERVIEW_MAX_ITEM_COUNT;
    if (maxCount != self.containerView.maxNumberOfLine) {
        self.containerView.maxNumberOfLine = maxCount;
        [self.containerView reloadItems];
    }
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
}



- (void)addAction:(NaviActionItem *)item {
    [self.items addObject:item];
}

@synthesize items = _items;
- (NSMutableArray<NaviActionItem *> *)items {
    if (!_items) {
        _items = @[].mutableCopy;
    }
    return _items;
}
@end

@implementation NaviActionItem

@end

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
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn.titleLabel.font = [UIFont systemFontOfSize:28.0];
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

@implementation NaviActionButton {
    CGSize _titleLabelSize;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}


// 图片太大，文本显示不出来，控制button中image的尺寸
// imageRectForContentRect:和titleRectForContentRect:不能互相调用self.imageView和self.titleLael,不然会死循环
- (CGRect)imageRectForContentRect:(CGRect)bounds {
    if (CGSizeEqualToSize(_titleLabelSize, CGSizeZero)) {
        return CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    }
    return CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height-_titleLabelSize.height);
}

- (CGRect)titleRectForContentRect:(CGRect)bounds {
    if (self.imageView.image) {
        return CGRectMake(0.0, self.imageView.bounds.size.height, bounds.size.width, bounds.size.height-self.imageView.bounds.size.height);
    }
    return CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    UILabel *titleLabel = self.titleLabel;
    _titleLabelSize = TextSize(title, titleLabel.font, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), titleLabel.lineBreakMode);
}


@end
