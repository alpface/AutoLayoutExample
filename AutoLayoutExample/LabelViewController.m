//
//  LabelViewController.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/15.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "LabelViewController.h"

@interface LabelViewController ()

@property (nonatomic, strong) NSMutableArray<UILabel *> *labelArray;
@property (nonatomic, strong) NSArray<NSString *> *labelTextArray;

@end

@implementation LabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Adjustment priority" style:UIBarButtonItemStylePlain target:self action:@selector(adjustmentLabelPriority)];
    [self setupViews];
}

- (void)setupViews {
    CGFloat padding = 5.0;
    NSMutableDictionary *viewDict = @{}.mutableCopy;
    NSMutableString *vFormat = @"".mutableCopy;
    [self.labelTextArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [self labelWithText:obj];
        [self.view addSubview:label];
        [self.labelArray addObject:label];
        NSString *labelKey = [@"label" stringByAppendingString:@(idx).stringValue];
        [viewDict setObject:label forKey:labelKey];
        [vFormat appendFormat:@"-(%f)-[%@]", padding, labelKey];
        if (self.labelTextArray.count - 1 == idx) {
            [vFormat appendFormat:@"-(%f)-", padding];
        }
    }];
    if (vFormat.length) {
        id topLayoutGuide = self.topLayoutGuide;
        [viewDict setObject:topLayoutGuide forKey:@"topLayoutGuide"];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[topLayoutGuide]%@|", vFormat] options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:nil views:viewDict]];
    }
    UILabel *lastLabel = self.labelArray.lastObject;
    // 已确定所有的label之间左右都是对齐的，现在只需要让其中一个label相对一个已确定左右的控件约束即可
    [NSLayoutConstraint constraintWithItem:lastLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0].active = YES;
    [NSLayoutConstraint constraintWithItem:lastLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0].active = YES;
    
//    UILabel *firstLabel = self.labelArray.firstObject;
    // 该优先级表示一个控件抗被拉伸的优先级。优先级越高，越不容易被拉伸，默认是250。
//    [firstLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    // 该优先级和setContentHuggingPriority优先级相对应，表示一个控件抗压缩的优先级。优先级越高，越不容易被压缩，默认是750
    [lastLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

- (void)adjustmentLabelPriority {
    int randomIdx = arc4random_uniform((int)self.labelArray.count);
    UILabel *label = self.labelArray[randomIdx];
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.labelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:label] == NO) {
            [obj setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        }
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *label = [UILabel new];
    label.text = text;
    label.numberOfLines = 0;
    label.translatesAutoresizingMaskIntoConstraints = false;
    label.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
    return label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSArray<NSString *> *)labelTextArray {
    return @[
      @"我的母亲很高兴，但也藏着许多凄凉的神情，教我坐下，歇息，喝茶，且不谈搬家的事。宏儿没有见过我，远远的对面站着只是看。\n'你休息一两天，去拜望亲戚本家一回，我们便可以走了'。母亲说。",
      @"我的父亲允许了;",
      /*我也很高兴，因为我早听到闰土这名字，而且知道他和我仿佛年纪，闰月生的，五行缺土⑷，所以他的父亲叫他闰土。他是能装〔弓京〕捉小鸟雀的。\n我们那时候不知道谈些什么，只记得闰土很高兴，说是上城之后，见了许多没有见过的东西。*/
      @"\"现在太冷，你夏天到我们这里来。我们日里到海边捡贝壳去，红的绿的都有，鬼见怕也有，观音手⑸也有。晚上我和爹管西瓜去，你也去。\"",
      @"\"不是。走路的人口渴了摘一个瓜吃，我们这里是不算偷的。要管的是獾猪，刺猬，猹。月亮底下，你听，啦啦的响了，猹在咬瓜了。你便捏了胡叉，轻轻地走去……\"\n我那时并不知道这所谓猹的是怎么一件东西——便是现在也没有知道——只是无端的觉得状如小狗而很凶猛。",
      @"阿!闰土的心里有无穷无尽的希奇的事，都是我往常的朋友所不知道的。他们不知道一些事，闰土在海边时，他们都和我一样只看见院子里高墙上的四角的天空。\n现在我的母亲提起了他，我这儿时的记忆，忽而全都闪电似的苏生过来，似乎看到了我的美丽的故乡了。我应声说：\n\"这好极!他，——怎样?……\"\n\"他?……他景况也很不如意……\"母亲说着，便向房外看，\"这些人又来了。说是买木器，顺手也就随便拿走的，我得去看看。\"",
      ];
}
- (NSMutableArray<UILabel *> *)labelArray {
    if (!_labelArray) {
        _labelArray = @[].mutableCopy;
    }
    return _labelArray;
}
@end
