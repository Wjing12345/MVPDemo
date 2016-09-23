//
//  ActCommandCache.h
//  coolooknews
//
//  Created by zhoujie on 15/11/24.
//  Copyright © 2015年 coolook. All rights reserved.
//

#import "ActCommand.h"

@interface ActCommandCache : NSObject

@property (nonatomic, assign) NSInteger limitNumberOfMinutes;   //缓存时间，单位：分钟

// 获取本地缓存的数据，判断URL是否需要缓存，返回nil，则需要缓存
- (NSData *)cachedResponseDataWithCommand:(ActCommand *)aCommand;

// 缓存URL及响应的数据
- (void)cacheRequestWithCommand:(ActCommand *)aCommand responseData:(NSData *)aData;

@end
