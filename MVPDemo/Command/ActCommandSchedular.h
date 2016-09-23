//
//  ActCommandSchedular.h
//  coolooknews
//
//  Created by zhoujie on 15/11/24.
//  Copyright © 2015年 coolook. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ActCommand;

@protocol ActCommandSchedular <NSObject>

@required
- (void)start;
- (void)stop;
- (void)addCommand:(ActCommand *)aCommand;
- (void)removeCommandWithSeq:(NSInteger)aSeq;

@end

@interface ActCommandSchedularCenter: NSObject

+ (id<ActCommandSchedular>)schedularWithCommandId:(NSInteger)aCommandId;
+ (id<ActCommandSchedular>)schedularWithKey:(NSString *)aKey;

@end

