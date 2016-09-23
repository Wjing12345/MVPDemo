//
//  ActCommandId.h
//  coolooknews
//
//  Created by zhoujie on 15/11/24.
//  Copyright © 2015年 coolook. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ActCommandId) {
    ActCommandIdNormarlRequest = 1000, // 默认并行
    ActCommandIdSerialRequest, // 串行
    ActCommandIdXMPPRequest, // XMPP
    
    ActCommandIdCount,
};