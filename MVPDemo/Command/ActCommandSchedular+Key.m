//
//  ActCommandSchedular+Key.m
//  coolooknews
//
//  Created by zhoujie on 15/11/24.
//  Copyright © 2015年 coolook. All rights reserved.
//

#import "ActCommandSchedular+Key.h"
#import "ActCommandId.h"

@implementation ActCommandSchedularCenter (Key)

- (NSString *)keyForCommandId:(NSInteger)aCommandId
{
    if (aCommandId == ActCommandIdNormarlRequest)
        return @"NormalSchedularIdentifier";
    if (aCommandId == ActCommandIdSerialRequest)
        return @"SerialSchedularIdentifier";
    if (aCommandId == ActCommandIdXMPPRequest)
        return @"XMPPSchedularIdentifier";
    return @"NormalSchedularIdentifier";
}

@end
