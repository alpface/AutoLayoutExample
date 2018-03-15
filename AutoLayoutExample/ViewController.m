//
//  ViewController.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/14.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "ViewController.h"
#import "NaviViewController.h"
#import "DragViewController.h"
#import "LabelViewController.h"

@interface AutoLayoutExampleItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) Class exampleClass;

- (instancetype)initWithTitle:(NSString *)title exampleClass:(Class)clas;

@end

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<AutoLayoutExampleItem *> *tableArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupViews];
    self.tableArray = @[
                        [[AutoLayoutExampleItem alloc] initWithTitle:@"Navi action menu" exampleClass:[NaviViewController class]],
                        [[AutoLayoutExampleItem alloc] initWithTitle:@"Drag" exampleClass:[DragViewController class]],
                        [[AutoLayoutExampleItem alloc] initWithTitle:@"Label Text" exampleClass:[LabelViewController class]]
                        ].mutableCopy;
    
    [self.tableView reloadData];
}

- (void)setupViews {
    [self.view addSubview:self.tableView];
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [UITableView new];
        _tableView = tableView;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.translatesAutoresizingMaskIntoConstraints = false;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    }
    return _tableView;
}

- (NSMutableArray *)tableArray {
    if (!_tableView) {
        _tableArray = [NSMutableArray array];
    }
    return _tableArray;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource, UITableViewDelegate
////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = self.tableArray[indexPath.row].title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AutoLayoutExampleItem *item = self.tableArray[indexPath.row];
    UIViewController *vc = [item.exampleClass new];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.title = item.title;
    [self showViewController:vc sender:self];
}
@end

@implementation AutoLayoutExampleItem

- (instancetype)initWithTitle:(NSString *)title exampleClass:(Class)clas {
    if (self = [super init]) {
        _title = title;
        _exampleClass = clas;
    }
    return self;
}

@end
