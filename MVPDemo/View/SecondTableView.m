//
//  SecondTableView.m
//  MVPDemo
//
//  Created by wangjingmac on 16/9/9.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import "SecondTableView.h"
#import "SecondTableViewCell.h"
#import "SecondModel.h"
#import "MVPViewController.h"

@implementation SecondTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // 设置代理对象
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id post = [[SecondModel alloc] initWithContentsOfDic:self.dataArray[indexPath.row]];
    
    tableView.separatorStyle = YES;
    SecondTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld",(long)indexPath.row]];
    
    if(cell == nil)
    {
        cell = [[SecondTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[NSString stringWithFormat:@"cell%ld",(long)indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([cell respondsToSelector:@selector(presenter)]) {
        NSObject<AMNPresenterProtocol> *presenter = [cell presenter];
        [presenter presentWithModel:post viewController:self.viewController];
    }
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MVPViewController *MVPView = [[MVPViewController alloc] init];
    [self.viewController.navigationController pushViewController:MVPView animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
}

@end
