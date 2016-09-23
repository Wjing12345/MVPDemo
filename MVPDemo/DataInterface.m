//
//  DataInterface.m
//  威客众测
//
//  Created by 史进 on 15/7/13.
//  Copyright (c) 2015年 史进. All rights reserved.
//

#import "DataInterface.h"

@implementation DataInterface

-(instancetype)initWithDelegate:(id<DataInterfaceDelegate>)delegate
{
    self = [super init];
    if(self)
    {
        _delegate=delegate;
        
        _manager=[AFHTTPSessionManager manager];
        _manager.securityPolicy.allowInvalidCertificates = YES;
        _manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
        _manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"请使用 initWithDelegate 方法进行初始化");
    
    return nil;
}

// 请求
- (void)Home_secwkappindex:(NSDictionary *)requestDic appUrl:(NSString *)appUrl andType:(NSString *)andType
{
    
    _manager.requestSerializer.timeoutInterval = 10;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:requestDic];
        
    [_manager POST:appUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"JSON: %@", responseObject);
    
        //请求成功时回调方法
        if (_delegate && [_delegate respondsToSelector:@selector(dataInterfaceRequestFinishedWithReturnStatus:andResult:andType:)]) {
            [_delegate dataInterfaceRequestFinishedWithReturnStatus:0 andResult:responseObject andType:andType];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        
        //请求失败时候，回调方法
        if (_delegate && [_delegate respondsToSelector:@selector(dataInterfaceRequestFinishedWithReturnStatus:andResult:andType:)]) {
            [_delegate dataInterfaceRequestFinishedWithReturnStatus:[error code] andResult:nil andType:andType];
        }
    }];
}

@end
