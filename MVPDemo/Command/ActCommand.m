//
//  ActCommand.m
//  coolooknews
//
//  Created by zhoujie on 15/11/24.
//  Copyright © 2015年 coolook. All rights reserved.
//

#import "ActCommand.h"

#import "ActCommandSchedular.h"
#import <objc/runtime.h>

static NSInteger CreateSeqId()
{
    static NSInteger seqId = 1;
    if (seqId < 0)
        seqId = 0;
    return ++seqId;
}

@interface ActCommand ()
{
    dispatch_queue_t _notifyQueue;
    NSInteger _commandId;
    int requestnum;
}

@end

@implementation ActCommand

- (id)initWithCommandId:(NSInteger)aCommandId
{
    self = [super init];
    requestnum = 0;
    if (self)
    {
        _commandId = aCommandId;
        
        self.seqId = CreateSeqId();
        self.params = [NSMutableDictionary dictionary];
        self.requestHeaders = [NSMutableDictionary dictionary];
        self.responseHeaders = [NSMutableDictionary dictionary];
        self.requestType = ActCommandRequestTypeGET;        // 默认使用 GET 请求
        self.gzip = YES;
        
        self.checkCache = NO;
        
        _notifyQueue = NULL;
    }
    
    return self;
}

- (void)dealloc
{
    self.requestURLString = nil;
    
    self.requestHeaders = nil;
    
    self.postData = nil;
    self.responseData = nil;
    
    self.responseHeaders = nil;
    
    self.successBlock = nil;
    self.failBlock = nil;
    
    self.params = nil;
}

#pragma mark

- (BOOL)checkHeaderError:(NSDictionary *)aHeader
{
    return YES;
}

- (NSString *)stringForEncodeURL:(NSDictionary *)dic
{
    NSMutableString* encodeURL = [NSMutableString stringWithString:@""];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop) {
        NSString* value = nil;
        if ([val isKindOfClass:[NSString class]])
        {
            value = val;
        }
        if ([val isKindOfClass:[NSDictionary class]] || [val isKindOfClass:[NSArray class]])
        {
            NSData* data = [NSJSONSerialization dataWithJSONObject:val options:NSJSONWritingPrettyPrinted error:nil];
            if (data)
            {
                value = [NSString stringWithUTF8String:[data bytes]];
            }
        }
        else
        {
            value = [NSString stringWithFormat:@"%@", val];
        }
        if (value)
        {
            NSString *encodedValue = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)value, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
            [encodeURL appendFormat:@"%@=%@&", key, encodedValue];
            CFRelease((__bridge CFStringRef)encodedValue);
        }
    }];
    
    return encodeURL;
}

- (NSInteger)commandId
{
    return _commandId;
}

- (void)requestDidFinish:(NSData *)aData;
{
    // do nothing
}

- (void)requestDidFailWithError:(NSError *)aError
{
    [self notifyFailWithError:aError];
}

- (void)requestDidReceiveData:(NSData *)aData
{
    // do nothing
}

- (void)buildRequest
{}

- (void)cancel
{
    self.failBlock = nil;
    self.successBlock = nil;
    
    [[ActCommandSchedularCenter schedularWithCommandId:self.commandId] removeCommandWithSeq:self.seqId];
}

- (void)execute
{
    [[ActCommandSchedularCenter schedularWithCommandId:self.commandId] addCommand:self];
}

- (void)executeWithSchedular:(id /*<ActCommandSchedular>*/)aSchedular
{
    id<ActCommandSchedular> schedular = (id<ActCommandSchedular>)aSchedular;
    [schedular addCommand:self];
}

- (void)executeWithSuccess:(ActCommandSuccessBlock)aSuccessBlock
                   failure:(ActCommandFailBlock)aFailBlock
{
    self.successBlock = aSuccessBlock;
    self.failBlock = aFailBlock;
    
    [self execute];
}

- (void)setNotifyQueue:(dispatch_queue_t)aQueue
{
    _notifyQueue = aQueue;
}

- (void)notifySuccess
{
    if (!self.successBlock)
        return;
    if (_notifyQueue)
    {
        dispatch_async(_notifyQueue, ^{
            if (self.successBlock)
            {
                self.successBlock(self);
            }
            else
            {
                //NSLog(@"Null Pointer");
            }
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.successBlock)
            {
                self.successBlock(self);
            }
            else
            {
                //NSLog(@"Null Pointer");
            }
        });
    }
}

- (void)notifyFailWithError:(NSError *)aError
{
    NSLog(@"aError: %ld",aError.code);
    if(aError.code == -1 && requestnum<2){
        [self execute];
        [NSThread sleepForTimeInterval:2];
        requestnum++;
    }

    if (!self.failBlock)
        
        return;
    if (_notifyQueue)
    {
        dispatch_async(_notifyQueue, ^{
            if (self.failBlock)
            {
                self.failBlock(self, aError);
            }
            else
            {
               // NSLog(@"Null Pointer");
            }
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.failBlock)
            {
                self.failBlock(self, aError);
            }
            else
            {
               // NSLog(@"Null Pointer");
            }
        });
    }
    
   
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n%s Request Id: %ld\nRequest url: %@\nRequest parameters: %@\n",
            class_getName([self class]),
            (long)self.commandId, self.requestURLString, self.params];
}


@end