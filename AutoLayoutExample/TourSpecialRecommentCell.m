//
//  TourSpecialRecommentCell.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/8/3.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import "TourSpecialRecommentCell.h"

static CGFloat const BBButtonHPadding = 16.0; // 按钮和按钮之间的内间距
static CGFloat const BBButtonVPadding = 15.0; //
static CGFloat const BBGlobalMargin = 15.0;

@interface BBTourSpecialRecommentModel ()

@property (nonatomic, assign) CGFloat cellHeight;

@end

@interface BBTourSpecialRecommentButton : UIButton

@end

@interface TourSpecialRecommentCell ()

@property (nonatomic, strong) NSMutableArray<UIButton *> *cityButtonList;
@property (nonatomic, strong) NSArray *buttonItems;
@property (nonatomic, strong) UIView *buttonContentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *middleLine;
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *buttonConstraints;

@end

@implementation TourSpecialRecommentCell {
    NSLayoutConstraint *_titleLabelTopConstraint;
    NSLayoutConstraint *_buttonContentViewTopConstraint;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // 初始化时预备10个子控件做为循环使用的，为了优化，
        // 如果多了就添加，少了就移除
        [self.contentView addSubview:self.buttonContentView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.middleLine];
        
        NSLayoutConstraint *titleLabelTopConstraint =  [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BBGlobalMargin];
        titleLabelTopConstraint.active = YES;
        _titleLabelTopConstraint = titleLabelTopConstraint;
        
        [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:BBGlobalMargin].active = YES;
        [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:self.buttonContentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.buttonContentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-BBGlobalMargin].active = YES;
        NSLayoutConstraint *buttonContentViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.buttonContentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:BBGlobalMargin];
        buttonContentViewTopConstraint.active = YES;
        _buttonContentViewTopConstraint = buttonContentViewTopConstraint;
        
        [NSLayoutConstraint constraintWithItem:self.buttonContentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:self.middleLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.buttonContentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.middleLine attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.buttonContentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.middleLine attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.buttonContentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.middleLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1.0].active = YES;
        
        for (NSInteger i = 0; i < 10; i++) {
            UIButton *button = [self createCityButton];
            [self.cityButtonList addObject:button];
            [self.buttonContentView addSubview:button];
        }
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
    }
    return self;
}

