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

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////
- (void)dismiss {
    [self dismissWithAnimated:YES];
}
- (void)showWithAnimated:(BOOL)animated {
    
    self.show = YES;
    
    // 执行此次layoutIfNeeded是为了防止下面的动画把所有的布局都执行了，会导致view从顶部开始出现的问题
//        [view layoutIfNeeded];
    // 另外一种方案：加入到主队列中执行本次动画
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backgroundView.alpha = 0.3;
        [self containerViewTopConstraint].constant = CONTAINERVIEW_TOP_MAX_MARGIN;
        if (animated) {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(naviActionViewDidShow:)]) {
                    [self.delegate naviActionViewDidShow:self.containerView];
                }
            }];
        }
        else {
            [self.view layoutIfNeeded];
            if (self.delegate && [self.delegate respondsToSelector:@selector(naviActionViewDidShow:)]) {
                [self.delegate naviActionViewDidShow:self.containerView];
            }
        }
        
    });
}

- (void)dismissWithAnimated:(BOOL)animated {
    self.show = NO;
    [self containerViewTopConstraint].constant = [UIScreen mainScreen].bounds.size.height;
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
    NSInteger maxCount = CONTAINERVIEW_MAX_ITEM_COUNT;
    if (maxCount != self.containerView.maxNumberOfLine) {
        self.containerView.maxNumberOfLine = maxCount;
        [self.containerView reloadItems];
    }
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
}


@end



