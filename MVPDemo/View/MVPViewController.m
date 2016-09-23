//
//  MVPViewController.m
//  MVPDemo
//
//  Created by wangjingmac on 16/9/7.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import "MVPViewController.h"
#import "AMNPresenterProtocol.h"
#import "AMNTextTableViewCell.h"
#import "AMNTimeline.h"

@interface MVPViewController ()


@end

@implementation MVPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"MVP";
    self.view.backgroundColor = [UIColor whiteColor];

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

@end
