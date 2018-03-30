//
//  SideslipViewController.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/30.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "SideslipViewController.h"
#import <objc/runtime.h>

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

static CGFloat TableViewWidthMultiplierValue = 0.6;
static NSString * const SideslipTableViewCellIdentifier = @"SideslipTableViewCellIdentifier";
static void * SideslipViewControllerKey = &SideslipViewControllerKey;

typedef NS_ENUM(NSInteger, SideslipTableViewScrollDirection) {
    SideslipTableViewScrollDirectionNotKnow,
    SideslipTableViewScrollDirectionVertical,
    SideslipTableViewScrollDirectionHorizontal
};

@interface SideslipTableViewHeaderView : UIView

@end

@interface SideslipTableViewHeaderViewButton : UIButton

@end

@interface SideslipTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *sw;

@end

@interface SideslipTableView : UITableView <UIGestureRecognizerDelegate>

@property (nonatomic, copy) void (^ sideslipPanGestureRecognizerBlock)(UIPanGestureRecognizer *pan);

@end

@interface SideslipViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) SideslipTableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *viewConstraints;
@property (nonatomic, assign, getter=isShow) BOOL show;
@property (nonatomic, copy) void (^ animationComletionHandler)(BOOL isShow);

@end

@implementation SideslipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupViews {
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.tableView];
    
    SideslipTableViewHeaderView *headerView = [SideslipTableViewHeaderView new];
    headerView.frame = CGRectMake(0, 0, 0, 120.0);
    self.tableView.tableHeaderView = headerView;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.alpha = 0.0;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = false;
    self.tableView.translatesAutoresizingMaskIntoConstraints = false;
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundView]|" options:kNilOptions metrics:nil views:@{@"backgroundView": self.backgroundView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|" options:kNilOptions metrics:nil views:@{@"backgroundView": self.backgroundView}]];
    
    [self.view updateConstraintsIfNeeded];
    [self.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBackgroundView:)]];
    [self.backgroundView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureOnBackgroundView:)]];
    __weak typeof(self) weakSelf = self;
    self.tableView.sideslipPanGestureRecognizerBlock = ^(UIPanGestureRecognizer *pan) {
        [weakSelf panGestureOnBackgroundView:pan];
    };
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    if (self.view.superview == nil || self.tableView.superview == nil) {
        return;
    }
    [NSLayoutConstraint deactivateConstraints:self.viewConstraints];
    [self.viewConstraints removeAllObjects];
    [self.viewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:kNilOptions metrics:nil views:@{@"tableView": self.tableView}]];
    [self.viewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:TableViewWidthMultiplierValue constant:0.0]];
    // 未显示状态下的tableView的关键约束
    [self.viewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    // 显示状态下的tableView的关键约束
    [self.viewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [NSLayoutConstraint activateConstraints:self.viewConstraints];
    [self _updateConstraints];
}

- (void)_updateConstraints {
    if (self.isShow) {
        [self tableViewLeadingConstraintOfDismiss].active = NO;
        [self tableViewTrailingConstraint].active = YES;
    }
    else {
        [self tableViewLeadingConstraintOfDismiss].active = YES;
        [self tableViewTrailingConstraint].active = NO;
    }
}

/// tableView宽度约束
- (NSLayoutConstraint *)tableViewWidthConstraintOfShow {
    if (self.viewConstraints.count == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem==%@ AND secondItem==%@ AND firstAttribute==%ld ", self.tableView, self.view, NSLayoutAttributeWidth];
    NSLayoutConstraint *constraint = [self.viewConstraints filteredArrayUsingPredicate:predicate].firstObject;
    return constraint;
}

/// 未显示状态下的左侧约束
- (NSLayoutConstraint *)tableViewLeadingConstraintOfDismiss {
    if (self.viewConstraints.count == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem==%@ AND secondItem==%@ AND firstAttribute==%ld AND secondAttribute==%ld", self.tableView, self.view, NSLayoutAttributeLeading, NSLayoutAttributeTrailing];
    NSLayoutConstraint *constraint = [self.viewConstraints filteredArrayUsingPredicate:predicate].firstObject;
    return constraint;
}

/// 显示状态下的右侧约束
- (NSLayoutConstraint *)tableViewTrailingConstraint {
    if (self.viewConstraints.count == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem==%@ AND secondItem==%@ AND firstAttribute==%ld AND secondAttribute==%ld", self.tableView, self.view, NSLayoutAttributeTrailing, NSLayoutAttributeTrailing];
    NSLayoutConstraint *constraint = [self.viewConstraints filteredArrayUsingPredicate:predicate].firstObject;
    return constraint;
}

- (void)resetConstraints {
    [self tableViewTrailingConstraint].constant = 0.0;
    [self tableViewLeadingConstraintOfDismiss].constant = 0.0;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

+ (instancetype)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL isShow))completion {
    SideslipViewController *vc = objc_getAssociatedObject([UIApplication sharedApplication], SideslipViewControllerKey);
    if (vc == nil) {
        vc = [[SideslipViewController alloc] init];
        objc_setAssociatedObject([UIApplication sharedApplication], SideslipViewControllerKey, vc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (vc.view.superview) {
        return vc;
    }
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:vc.view];
    vc.view.translatesAutoresizingMaskIntoConstraints = false;
    
    CGFloat padding = 0;
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(padding)-[viewController]-(padding)-|" options:kNilOptions metrics:@{@"padding": @(padding)} views:@{@"viewController": vc.view}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[viewController]|" options:kNilOptions metrics:nil views:@{@"viewController": vc.view}]];
    // 强制更新本次布局，以避免下次可能会在某个动画块中更新了
    [vc.view layoutIfNeeded];
    
    [vc showWithAnimated:animated completion:^(BOOL isShow) {
        if (completion) {
            completion(isShow);
        }
        if (isShow == NO) {
            [vc releaseSelf];
        }
    }];
    
    return vc;
}

+ (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    SideslipViewController *vc = objc_getAssociatedObject([UIApplication sharedApplication], SideslipViewControllerKey);
    if (vc == nil) {
        return;
    }
    [vc dismissWithAnimated:animated completion:^(BOOL isShow) {
        if (completion) {
            completion(isShow);
        }
        if (isShow == NO) {
            [vc releaseSelf];
        }
    }];
}


- (void)releaseSelf {
    [self.view removeFromSuperview];
    objc_setAssociatedObject([UIApplication sharedApplication], SideslipViewControllerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)toggleWithAnimated:(BOOL)animated completion:(void (^)(BOOL isShow))completion {
    if (self.isShow) {
        [self dismissWithAnimated:animated completion:completion];
    }
    else {
        [self showWithAnimated:animated completion:completion];
    }
}

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    if (self.isShow) {
        return;
    }
    self.show = YES;
    self.animationComletionHandler = completion;
    // 执行此次layoutIfNeeded是为了防止下面的动画把所有的布局都执行了，会导致view从顶部开始出现的问题
    //    [self.view layoutIfNeeded];
    // 另外一种方案：加入到主队列中执行本次动画
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backgroundView.alpha = 0.3;
        [self _updateConstraints];
        [UIView animateWithDuration:animated ? 0.3 : 0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self resetConstraints];
            if (self.animationComletionHandler) {
                self.animationComletionHandler(self.show);
            }
        }];
    });
}

