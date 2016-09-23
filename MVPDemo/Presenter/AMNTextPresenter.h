//
//  AMNTextPresenter.h
//  MVPExample-ObjectiveC
//
//  Created by wangjingmac on 16/9/7.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMNPresenterProtocol.h"
#import "SecondModel.h"

@protocol AMNTextPresenterProtocol

- (void)setText:(NSString *)text;

@end

@interface AMNTextPresenter : NSObject <AMNPresenterProtocol>

@property (nonatomic) NSObject<AMNTextPresenterProtocol> *view;
@property (nonatomic) UIViewController *viewController;
@property (nonatomic) SecondModel *sModel;

- (instancetype)initWithView:(UIView<AMNTextPresenterProtocol> *)view;
- (void)presentWithModel:(SecondModel *)model viewController:(UIViewController *)viewController;
- (void)present;

@end