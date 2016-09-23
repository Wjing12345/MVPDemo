//
//  AMNTextPresenter.m
//  MVPExample-ObjectiveC
//
//  Created by wangjingmac on 16/9/7.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import "AMNTextPresenter.h"
#import "MVPViewController.h"

@implementation AMNTextPresenter

- (instancetype)initWithView:(UIView<AMNTextPresenterProtocol> *)view
{
    if (self = [self init]) {
        self.view = view;
    }

    return self;
}

- (void)presentWithModel:(SecondModel *)model viewController:(UIViewController *)viewController
{
    self.sModel = model;
    self.viewController = viewController;
    [self present];
}

- (void)present
{
    [self.view setText:self.sModel.title];
}

@end