- (void)dismiss {
    [self dismissWithAnimated:YES completion:self.animationComletionHandler];
}

- (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    if (self.isShow == NO) {
        return;
    }
    self.show = NO;
    self.animationComletionHandler = completion;
    [self _updateConstraints];
    
    [UIView animateWithDuration:animated ? 0.3 : 0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundView.alpha = 0.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self resetConstraints];
        if (self.animationComletionHandler) {
            self.animationComletionHandler(self.show);
        }
    }];
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////
- (void)tapOnBackgroundView:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        [self dismissWithAnimated:YES completion:self.animationComletionHandler];
    }
}

- (void)panGestureOnBackgroundView:(UIPanGestureRecognizer *)pan {
    if (self.isShow == NO) {
        return;
    }
    // 获取到的是手指移动后，在相对坐标中的偏移量
    CGPoint translation = [pan translationInView:self.view];
    // 重置偏移量
    [pan setTranslation:CGPointZero inView:self.view];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            // 根据手指移动的偏移量，移动sideslipTableView
            CGFloat trailingConstant = self.tableViewTrailingConstraint.constant;
            trailingConstant += translation.x;
//            NSLog(@"%f", trailingConstant);
            if (trailingConstant <= 0) {
                return;
            }
            [self.view layoutIfNeeded];
            CGFloat progress = trailingConstant / (self.view.frame.size.width * TableViewWidthMultiplierValue);
            self.tableViewTrailingConstraint.constant = trailingConstant;
            [UIView animateWithDuration:0.1 animations:^{
                [self.view layoutIfNeeded];
            }];
            if (trailingConstant >= self.view.frame.size.width * TableViewWidthMultiplierValue) {
                progress = 1.0;
                [self dismissWithAnimated:YES completion:self.animationComletionHandler];
            }
            [self updateSideslipProgress:progress];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [self dismissWithAnimated:YES completion:self.animationComletionHandler];
            break;
        }
        case UIGestureRecognizerStateFailed: {
            NSLog(@"UIGestureRecognizerStateFailed");
            break;
        }
        default:
            break;
    }

}

