//
//  ButtonListViewController.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/8/3.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import "ButtonListViewController.h"
#import "TourSpecialRecommentCell.h"

@interface ButtonListViewController ()
@property (nonatomic, strong) NSArray<BBTourSpecialRecommentModel *> *models;
@end

@implementation ButtonListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[TourSpecialRecommentCell class] forCellReuseIdentifier:@"TourSpecialRecommentCell"];
    
    NSMutableArray *arr = @[].mutableCopy;
    for (NSInteger i =0; i < 8; i++) {
        BBTourSpecialRecommentModel *model = [BBTourSpecialRecommentModel new];
        model.buttonMarginInsets = UIEdgeInsetsMake(14.0, 0, 14.0, 0.0);
        model.buttonHeight = @30.0;
        model.attTitle = [[NSAttributedString alloc] initWithString:@"专用推荐"];
        if (i%2==0) {
            model.recomments = @[@"ksks", @"ksdjkas", @"阿萨德啦咔咔", @"sds"];
        }
        else {
            model.recomments = @[@"ksks", @"ksdjkas", @"阿萨德啦咔咔", @"sds", @"sassa"];
        }
        if (i == 5) {
            model.recomments = @[@"ksks", @"ksdjkas", @"阿萨德啦咔咔", @"sds", @"sassa", @"kkksk",@"ksks", @"ksdjkas", @"阿萨德啦咔咔", @"sds", @"sassa", @"kkksk"];
        }
        
        model.maxColumnCount = 3;
        model.clickButtonAction = ^(UIButton *btn) {
            
        };
        [arr addObject:model];
    }
    self.models = arr;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TourSpecialRecommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TourSpecialRecommentCell" forIndexPath:indexPath];
    
    cell.model = self.models[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = self.models[indexPath.row].cellHeight;
    return height;
}

@end
