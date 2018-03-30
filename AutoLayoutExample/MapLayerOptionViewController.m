//
//  MapLayerOptionViewController.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/30.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "MapLayerOptionViewController.h"

static NSString * const SideslipTableViewCellIdentifier = @"SideslipTableViewCellIdentifier";

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

@interface SideslipTableViewHeaderView : UIView

@end

@interface SideslipTableViewHeaderViewButton : UIButton

@end

@interface SideslipViewTableItem : NSObject

@property (nonatomic, copy) UIImage *iconImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL isSwitchOn;
@property (nonatomic, copy) void (^clickAction)(SideslipViewTableItem *item);
@property (nonatomic, copy) void (^switchChangeBlock)(BOOL isSwitchOn);

- (instancetype)initWithIconImage:(UIImage *)iconImage
                            title:(NSString *)title
                       isSwitchOn:(BOOL)isSwitchOn
                      clickAction:(void (^)(SideslipViewTableItem *item))clickAction
                switchChangeBlock:(void (^)(BOOL isSwitchOn))switchChangeBlock;


@end

@interface SideslipViewTableSection : NSObject

@property (nonatomic, strong) NSMutableArray<SideslipViewTableItem *> *items;

@end

@interface SideslipTableViewCell : UITableViewCell

@property (nonatomic, strong) SideslipViewTableItem *item;

@end


@interface MapLayerOptionViewController ()  <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray<SideslipViewTableSection *> *tableSections;

@end

@implementation MapLayerOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    SideslipTableViewHeaderView *headerView = [SideslipTableViewHeaderView new];
    headerView.frame = CGRectMake(0, 0, 0, 120.0);
    self.tableView.tableHeaderView = headerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[SideslipTableViewCell class] forCellReuseIdentifier:SideslipTableViewCellIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}


- (void)initData {
    
    SideslipViewTableSection *section = [[SideslipViewTableSection alloc] init];
    SideslipViewTableItem *item1 = [[SideslipViewTableItem alloc] initWithIconImage:[UIImage imageNamed:@"preference_3g4g"] title:@"Traffic info" isSwitchOn:NO clickAction:^(SideslipViewTableItem *item) {
        
    } switchChangeBlock:^(BOOL isSwitchOn) {
        
    }];
    [section.items addObject:item1];
    SideslipViewTableItem *item2 = [[SideslipViewTableItem alloc] initWithIconImage:[UIImage imageNamed:@"preference_local_language"] title:@"Local names" isSwitchOn:NO clickAction:^(SideslipViewTableItem *item) {
        
    } switchChangeBlock:^(BOOL isSwitchOn) {
        
    }];
    [section.items addObject:item2];
    SideslipViewTableItem *item3 = [[SideslipViewTableItem alloc] initWithIconImage:[UIImage imageNamed:@"preference_boobuz_on_map"] title:@"Community" isSwitchOn:NO clickAction:^(SideslipViewTableItem *item) {
        
    } switchChangeBlock:^(BOOL isSwitchOn) {
        
    }];
    [section.items addObject:item3];
    SideslipViewTableItem *item4 = [[SideslipViewTableItem alloc] initWithIconImage:[UIImage imageNamed:@"icon_chat_experience"] title:@"Moments" isSwitchOn:NO clickAction:^(SideslipViewTableItem *item) {
        
    } switchChangeBlock:^(BOOL isSwitchOn) {
        
    }];
    [section.items addObject:item4];
    SideslipViewTableItem *item5 = [[SideslipViewTableItem alloc] initWithIconImage:[UIImage imageNamed:@"icon_chat_experience"] title:@"World maps moments" isSwitchOn:NO clickAction:^(SideslipViewTableItem *item) {
        
    } switchChangeBlock:^(BOOL isSwitchOn) {
        
    }];
    [section.items addObject:item5];
    SideslipViewTableItem *item6 = [[SideslipViewTableItem alloc] initWithIconImage:[UIImage imageNamed:@"icon_place_photo"] title:@"Places photos" isSwitchOn:NO clickAction:^(SideslipViewTableItem *item) {
        
    } switchChangeBlock:^(BOOL isSwitchOn) {
        
    }];
    [section.items addObject:item6];
    [self.tableSections addObject:section];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableSections.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableSections[section].items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SideslipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SideslipTableViewCellIdentifier forIndexPath:indexPath];
    
    SideslipViewTableSection *section = self.tableSections[indexPath.section];
    SideslipViewTableItem *item = section.items[indexPath.row];
    cell.item = item;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SideslipViewTableSection *section = self.tableSections[indexPath.section];
    SideslipViewTableItem *item = section.items[indexPath.row];
    if (item.clickAction) {
        item.clickAction(item);
    }
}

