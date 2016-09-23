//
//  BaseModel.h
//  猎律客户版
//
//  Created by 北京猎律科技有限公司 on 15/5/4.
//  Copyright (c) 2015年 北京猎律科技有限公司. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface BaseModel : NSObject

- (id)initWithContentsOfDic:(NSDictionary *)dic;

- (NSDictionary *)keyToAtt:(NSDictionary *)dic;
@end
