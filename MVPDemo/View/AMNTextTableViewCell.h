//
//  AMNTextTableViewCell.h
//  MVPExample-ObjectiveC
//
//  Created by wangjingmac on 16/9/7.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMNTextPresenter.h"

@interface AMNTextTableViewCell : UITableViewCell <AMNTextPresenterProtocol>
@property (nonatomic) AMNTextPresenter *presenter;
@end
