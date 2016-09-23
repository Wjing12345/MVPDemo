//
//  ActCommand+CheckError.m
//  coolooknews
//
//  Created by zhoujie on 15/11/24.
//  Copyright © 2015年 coolook. All rights reserved.
//

#import "ActCommand.h"

@implementation ActCommand (CheckError)

- (NSError *)checkErrorWithCode:(NSDictionary *)aResult
{
    id codeObj = [aResult objectForKey:@"code"];
    
    if (codeObj) {
        [self.responseHeaders setObject:codeObj forKey:@"code"];
        
        NSInteger code = [codeObj integerValue];
        if (code != 0)
        {
            return [NSError errorWithDomain:@"art" code:code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[aResult objectForKey:@"msg"], @"NSLocalizedDescription", nil]];
        }
    }
    
    id msg = [aResult objectForKey:@"msg"];
    if (msg)
    {
       [self.responseHeaders setObject:msg forKey:@"msg"];
    }

    return nil;
}

- (NSError *)parseError
{
    return [NSError errorWithDomain:@"art" code:1001 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"解析失败", @"NSLocalizedDescription", nil]];
}

@end
