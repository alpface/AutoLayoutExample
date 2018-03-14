//
//  NaviActionController.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/13.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "NaviActionController.h"
#import <objc/runtime.h>

#define CONTAINERVIEW_MARGIN 10.0
static void *NaviActionControllerKey = &NaviActionControllerKey;

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
/// 每行item的个数, 此方法会根据设置的间距itemHPadding值，自适应item的宽度
@property (nonatomic, assign) IBInspectable NSUInteger maxNumberOfLine;
/// 正方形，设置此属性后，宽高相同
/// @note 当设置itemHeight时，且square==YES 则宽度=高度
@property (assign, nonatomic, getter = isSquare) BOOL square;
@property (nonatomic, assign) IBInspectable CGFloat itemHPadding;
@property (nonatomic, assign) IBInspectable CGFloat itemVPadding;
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *viewConstraints;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NaviActionButton *> *> *lineArray;
- (void)reloadItems;
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
//    self.containerView.itemHeight = 100.0;
    self.containerView.maxNumberOfLine = 3;
    self.containerView.itemHPadding = 10.0;
    self.containerView.itemVPadding = 10.0;
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
    CGFloat topMargin = 50.0;
    if (self.isShow == NO) {
        topMargin = [UIScreen mainScreen].bounds.size.height;
    }
    [self.viewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:topMargin]];
    [NSLayoutConstraint activateConstraints:self.viewConstraints];
}

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

- (void)show {
    
    self.show = YES;
    
    // 执行此次layoutIfNeeded是为了防止下面的动画把所有的布局都执行了，会导致view从顶部开始出现的问题
//        [view layoutIfNeeded];
    // 另外一种方案：加入到主队列中执行本次动画
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backgroundView.alpha = 0.3;
        [self containerViewTopConstraint].constant = 50.0;
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    });
}

- (void)dismiss {
    self.show = NO;
    [self containerViewTopConstraint].constant = [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:.2 animations:^{
        self.backgroundView.alpha = 0.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
//        [self.view.superview removeConstraints:self.view.constraints];
//        [self.view removeFromSuperview];
    }];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Notify
////////////////////////////////////////////////////////////////////////
- (void)didChangeStatusBarOrientation:(NSNotification *)notif {
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
    //    self.cellModel.height = size.height;
}

- (void)buttonClick:(NaviActionButton *)sender {
    
    
}
/// 将buttonArray中的所有按钮，根据maxNumberOfLine按组拆分(按maxNumberOfLine一组进行分组,目的是为了使用AutoLayout布局)
- (NSMutableArray<NSMutableArray<NaviActionButton *> *> *)lineArray {
    if (!_lineArray) {
        _lineArray = @[].mutableCopy;
    }
    return _lineArray;
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
                // 最后一行, 拼接底部
                [vFormat appendFormat:@"-(==vPadiing)-|"];
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
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    
}


/// 每行paddingView的数量
- (NSUInteger)paddingViewCountOfLine:(NSUInteger)line {
    // 获取这行item的数据
    NSArray *rowArray = self.lineArray[line];
    NSUInteger paddingCoutOfline = rowArray.count + 1;
    return paddingCoutOfline;
}


- (NaviActionButton *)createButton {
    NaviActionButton *btn = [NaviActionButton new];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    btn.layer.cornerRadius = 4.0;
//    btn.layer.borderColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:229/255.0 alpha:1.0].CGColor;
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    btn.layer.borderWidth = 1.0;
//    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIView *)createPaddingView {
    UIView *paddingView = [UIView new];
    paddingView.translatesAutoresizingMaskIntoConstraints = NO;
    paddingView.hidden = YES;
    return paddingView;
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
