//
//  AMNTimeline.m
//  MVPExample-ObjectiveC
//
//  Created by wangjingmac on 16/9/7.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import "AMNTimeline.h"
#import "AMNText.h"

@implementation AMNTimeline

- (instancetype)init
{
    if (self = [super init]) {
        self.posts = [NSMutableArray new];
        for (int i=0; i<20; i++) {

            [self.posts addObject:[NSClassFromString(@"AMNText") new]];
        }
    }

    return self;
}
@end