- (void)updateSideslipProgress:(CGFloat)progress {
    
//    CGFloat backgroundAlpha = self.backgroundView.alpha;
//    backgroundAlpha = backgroundAlpha - backgroundAlpha * progress;
//    self.backgroundView.alpha = backgroundAlpha;
//    NSLog(@"backgroundAlpha:%f", backgroundAlpha);
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SideslipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SideslipTableViewCellIdentifier forIndexPath:indexPath];
    
    return cell;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Lazy
////////////////////////////////////////////////////////////////////////
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [UIView new];
    }
    return _backgroundView;
}

- (SideslipTableView *)tableView {
    if (!_tableView) {
        SideslipTableView *tableView = [[SideslipTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView = tableView;
        tableView.dataSource = self;
        tableView.delegate = self;
        [tableView registerClass:[SideslipTableViewCell class] forCellReuseIdentifier:SideslipTableViewCellIdentifier];
    }
    return _tableView;
}

- (NSMutableArray<NSLayoutConstraint *> *)viewConstraints {
    if (!_viewConstraints) {
        _viewConstraints = @[].mutableCopy;
    }
    return _viewConstraints;
}




@end

@implementation SideslipTableView {
    UIPanGestureRecognizer *_sideslipPanGestureRecognizer;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        UIPanGestureRecognizer *pan2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureOnSelf:)];
        _sideslipPanGestureRecognizer = pan2;
        [self addGestureRecognizer:pan2];
        pan2.delegate = self;
//        self.delaysContentTouches = NO;
    }
    return self;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    SideslipTableViewScrollDirection scrollDirection = [self scrollDirectionWithGestureRecognizer:gestureRecognizer];
    switch (scrollDirection) {
        case SideslipTableViewScrollDirectionVertical: {
            if ([gestureRecognizer isEqual:_sideslipPanGestureRecognizer]) {
                return YES;
            }
            else {
                return NO;
            }
            break;
        }
        case SideslipTableViewScrollDirectionHorizontal: {
            if ([gestureRecognizer isEqual:self.panGestureRecognizer]) {
                return NO;
            }
            else {
                return YES;
            }
            break;
        }
        default:
            return NO;
            break;
    }
    
}

/// 当手势开始时，根据手势开始移动时的偏移量，判断手指在scrollView上起始移动的方向；
/// @note 如果是左右滑动时，此时应该只能响应我添加的滑动手势_sideslipPanGestureRecognizer， 那此时如果gestureRecognizer是scrollView自带的滑动手势时，则让自带的滑动手势不能响应，反之亦然
/// @note 如果是上下滑动时，此时应该只能响应scrollView自带的滑动手势， 那此时如果gestureRecognizer是_sideslipPanGestureRecognizer时，则让我手动添加的手势不能响应，去响应scrollView自带滑动手势，反之亦然
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    SideslipTableViewScrollDirection scrollDirection = [self scrollDirectionWithGestureRecognizer:gestureRecognizer];
    switch (scrollDirection) {
        case SideslipTableViewScrollDirectionVertical: {
            if ([gestureRecognizer isEqual:_sideslipPanGestureRecognizer]) {
                return NO;
            }
            else {
                return YES;
            }
            break;
        }
        case SideslipTableViewScrollDirectionHorizontal: {
            if ([gestureRecognizer isEqual:self.panGestureRecognizer]) {
                return NO;
            }
            else {
                return YES;
            }
            break;
        }
        default:
            return YES;
            break;
    }
}
- (void)panGestureOnSelf:(UIPanGestureRecognizer *)pan {
    if (self.sideslipPanGestureRecognizerBlock) {
        self.sideslipPanGestureRecognizerBlock(pan);
    }
}


/// 根据滑动手势开始滑动的偏移量，确定其滑动方向
- (SideslipTableViewScrollDirection)scrollDirectionWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
    if (![pan isEqual:self.panGestureRecognizer] && ![pan isEqual:_sideslipPanGestureRecognizer]) {
        return SideslipTableViewScrollDirectionNotKnow;
    }
    CGPoint point = [pan translationInView:self];
    UIGestureRecognizerState state = gestureRecognizer.state;
    if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state) {
        // y轴偏移量大，说明是上下移动，此时如果手势是_sideslipPanGestureRecognizer时，让其不能响应
        if (fabs(point.y) >= fabs(point.x)) {
            return SideslipTableViewScrollDirectionVertical;
        }
        else {
            // x轴偏移量大，说明是左右移动，此时如果手势是scrollView自带的滑动手势时，让其不能响应
            return SideslipTableViewScrollDirectionHorizontal;
        }
    }
    return SideslipTableViewScrollDirectionNotKnow;
}

@end

