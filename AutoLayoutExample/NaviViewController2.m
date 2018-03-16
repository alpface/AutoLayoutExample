//
//  NaviViewController2.m
//  AutoLayoutExample
//
//  Created by xiaoyuan on 2018/3/16.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "NaviViewController2.h"
#import "NaviActionController.h"

@interface NaviViewController2 ()

@end

@implementation NaviViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Class)naviActionActionClass {
    return [NaviActionController class];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
