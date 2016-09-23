//
//  SecondTableView.h
//  MVPDemo
//
//  Created by wangjingmac on 16/9/9.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondTableView : UITableView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) UIViewController *viewController;
@property (nonatomic) NSArray *dataArray;

@end
