//
//  SecondTableViewCell.h
//  MVPDemo
//
//  Created by wangjingmac on 16/9/8.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMNTextPresenter.h"

@interface SecondTableViewCell : UITableViewCell<AMNTextPresenterProtocol>
@property (nonatomic) AMNTextPresenter *presenter;

@end
