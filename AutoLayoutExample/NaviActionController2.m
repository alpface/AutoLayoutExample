//
//  NaviActionController2.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/13.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "NaviActionController2.h"

#define CONTAINERVIEW_MARGIN 6.0
#define CONTAINERVIEW_LEFT_MARGIN (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? CONTAINERVIEW_MARGIN : 164.0)
#define CONTAINERVIEW_TOP_MAX_MARGIN (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? (self.items.count>6 ? [UIScreen mainScreen].bounds.size.height*0.3 : [UIScreen mainScreen].bounds.size.height*0.55) : [UIApplication sharedApplication].statusBarFrame.size.height+44.0+CONTAINERVIEW_MARGIN*2)
#define CONTAINERVIEW_MAX_ITEM_COUNT (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 3 : 3)



@interface NaviActionController2 ()
@property (nonatomic, strong) NaviActionContentView *containerView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign, getter=isShow) BOOL show;
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *viewConstraints;
@end


@implementation NaviActionController2

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
    self.containerView.itemVPadding = 15.0;
    self.containerView.itemHPadding = [self getHPadding];
    // 设置这两个属性会导致屏幕旋转时，containerView的高度会超出父视图
    //    self.containerView.itemHeight = 100.0;
    //    self.containerView.square = YES;
    
    
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundView]|" options:kNilOptions metrics:nil views:@{@"backgroundView": self.backgroundView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|" options:kNilOptions metrics:nil views:@{@"backgroundView": self.backgroundView}]];
    
    [self.view updateConstraintsIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [self.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBackgroundView:)]];
    
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    if (self.view.superview == nil || self.containerView.superview == nil) {
        return;
    }
    [NSLayoutConstraint deactivateConstraints:self.viewConstraints];
    [self.viewConstraints removeAllObjects];
    NSDictionary *metrics = @{@"margin": @(CONTAINERVIEW_MARGIN), @"leftMargin": @(CONTAINERVIEW_LEFT_MARGIN)};
    [self.viewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(leftMargin)-[containerView]-(margin)-|" options:kNilOptions metrics:metrics views:@{@"containerView": self.containerView}]];
    CGFloat topMargin = CONTAINERVIEW_TOP_MAX_MARGIN;
    // 未显示状态下的containerView
    [self.viewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-topMargin]];
    [self.viewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    // 显示状态下的containerView
    [self.viewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-CONTAINERVIEW_MARGIN]];
    
    [NSLayoutConstraint activateConstraints:self.viewConstraints];
    [self _update];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (NSMutableArray<NSLayoutConstraint *> *)viewConstraints {
    if (!_viewConstraints) {
        _viewConstraints = @[].mutableCopy;
    }
    return _viewConstraints;
}


- (NSLayoutConstraint *)containerViewLeftConstraint {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem==%@ AND secondItem==%@ AND firstAttribute==%ld ", self.containerView, self.view, NSLayoutAttributeLeading];
    NSLayoutConstraint *constraint = [self.viewConstraints filteredArrayUsingPredicate:predicate].firstObject;
    return constraint;
}

/// 显示状态下的顶部约束
- (NSLayoutConstraint *)containerViewHeightConstraintOfShow {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem==%@ AND secondItem==%@ AND firstAttribute==%ld ", self.containerView, self.view, NSLayoutAttributeHeight];
    NSLayoutConstraint *constraint = [self.viewConstraints filteredArrayUsingPredicate:predicate].firstObject;
    return constraint;
}

/// 未显示状态下的顶部约束
- (NSLayoutConstraint *)containerViewTopConstraintOfDismiss {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem==%@ AND secondItem==%@ AND firstAttribute==%ld AND secondAttribute==%ld", self.containerView, self.view, NSLayoutAttributeTop, NSLayoutAttributeBottom];
    NSLayoutConstraint *constraint = [self.viewConstraints filteredArrayUsingPredicate:predicate].firstObject;
    return constraint;
}

- (NSLayoutConstraint *)containerViewBottomConstraint {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem==%@ AND secondItem==%@ AND firstAttribute==%ld AND secondAttribute==%ld", self.containerView, self.view, NSLayoutAttributeBottom, NSLayoutAttributeBottom];
    NSLayoutConstraint *constraint = [self.viewConstraints filteredArrayUsingPredicate:predicate].firstObject;
    return constraint;
}

