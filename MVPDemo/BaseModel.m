//
//  BaseModel.m
//  猎律客户版
//
//  Created by 北京猎律科技有限公司 on 15/5/4.
//  Copyright (c) 2015年 北京猎律科技有限公司. All rights reserved.
//
#import "BaseModel.h"

@implementation BaseModel

- (id)initWithContentsOfDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self dicToObject:dic];
    }
    return self;
}



- (NSDictionary *)keyToAtt:(NSDictionary *)dic
{
    if([dic isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
        for (NSString *key in dic) {
            
            [attDic setObject:key forKey:key];
        }
        return attDic;
    }
    else
    {
        return nil;
    }
    return nil;
}



- (SEL)setingToSel:(NSString *)model_key
{

    NSString *first = [[model_key substringToIndex:1] uppercaseString];
    NSString *end = [model_key substringFromIndex:1];
    NSString *setSel = [NSString stringWithFormat:@"set%@%@:",first,end];
    return NSSelectorFromString(setSel);
}

- (void)dicToObject:(NSDictionary *)dic
{
    if([dic isKindOfClass:[NSDictionary class]])
    {
        for (NSString *key in dic) {
            NSString *model_key = [[self keyToAtt:dic] objectForKey:key];
            if (model_key) {
                SEL action = [self setingToSel:model_key];
                if ([self respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [self performSelector:action withObject:[dic objectForKey:key]];
#pragma clang diagnostic pop
                }
            }
        }
    }
    else
    {
        return;
    }
    
}

@end
