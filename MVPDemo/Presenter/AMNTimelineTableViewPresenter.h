//
//  AMNTimelineTableViewPresenter.h
//  MVPExample-ObjectiveC
//
//  Created by wangjingmac on 16/9/7.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMNPresenterProtocol.h"

@interface AMNTimelineTableViewPresenter : NSObject <UITableViewDataSource, UITableViewDelegate, AMNPresenterProtocol>
@property (nonatomic, weak) IBOutlet UITableView *view;
@property (nonatomic, weak) IBOutlet UIViewController *viewController;
@end
