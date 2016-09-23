//
//  DataInterface.h
//  威客众测
//
//  Created by 史进 on 15/7/13.
//  Copyright (c) 2015年 史进. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"



@protocol DataInterfaceDelegate <NSObject>

/**
 * @brief 网络请求回调协议
 * @param ret
 *      返回成功：status = 0；
 *      超时：status = -1001
 *      无法连接服务器：status = -1004
 *      其它status值参照portal文档中的描述
 * @param result   返回数据
 * @param type     请求类型
 **/
- (void)dataInterfaceRequestFinishedWithReturnStatus:(NSInteger)status andResult:(NSDictionary *)result andType:(NSString *)type;

@end



@interface DataInterface : NSObject
{
    id<DataInterfaceDelegate>_delegate;
}
@property (nonatomic,strong) AFHTTPSessionManager *manager;


- (id)initWithDelegate:(id<DataInterfaceDelegate>)delegate;


//实验实验
- (void)Home_secwkappindex:(NSDictionary *)requestDic appUrl:(NSString *)appUrl andType:(NSString *)andType;

@end
