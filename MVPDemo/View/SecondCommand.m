//
//  SecondCommand.m
//  MVPDemo
//
//  Created by wangjingmac on 16/9/12.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import "SecondCommand.h"

@implementation SecondCommand

- (id) init {
    self = [super initWithCommandId:ActCommandIdNormarlRequest];
    return self;
}

- (void) buildRequest
{
    [self.params setObject: self.page forKey:@"page"];
    [self.params setObject: self.length forKey:@"length"];
    self.requestURLString = API_PersonalCenter_URL;
}


- (void)requestDidFinish:(NSData *)aData
{
    NSError *error = nil;
    NSDictionary *rt = [NSJSONSerialization JSONObjectWithData:aData options:NSJSONReadingMutableContainers error:&error];
    //NSLog(@"rt: %@",rt);
    if (error == nil && rt) {
        error = [self checkErrorWithCode:rt];
        if (error == nil) {
            //			self.agentvo = [AgentVo mj_objectWithKeyValues: rt];
            //			if(self.agentvo.status ==0){
            //                self.user =self.agentvo.user;
            //				[UserInfoDao updateUserinfo:self.agentvo.user];
            ////                [user update];
            //			}
            [self notifySuccess];
        } else {
            [self notifyFailWithError:error];
        }
    } else {
        [self notifyFailWithError:[self parseError]];
    }
}

- (void) requestDidFailWithError:(NSError *)aError
{
    [self notifyFailWithError:aError];
}

@end
