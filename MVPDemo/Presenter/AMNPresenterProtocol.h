//
//  AMNPresenterProtocol.h
//  MVPExample-ObjectiveC
//
//  Created by wangjingmac on 16/9/7.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMNPresenterProtocol
- (void)setView:(NSObject *)view;
- (void)setViewController:(UIViewController *)viewController;
@optional
- (void)present;
- (void)presentWithModel:(id)model viewController:(UIViewController *)viewController;
@end