- (NSMutableArray<SideslipViewTableSection *> *)tableSections {
    if (!_tableSections) {
        _tableSections = @[].mutableCopy;
    }
    return _tableSections;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

@interface SideslipTableViewCell ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *sw;
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
    
    [self.titleLabel setContentCompressionResistancePriority:20.0 forAxis:UILayoutConstraintAxisHorizontal];
    
    CGFloat margin = 16.0;
//    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(==margin)-[iconView]-(==margin)-[titleLabel]-(<=margin)-[sw]-(==13.0)-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"margin": @(margin)} views:@{@"iconView": self.iconView, @"titleLabel": self.titleLabel, @"sw": self.sw}]];
    
    [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:margin].active = YES;
     [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:margin].active = YES;
     [NSLayoutConstraint constraintWithItem:self.sw attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-margin].active = YES;
     [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.sw attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-margin].active = YES;
     [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.sw attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    
    
    [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-32].active = YES;
    [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0].active = YES;
    
    [self.sw addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)switchValueChange:(UISwitch *)sw {
    self.item.isSwitchOn = sw.isOn;
    
}

- (void)setItem:(SideslipViewTableItem *)item {
    _item = item;
    
    self.iconView.image = item.iconImage;
    self.titleLabel.text = item.title;
    self.sw.on = item.isSwitchOn;
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
    [self.button2D setTitle:@"2D map" forState:UIControlStateNormal];
    [self.button3D setTitle:@"3D map" forState:UIControlStateNormal];
    [self.button2D setTitleColor:[UIColor colorWithRed:0.0/255.0 green:105.0/255.0 blue:210.0/255.0 alpha:1.0] forState:UIControlStateSelected];
    [self.button3D setTitleColor:[UIColor colorWithRed:0.0/255.0 green:105.0/255.0 blue:210.0/255.0 alpha:1.0] forState:UIControlStateSelected];
    [self.button2D addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.button3D addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *lineView = [UIView new];
    [self addSubview:lineView];
    lineView.translatesAutoresizingMaskIntoConstraints = false;
    lineView.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    
    NSDictionary *viewsDict = @{@"button2D": self.button2D, @"button3D": self.button3D, @"lineView": lineView};
    CGFloat padding = 10.0;
    CGFloat margin = 32.0;
    NSDictionary *metrics = @{@"padding": @(padding), @"margin": @(margin)};
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(margin)-[button2D]-(==padding)-[button3D]-(margin)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:viewsDict]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(40.0)-[button2D]-(==padding)-[lineView]" options:kNilOptions metrics:metrics views:viewsDict]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(40.0)-[button3D]-(==padding)-[lineView]" options:kNilOptions metrics:metrics views:viewsDict]];
    [NSLayoutConstraint constraintWithItem:self.button2D attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.button3D attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.button2D attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.button3D attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[lineView]|" options:kNilOptions metrics:nil views:viewsDict]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lineView(==5.0)]|" options:kNilOptions metrics:nil views:viewsDict]];
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

@implementation SideslipViewTableItem

- (instancetype)initWithIconImage:(UIImage *)iconImage
                            title:(NSString *)title
                       isSwitchOn:(BOOL)isSwitchOn
                      clickAction:(void (^)(SideslipViewTableItem *item))clickAction
                switchChangeBlock:(void (^)(BOOL))switchChangeBlock    {
    if (self = [super init]) {
        self.iconImage = iconImage;
        self.title = title;
        self.isSwitchOn = isSwitchOn;
        self.clickAction = clickAction;
        self.switchChangeBlock = switchChangeBlock;
    }
    return self;
}

- (void)setIsSwitchOn:(BOOL)isSwitchOn {
    if (_isSwitchOn == isSwitchOn) {
        return;
    }
    _isSwitchOn = isSwitchOn;
    if (self.switchChangeBlock) {
        self.switchChangeBlock(isSwitchOn);
    }
}
@end

@implementation SideslipViewTableSection

- (NSMutableArray<SideslipViewTableItem *> *)items {
    if (!_items) {
        _items = @[].mutableCopy;
    }
    return _items;
}


@end

