//
//  PersonalCenterCommand.h
//  coolooknews
//
//  Created by 车玉 on 16/6/9.
//  Copyright © 2016年 coolook. All rights reserved.
//

#import "ActCommand.h"
//#import "AgentVo.h"
//#import "UserInfo.h"

@interface PersonalCenterCommand : ActCommand

//input
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *access_token;

//out
//@property (nonatomic, strong) AgentVo *agentvo;

@property (nonatomic, assign) int status;
//@property (nonatomic, strong)UserInfo *user;
@end