- (void)_update {
    if (self.isShow) {
        [self containerViewTopConstraintOfDismiss].active = NO;
        [self containerViewBottomConstraint].active = YES;
    }
    else {
        [self containerViewTopConstraintOfDismiss].active = YES;
        [self containerViewBottomConstraint].active = NO;
    }
}

- (NaviActionContentView *)containerView {
    if (!_containerView) {
        NaviActionContentView *containerView = [[NaviActionContentView alloc] initWithFrame:CGRectZero];
        _containerView = containerView;
        containerView.translatesAutoresizingMaskIntoConstraints = false;
        __weak typeof(&*self) weakSelf = self;
        containerView.buttonActionBlock = ^(NaviActionItem *item) {
            if (item.clickBlock) {
                item.clickBlock(item);
            }
            __strong typeof(&*weakSelf) self = weakSelf;
            if (self.delegate && [self.delegate respondsToSelector:@selector(naviActionView:didClickItem:)]) {
                [self.delegate naviActionView:self.containerView didClickItem:item];
            }
        };
        UIView *bottomView = [UIView new];
        bottomView.backgroundColor = [UIColor clearColor];
        UIButton *button = [UIButton new];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        button.translatesAutoresizingMaskIntoConstraints = false;
        [button setTitle:@"cancel" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:button];
        bottomView.backgroundColor = [UIColor clearColor];
        [button setBackgroundColor:[UIColor whiteColor]];
        button.layer.cornerRadius = 5.0;
        button.layer.masksToBounds = YES;
        button.layer.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1.0].CGColor;
        CGFloat padding = 10.0;
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(==padding)-[button]-(==padding)-|" options:kNilOptions metrics:@{@"padding": @(padding)} views:@{@"button": button}]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==5.0)-[button]-(==padding)-|" options:kNilOptions metrics:@{@"padding": @(padding)} views:@{@"button": button}]];
        
        [containerView setBottomView:bottomView animated:NO height:50.0];
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

//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self dismiss];
//}

- (void)tapOnBackgroundView:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        [self dismissWithAnimated:YES];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (void)showWithAnimated:(BOOL)animated {
    
    self.show = YES;
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    // 执行此次layoutIfNeeded是为了防止下面的动画把所有的布局都执行了，会导致view从顶部开始出现的问题
    //    [self.view layoutIfNeeded];
    // 另外一种方案：加入到主队列中执行本次动画
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backgroundView.alpha = 0.3;
        [self _update];
        if (animated) {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(naviActionViewDidShow:)]) {
                    [self.delegate naviActionViewDidShow:self.containerView];
                }
                //                [self performSelector:@selector(dismiss) withObject:nil afterDelay:5.0];
            }];
        }
        else {
            [self.view layoutIfNeeded];
            if (self.delegate && [self.delegate respondsToSelector:@selector(naviActionViewDidShow:)]) {
                [self.delegate naviActionViewDidShow:self.containerView];
            }
            //            [self performSelector:@selector(dismiss) withObject:nil afterDelay:5.0];
        }
        
    });
}

- (void)dismiss {
    [self dismissWithAnimated:YES];
}

- (void)dismissWithAnimated:(BOOL)animated {
    self.show = NO;
    [self _update];
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.backgroundView.alpha = 0.0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(naviActionViewDidDismiss:)]) {
                [self.delegate naviActionViewDidDismiss:self.containerView];
            }
        }];
    }
    else {
        [self.view layoutIfNeeded];
        if (self.delegate && [self.delegate respondsToSelector:@selector(naviActionViewDidDismiss:)]) {
            [self.delegate naviActionViewDidDismiss:self.containerView];
        }
    }
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Notify
////////////////////////////////////////////////////////////////////////
- (void)didChangeStatusBarOrientation:(NSNotification *)notif {
    CGFloat hPadding = [self getHPadding];
    NSInteger maxCount = CONTAINERVIEW_MAX_ITEM_COUNT;
    if (hPadding != self.containerView.itemHPadding || maxCount != self.containerView.maxNumberOfLine) {
        self.containerView.maxNumberOfLine = maxCount;
        self.containerView.itemHPadding = hPadding;
        [self.containerView reloadItems];
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
}


- (CGFloat)getHPadding {
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        return [UIScreen mainScreen].bounds.size.width*0.1;
    }
    return [UIScreen mainScreen].bounds.size.width*0.08;
}


@end




