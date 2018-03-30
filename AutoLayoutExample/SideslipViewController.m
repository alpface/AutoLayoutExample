//
//  SideslipViewController.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/30.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "SideslipViewController.h"
#import <objc/runtime.h>


static CGFloat const TableViewWidthMultiplierValue = 0.6;
static CGFloat const BackgroundViewMaxAlpha = 0.3;
static void * SideslipViewControllerKey = &SideslipViewControllerKey;

typedef NS_ENUM(NSInteger, SideslipTableViewScrollDirection) {
    SideslipTableViewScrollDirectionNotKnow,
    SideslipTableViewScrollDirectionVertical,
    SideslipTableViewScrollDirectionHorizontal
};


@interface SideslipTableView ()

@property (nonatomic, copy) void (^ sideslipPanGestureRecognizerBlock)(UIPanGestureRecognizer *pan);

@end

@interface SideslipViewController ()

@property (nonatomic, strong) UIView *backgroundView;
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
#pragma mark - Public methods
////////////////////////////////////////////////////////////////////////

+ (instancetype)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL isShow))completion {
    SideslipViewController *vc = objc_getAssociatedObject([UIApplication sharedApplication], SideslipViewControllerKey);
    if (vc == nil) {
        vc = [[self alloc] init];
        objc_setAssociatedObject([UIApplication sharedApplication], SideslipViewControllerKey, vc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (vc.view.superview) {
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

+ (__kindof SideslipViewController *)displaySideslipViewController {
    SideslipViewController *vc = objc_getAssociatedObject([UIApplication sharedApplication], SideslipViewControllerKey);
    if (vc.isShow) {
        return vc;
    }
    return nil;
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
        self.backgroundView.alpha = BackgroundViewMaxAlpha;
        [self _updateConstraints];
        [UIView animateWithDuration:animated ? 0.3 : 0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
            [[UIApplication sharedApplication].delegate.window.rootViewController setNeedsStatusBarAppearanceUpdate];
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
        [[UIApplication sharedApplication].delegate.window.rootViewController setNeedsStatusBarAppearanceUpdate];
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
    
    self.backgroundView.alpha = BackgroundViewMaxAlpha * (1.0 - progress);
    NSLog(@"backgroundAlpha:%f", self.backgroundView.alpha);
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
        SideslipTableView *tableView = [[SideslipTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView = tableView;
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
            if ([gestureRecognizer isEqual:_sideslipPanGestureRecognizer]) {
                return YES;
            }
            else {
                return NO;
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
            if ([gestureRecognizer isEqual:_sideslipPanGestureRecognizer]) {
                return YES;
            }
            else {
                return NO;
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