- (void)setModel:(BBTourSpecialRecommentModel *)model {
    _model = model;
    
    self.buttonItems = model.recomments;
    if (model.attTitle.length == 0) {
        _titleLabelTopConstraint.constant = 0.0;
        _buttonContentViewTopConstraint.constant = 0.0;
    }
    else {
        _titleLabelTopConstraint.constant = BBGlobalMargin;
        _buttonContentViewTopConstraint.constant = BBGlobalMargin;
    }
    self.titleLabel.attributedText = model.attTitle;
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    if (self.frame.size.height <= 0) {
        [self sizeToFit];
    }
    model.cellHeight = self.frame.size.height;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize s = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return s;
}
- (void)setButtonItems:(NSArray *)buttonItems {
    
    if ([buttonItems isEqualToArray:_buttonItems]) {
        return;
    }
    
    _buttonItems = buttonItems;
    
    NSInteger totalCount = buttonItems.count;
    
    // 计算已有的子控件数量与需要展示的个数的差值
    NSInteger differencesCount = differencesCount = totalCount - self.cityButtonList.count;
    if (differencesCount == 0) {
        // 没有差值，不需要创建新的，也不需要移除多余的
    }
    else if (differencesCount < 0) {
        // 多余的需要移除
        //        differencesCount = labs(differencesCount);
        while (differencesCount < 0) {
            UIButton *button = self.cityButtonList.lastObject;
            [button removeFromSuperview];
            [self.cityButtonList removeObject:button];
            differencesCount++;
        }
    }
    else if (differencesCount > 0) {
        // 缺少控件，就创建
        while (differencesCount > 0) {
            UIButton *button = [self createCityButton];
            [self.cityButtonList addObject:button];
            [self.buttonContentView addSubview:button];
            differencesCount--;
        }
    }
    
    NSParameterAssert(self.cityButtonList.count == totalCount);
    //////////////////
    
    // 给控件设置值
    for (NSInteger i = 0; i < totalCount; ++i) {
        UIButton *button = self.cityButtonList[i];
        button.tag = i;
        NSString *title = buttonItems[i];
        button.hidden = NO;
        [button setTitle:title forState:UIControlStateNormal];
    }
    
    // 取出总数取余maxColumnCount的值，这个创建为占位视图，方便布局使用
    if (totalCount % self.model.maxColumnCount != 0) {
        int c = abs( self.model.maxColumnCount - (totalCount % self.model.maxColumnCount));
        for (NSInteger i = 0; i < c; i++) {
            UIButton *button = [self createCityButton];
            [self.cityButtonList addObject:button];
            [self.buttonContentView addSubview:button];
            button.hidden = YES;
        }
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)buttonClick:(UIButton *)sender {
    
    if (self.model.clickButtonAction) {
        self.model.clickButtonAction(sender);
    }
}


/// 此约束会根据子控件的高度，固定父控件的高度
- (void)updateConstraints {
    [super updateConstraints];
    
    if (self.buttonConstraints == nil) {
        self.buttonConstraints = @[].mutableCopy;
    }
    
    [NSLayoutConstraint deactivateConstraints:self.buttonConstraints];
    [self.buttonConstraints removeAllObjects];
    
    if (self.cityButtonList.count == 0) {
        return;
    }
    
    // 最大的列数
    NSInteger columnCount = self.model.maxColumnCount ?: 3;
    //NSInteger rowCount = ceil(self.cityButtonList.count/(CGFloat)columnCount);
    // 将cityButtonList中的所有按钮，按组拆分(按rowCount一组进行分组,目的是为了使用AutoLayout布局)
    NSMutableArray *sectionArray = @[].mutableCopy;
    
    for (NSInteger i = 0; i < self.cityButtonList.count; i++) {
        NSInteger rowIndex = i / columnCount;
        NSMutableArray *rowArray = nil;
        if (rowIndex >= sectionArray.count) {
            rowArray = [NSMutableArray array];
            [sectionArray addObject:rowArray];
        }
        else {
            rowArray = [sectionArray objectAtIndex:rowIndex];
        }
        UIButton *btn = self.cityButtonList[i];
        [rowArray addObject:btn];
    }
    
    CGFloat hPadding = BBButtonHPadding;
    CGFloat vPadiing = BBButtonVPadding;
    CGFloat leftMargin = self.model.buttonMarginInsets.left;
    CGFloat rightMargin = self.model.buttonMarginInsets.right;
    CGFloat topMargin = self.model.buttonMarginInsets.top;
    CGFloat bottomMargin = self.model.buttonMarginInsets.bottom;
    NSMutableArray *constraints = self.buttonConstraints;
    NSMutableDictionary *metrics = @{@"hPadding": @(hPadding), @"vPadiing": @(vPadiing), @"leftMargin": @(leftMargin), @"rightMargin": @(rightMargin), @"topMargin": @(topMargin), @"bottomMargin": @(bottomMargin)}.mutableCopy;
    
    for (NSInteger i = 0; i < sectionArray.count; i++) {
        NSArray *rowArray = sectionArray[i];
        NSMutableString *hFormat = @"".mutableCopy;
        NSDictionary *hSubviewsDict = @{}.mutableCopy;
        UIButton *previousBtn = nil;
        NSString *previousBtnKey = nil;
        for (NSInteger j = 0; j < rowArray.count; j++) {
            UIButton *btn = rowArray[j];
            NSString *buttonKey = [NSString stringWithFormat:@"button_%ld_%ld", j, i];
            [hSubviewsDict setValue:btn forKey:buttonKey];
            
            // 子控件之间的列约束
            // 如果是第一个按钮就设置跟父控件的间距
            if (j == 0) {
                [hFormat appendFormat:@"-(==leftMargin)-[%@%@]", buttonKey, previousBtn?[NSString stringWithFormat:@"(%@)", previousBtnKey]:@""];
            }
            else {
                [hFormat appendFormat:@"-(==hPadding)-[%@%@]", buttonKey, previousBtn?[NSString stringWithFormat:@"(%@)", previousBtnKey]:@""];
            }
            
            if (j == rowArray.count - 1) {
                // 拼接最后一列的右侧间距
                [hFormat appendFormat:@"-(==rightMargin)-"];
            }
            
            // 子控件之间的行约束
            // 取出当前btn顶部依赖的控件，如果没有依赖则为父控件
            NSMutableString *vFormat = @"".mutableCopy;
            NSMutableDictionary *vSubviewsDict = @{}.mutableCopy;
            // 上一行的index
            NSInteger previousRowIndex = i - 1;
            // 取出当前按钮上面的按钮
            UIButton *dependentTopBtn = nil;
            if (previousRowIndex < sectionArray.count) {
                // 取出上一行的所有按钮
                NSArray *previousRowArray = [sectionArray objectAtIndex:previousRowIndex];
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
                // 顶部没有按钮
                [vFormat appendFormat:@"|-(==topMargin)-[%@%@]", buttonKey, previousBtn?[NSString stringWithFormat:@"(%@)", previousBtnKey]:@""];
            }
            
            if (i == sectionArray.count - 1) {
                // 最后一行, 拼接底部
                [vFormat appendFormat:@"-(==bottomMargin)-|"];
            }
            
            if (vFormat.length) {
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:%@", vFormat] options:kNilOptions metrics:metrics views:vSubviewsDict]];
            }
            
            // 如果设置了高度，则高度不再自适应
            if (self.model.buttonHeight) {
                [constraints addObject:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.model.buttonHeight.doubleValue]];
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

- (UIButton *)createCityButton {
    BBTourSpecialRecommentButton *btn = [BBTourSpecialRecommentButton new];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitle:@"北京" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (NSMutableArray *)cityButtonList {
    if (!_cityButtonList) {
        _cityButtonList = [NSMutableArray array];
    }
    return _cityButtonList;
}

+ (NSString *)defaultIdentifier {
    return [NSStringFromClass([self class]) stringByAppendingString:NSStringFromSelector(_cmd)];
}

- (UIView *)buttonContentView {
    if (!_buttonContentView) {
        _buttonContentView = [UIView new];
        _buttonContentView.backgroundColor = [UIColor clearColor];
        _buttonContentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _buttonContentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return _titleLabel;
}

- (UIView *)middleLine {
    if (!_middleLine) {
        _middleLine = [UIView new];
        _middleLine.backgroundColor = [UIColor colorWithRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1.0f];
        _middleLine.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _middleLine;
}

@end


@implementation BBTourSpecialRecommentModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxColumnCount = 3;
    }
    return self;
}

@end


@implementation BBTourSpecialRecommentButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 5.0, 0, 5.0);
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [[UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f] CGColor];
        self.layer.borderWidth = 1;
        [self setTitleColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0f] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:20/255.0 alpha:1.0f] forState:UIControlStateHighlighted];
        self.layer.cornerRadius = 4.0;
        self.layer.borderColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:229/255.0 alpha:1.0].CGColor;
        self.titleLabel.font = [UIFont systemFontOfSize:14.0];
        self.layer.borderWidth = 1.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.frame.size.height && self.frame.size.width) {
        self.layer.cornerRadius = self.frame.size.height * 0.5;
    }
}

@end

