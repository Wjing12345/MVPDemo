//
//  ActCommand.h
//  coolooknews
//
//  Created by zhoujie on 15/11/24.
//  Copyright © 2015年 coolook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActCommandId.h"

typedef NS_ENUM(NSInteger, ActCommandPriority) {
	ActCommandPriorityVeryLow = -8L,
	ActCommandPriorityLow = -4L,
	ActCommandPriorityNormal = 0,
	ActCommandPriorityHigh = 4,
	ActCommandPriorityVeryHigh = 8
};

typedef NS_ENUM(NSInteger, ActCommandRequestType) {
	ActCommandRequestTypeGET,
	ActCommandRequestTypePOST,
};

@protocol GKRequestObserver <NSObject>

@required
- (void)requestDidFinish:(NSData *)aData;
- (void)requestDidFailWithError:(NSError *)aError;
@optional
- (void)requestDidReceiveData:(NSData *)aData;

@end

@class ActCommand;

typedef void (^ActCommandSuccessBlock)(id /* ActCommand* */);
typedef void (^ActCommandFailBlock)(id /* ActCommand* */, NSError*);

@interface ActCommand : NSObject <GKRequestObserver>

@property (nonatomic, assign) ActCommandRequestType requestType;
@property (nonatomic, assign) BOOL gzip;

@property (nonatomic, assign) NSInteger commandId;
@property (nonatomic, assign) NSInteger seqId;

@property (nonatomic, copy) NSString* requestURLString;
@property (nonatomic, retain) NSMutableDictionary* requestHeaders;

@property (nonatomic, copy) NSData* postData;
@property (nonatomic, copy) NSData* responseData;

@property (nonatomic, retain) NSMutableDictionary* responseHeaders;

@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, assign) NSInteger checkCache; //是否检查缓存，默认是YES(检查的)

@property (nonatomic, copy) ActCommandSuccessBlock successBlock;
@property (nonatomic, copy) ActCommandFailBlock failBlock;

@property (nonatomic, retain) NSMutableDictionary* params;

- (id)initWithCommandId:(NSInteger)aCommandId;

- (BOOL)checkHeaderError:(NSDictionary *)aHeader;

- (NSString *)stringForEncodeURL:(NSDictionary *)dic;

// 构建Post请求, 需要子类实现, 在被Schedular Send的时候会被调用
- (void)buildRequest;

- (void)cancel;
- (void)execute;
- (void)executeWithSchedular:(id /*<ActCommandSchedular>*/)aSchedular;
- (void)executeWithSuccess:(ActCommandSuccessBlock)aSuccessBlock
                   failure:(ActCommandFailBlock)aFailBlock;

- (void)setNotifyQueue:(dispatch_queue_t)aQueue;
- (void)notifySuccess;
- (void)notifyFailWithError:(NSError *)aError;

@end

@interface ActCommand (CheckError)

- (NSError *)checkErrorWithCode:(NSDictionary *)aResult;

- (NSError *)parseError;

@end

@interface ActCommand (RequestHeader)

- (void)buildRequestHeader;

@end