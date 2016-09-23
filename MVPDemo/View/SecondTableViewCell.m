//
//  SecondTableViewCell.m
//  MVPDemo
//
//  Created by wangjingmac on 16/9/8.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import "SecondTableViewCell.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface SecondTableViewCell()

@property (nonatomic,strong) UILabel *label;

@end

@implementation SecondTableViewCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.label = [[UILabel alloc] init];
        self.label.numberOfLines = 0;
        self.label.font = [UIFont systemFontOfSize: 13];
        self.label.frame = CGRectMake(20, 0, SCREEN_WIDTH-40, 100);
        [self.contentView addSubview:self.label];
        
        self.presenter = [[AMNTextPresenter alloc] initWithView:self];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    self.label.text = text;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
