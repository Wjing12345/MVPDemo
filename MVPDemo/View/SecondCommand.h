//
//  SecondCommand.h
//  MVPDemo
//
//  Created by wangjingmac on 16/9/12.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import "ActCommand.h"

@interface SecondCommand : ActCommand

@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *length;
@property (nonatomic, assign) int status;

@end
