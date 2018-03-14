//
//  NaviActionController.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/13.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "NaviActionController.h"

@interface  NaviActionContentView : UIView
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttonArray;
@property (nonatomic, strong) NSMutableArray<NaviActionItem *> *items;
// item高度
@property (nonatomic, assign) IBInspectable CGFloat itemHeight;
/// 每行item的个数, 此方法会根据设置的间距itemHPadding值，自适应item的宽度
@property (nonatomic, assign) IBInspectable NSUInteger maxNumberOfLine;
/// 正方形，设置此属性后，宽高相同
@property (assign, nonatomic, getter = isSquare) BOOL square;
@property (nonatomic, assign) IBInspectable CGFloat itemHPadding;
@property (nonatomic, assign) IBInspectable CGFloat itemVPadding;
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *viewConstraints;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<UIButton *> *> *lineArray;
- (void)reloadItems;
@end

@interface NaviActionController ()

@property (nonatomic, strong) NaviActionContentView *collectionView;

@end


@implementation NaviActionController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
    
    [self.collectionView.items removeAllObjects];
    [self.collectionView.items addObjectsFromArray:self.items];
    [self.collectionView reloadItems];
}

- (void)setupViews {
    [self.view addSubview:self.collectionView];
//    self.collectionView.itemHeight = 100.0;
    self.collectionView.maxNumberOfLine = 3;
    self.collectionView.itemHPadding = 10.0;
    self.collectionView.itemVPadding = 10.0;
    self.collectionView.square = YES;
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(5.0)-[collectionView]-(5.0)-|" options:kNilOptions metrics:nil views:@{@"collectionView": self.collectionView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=50.0)-[collectionView]-(5.0)-|" options:kNilOptions metrics:nil views:@{@"collectionView": self.collectionView}]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}


- (NaviActionContentView *)collectionView {
    if (!_collectionView) {
        NaviActionContentView *collectionView = [[NaviActionContentView alloc] initWithFrame:CGRectZero];
        _collectionView = collectionView;
        collectionView.translatesAutoresizingMaskIntoConstraints = false;
    }
    return _collectionView;
}



////////////////////////////////////////////////////////////////////////
#pragma mark - Notify
////////////////////////////////////////////////////////////////////////
- (void)didChangeStatusBarOrientation:(NSNotification *)notif {

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
        UIButton *button = [self createCityButton];
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
            UIButton *button = self.buttonArray.lastObject;
            [button removeFromSuperview];
            [self.buttonArray removeObject:button];
            differencesCount++;
        }
    }
    else if (differencesCount > 0) {
        // 缺少控件，就创建
        while (differencesCount > 0) {
            UIButton *button = [self createCityButton];
            [self.buttonArray addObject:button];
            [self addSubview:button];
            differencesCount--;
        }
    }
    
    NSParameterAssert(self.buttonArray.count == totalCount);
    //////////////////
    
    // 给控件设置值
    for (NSInteger i = 0; i < totalCount; ++i) {
        UIButton *button = self.buttonArray[i];
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

- (void)buttonClick:(UIButton *)sender {
    
    
}
/// 将buttonArray中的所有按钮，根据maxNumberOfLine按组拆分(按maxNumberOfLine一组进行分组,目的是为了使用AutoLayout布局)
- (NSMutableArray<NSMutableArray<UIButton *> *> *)lineArray {
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
        UIButton *btn = self.buttonArray[i];
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
        UIButton *previousBtn = nil;
        NSString *previousBtnKey = nil;
        for (NSInteger j = 0; j < rowArray.count; j++) {
            UIButton *btn = rowArray[j];
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
            UIButton *dependentTopBtn = nil;
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


- (UIButton *)createCityButton {
    UIButton *btn = [UIButton new];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitle:@"北京" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    btn.layer.cornerRadius = 4.0;
//    btn.layer.borderColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:229/255.0 alpha:1.0].CGColor;
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
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
