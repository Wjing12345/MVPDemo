//
//  PersonalCenterCommand.m
//  coolooknews
//
//  Created by 车玉 on 16/6/9.
//  Copyright © 2016年 coolook. All rights reserved.
//

#import "PersonalCenterCommand.h"
//#import "MJExtension.h"
//#import "LocalInfoDao.h"
//#import "UserInfoDao.h"

@implementation PersonalCenterCommand
@synthesize uuid, access_token;

- (id) init {
    self = [super initWithCommandId:ActCommandIdNormarlRequest];
    return self;
}

- (void) buildRequest
{
    [self.params setObject:uuid forKey:@"uuid"];
    [self.params setObject:access_token forKey:@"access_token"];
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
