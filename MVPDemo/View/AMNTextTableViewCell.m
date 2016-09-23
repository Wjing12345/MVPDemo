//
//  AMNTextTableViewCell.m
//  MVPExample-ObjectiveC
//
//  Created by wangjingmac on 16/9/7.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import "AMNTextTableViewCell.h"

@interface AMNTextTableViewCell()

@property (nonatomic) IBOutlet UILabel *label;

@end

@implementation AMNTextTableViewCell

- (void)awakeFromNib
{
    self.presenter = [[AMNTextPresenter alloc] initWithView:self];
}

- (void)setText:(NSString *)text
{
    self.label.text = text;
}

@end