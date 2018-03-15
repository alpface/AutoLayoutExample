//
//  DragViewController.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/15.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "DragViewController.h"

@interface DragViewController ()

@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;

@end

@implementation DragViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
}

- (void)setupViews {
    [self.view addSubview:self.button1];
    [self.view addSubview:self.button2];
    
    UIPanGestureRecognizer *pan1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerActionOnButton:)];
    [self.button1 addGestureRecognizer:pan1];
    UIPanGestureRecognizer *pan2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerActionOnButton:)];
    [self.button2 addGestureRecognizer:pan2];
    
    CGFloat padding = 80.0;
    id topLayoutGuide = self.topLayoutGuide;
    NSDictionary *viewDict = @{@"button1": self.button1, @"button2": self.button2, @"topLayoutGuide": topLayoutGuide};
    // 添加这两个button相对父控件的垂直约束，并且这两个控件的中心点x轴对齐NSLayoutFormatAlignAllCenterX(也就是垂直对齐)
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-(padding)-[button1]-(==padding)-[button2(>=0)]->=0-|" options:NSLayoutFormatAlignAllCenterX metrics:@{@"padding": @(padding)} views:viewDict]];
    // 然后只需要确定好这两个button中其中一个的中心点x轴相对布局即可
    [NSLayoutConstraint constraintWithItem:self.button1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0].active = YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)panGestureRecognizerActionOnButton:(UIPanGestureRecognizer *)pan {
    
    CGPoint translation = [pan translationInView:self.view];
    CGPoint translationCenter = CGPointMake(translation.x + pan.view.center.x,
                                            translation.y + pan.view.center.y);
    CGPoint panViewCenter = [self.view convertPoint:pan.view.center toView:self.view];
    // 重置translation
    [pan setTranslation:CGPointZero inView:self.view];
    
    switch (pan.state) {
        case UIGestureRecognizerStateChanged: {
//            [UIView animateWithDuration:0.10 animations:^{
                /// @note: 由于此处是更新视图的中心点坐标，通过AutoLayout的约束不会受影响，所以在下一次重新布局时(比如执行layoutIfNeeded)时，中心点坐标将会被恢复为约束时的布局
                pan.view.center = translationCenter;
//            }];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            // 计算速度向量的长度，当他小于200时，滑行会很短
            CGPoint velocity = [pan velocityInView:self.view];
            // 计算速度向量的长度
            CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
            CGFloat slideMult = magnitude / 200;
            // 基于速度和速度因素计算一个终点
            float slideFactor = 0.1 * slideMult;
            CGPoint finalPoint = CGPointMake(panViewCenter.x + (velocity.x * slideFactor),  panViewCenter.y + (velocity.y * slideFactor));
            [UIView animateWithDuration:0.30 animations:^{
                /// @note: 由于此处是更新视图的中心点坐标，通过AutoLayout的约束不会受影响，所以在下一次重新布局时(比如执行layoutIfNeeded)时，中心点坐标将会被恢复为约束时的布局
                pan.view.center = finalPoint;
            } completion:^(BOOL finished) {
                // 手势结束时恢复布局
                [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.3 initialSpringVelocity:10.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.view setNeedsLayout];
                    [self.view layoutIfNeeded];
                } completion:^(BOOL finished) {
                    
                }];
            }];
            
            break;
        }
        default:
            break;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (UIButton *)button1 {
    if (!_button1) {
        UIButton *btn = UIButton.new;
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        btn.backgroundColor = [UIColor grayColor];
        btn.layer.cornerRadius = 5.0;
        btn.layer.masksToBounds = YES;
        _button1 = btn;
    }
    return _button1;
}
- (UIButton *)button2 {
    if (!_button2) {
        UIButton *btn = UIButton.new;
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        btn.backgroundColor = [UIColor redColor];
        btn.layer.cornerRadius = 5.0;
        btn.layer.masksToBounds = YES;
        _button2 = btn;
    }
    return _button2;
}


@end