@implementation SideslipTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.sw];
    self.iconView.translatesAutoresizingMaskIntoConstraints = false;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = false;
    self.sw.translatesAutoresizingMaskIntoConstraints = false;
    
    CGFloat margin = 16.0;
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(==margin)-[iconView]-(==margin)-[titleLabel]-(<=margin)-[sw]-(==13.0)-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"margin": @(margin)} views:@{@"iconView": self.iconView, @"titleLabel": self.titleLabel, @"sw": self.sw}]];
    [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-32].active = YES;
    [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0].active = YES;
    [self test];
}

- (void)test {
    self.iconView.image = [UIImage imageNamed:@"icon_signal_weak"];
    self.titleLabel.text = @"路况";
}

- (UIImageView *)iconView {
    if (!_iconView) {
        UIImageView *imageView = [UIImageView new];
        _iconView = imageView;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [UILabel new];
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.font = [UIFont systemFontOfSize:13.0];
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UISwitch *)sw {
    if (!_sw) {
        UISwitch *sw = [[UISwitch alloc] init];
        _sw = sw;
        sw.onTintColor = [UIColor colorWithRed:0.0/255.0 green:105.0/255.0 blue:210.0/255.0 alpha:1.0];
        sw.tintColor = [UIColor colorWithRed:215/255.0 green:216/255.0 blue:215/255.0 alpha:1.0];
        sw.transform = CGAffineTransformMakeScale( 0.65, 0.65);
    }
    return _sw;
}

@end

@implementation SideslipTableViewHeaderViewButton {
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
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:11.0];
        _middlePadding = 6.0;
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
    CGFloat imageScal = 1.0;
    CGFloat width = MAX(0, bounds.size.width - _middlePadding) * imageScal;
    CGFloat height = MAX(0, bounds.size.height-_titleLabelSize.height-_middlePadding) * imageScal;
    CGFloat x = (self.bounds.size.width - width) * 0.5;
    CGFloat y = (self.bounds.size.height - height - _titleLabelSize.height - _middlePadding) * 0.5;
    rect = CGRectMake(x, y, width, height);
    
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

@end

@interface SideslipTableViewHeaderView ()

@property (nonatomic, strong) SideslipTableViewHeaderViewButton *button2D;
@property (nonatomic, strong) SideslipTableViewHeaderViewButton *button3D;
@property (nonatomic, weak) SideslipTableViewHeaderViewButton *lastSelectedButton;
@end


@implementation SideslipTableViewHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.button2D];
    [self addSubview:self.button3D];
    
    self.button2D.translatesAutoresizingMaskIntoConstraints = false;
    self.button3D.translatesAutoresizingMaskIntoConstraints = false;
    [self.button2D setImage:[UIImage imageNamed:@"layer_2d_unselected"] forState:UIControlStateNormal];
    [self.button3D setImage:[UIImage imageNamed:@"layer_3d_unselected"] forState:UIControlStateNormal];
    [self.button2D setImage:[UIImage imageNamed:@"layer_2d_selected"] forState:UIControlStateSelected];
    [self.button3D setImage:[UIImage imageNamed:@"layer_3d_selected"] forState:UIControlStateSelected];
    [self.button2D setTitle:@"2D地图" forState:UIControlStateNormal];
    [self.button3D setTitle:@"3D地图" forState:UIControlStateNormal];
    [self.button2D addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.button3D addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *viewsDict = @{@"button2D": self.button2D, @"button3D": self.button3D};
    CGFloat padding = 10.0;
    CGFloat margin = 32.0;
    NSDictionary *metrics = @{@"padding": @(padding), @"margin": @(margin)};
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(margin)-[button2D]-(==padding)-[button3D]-(margin)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:viewsDict]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(40.0)-[button2D]-(==padding)-|" options:kNilOptions metrics:metrics views:viewsDict]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(40.0)-[button3D]-(==padding)-|" options:kNilOptions metrics:metrics views:viewsDict]];
    [NSLayoutConstraint constraintWithItem:self.button2D attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.button3D attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.button2D attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.button3D attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0].active = YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)buttonAction:(SideslipTableViewHeaderViewButton *)button {
    self.lastSelectedButton.selected = NO;
    
    button.selected = YES;
    self.lastSelectedButton = button;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Lazy
////////////////////////////////////////////////////////////////////////

- (SideslipTableViewHeaderViewButton *)button2D {
    if (!_button2D) {
        _button2D = [SideslipTableViewHeaderViewButton new];
        _button2D.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _button2D;
}

- (SideslipTableViewHeaderViewButton *)button3D {
    if (!_button3D) {
        _button3D = [SideslipTableViewHeaderViewButton new];
        _button3D.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _button3D;
}

@end

