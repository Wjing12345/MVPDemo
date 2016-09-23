//
//  AMNTimelineTableViewPresenter.m
//  MVPExample-ObjectiveC
//
//  Created by wangjingmac on 16/9/7.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import "AMNTimelineTableViewPresenter.h"
#import "AMNTimeline.h"
#import "AMNTextTableViewCell.h"
#import "SecondViewController.h"

@interface AMNTimelineTableViewPresenter()
@property (nonatomic) AMNTimeline *timeline;
@end

@implementation AMNTimelineTableViewPresenter

- (instancetype)init
{
    if (self = [super init]) {
        self.timeline = [AMNTimeline new];
    }

    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.timeline.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id post = self.timeline.posts[indexPath.row];

    NSString *identifier = [NSString stringWithFormat:@"%@Cell", NSStringFromClass([post class])];

    id cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ([cell respondsToSelector:@selector(presenter)]) {
        NSObject<AMNPresenterProtocol> *presenter = [cell presenter];
        [presenter presentWithModel:post viewController:self.viewController];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SecondViewController *svc = [[SecondViewController alloc] init];
    [self.viewController.navigationController pushViewController:svc animated:YES];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
