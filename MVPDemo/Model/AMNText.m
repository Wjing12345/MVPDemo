//
//  AMNText.m
//  MVPExample-ObjectiveC
//
//  Created by wangjingmac on 16/9/7.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import "AMNText.h"

@implementation AMNText
- (instancetype)init
{
    if (self = [super init]) {
        
        self.text = @"特点 :(1)各部分之间的通信，都是双向的。(2)View 与 Model 不发生联系，都通过 Presenter 传递。(3) View 非常薄，不部署任何业务逻辑，称为”被动视图”（Passive View），即没有任何主动性，而 Presenter非常厚，所有逻辑都部署在那里。";
        
    }

    return self;
}
@end
