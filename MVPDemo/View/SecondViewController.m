//
//  SecondViewController.m
//  MVPDemo
//
//  Created by wangjingmac on 16/9/8.
//  Copyright © 2016年 wangjingmac. All rights reserved.
//

#import "SecondViewController.h"
#import "SecondTableViewCell.h"
#import "AMNTimeline.h"
#import "SecondTableView.h"
//#import "DataInterface.h"
#import "SecondCommand.h"

@interface SecondViewController ()
{
    SecondTableView *mainTableView;
}
@property (nonatomic) AMNTimeline *timeline;


@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"API MVP";
    
//    [self requestData];
    
    
//    mainTableView = [[SecondTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
//    mainTableView.showsVerticalScrollIndicator = NO;
//    UIView *view = [[UIView alloc] init];
//    mainTableView.tableFooterView = view;
//    [self.view addSubview:mainTableView];
    
    [self personalCenterResqustDate];
}

#pragma mark 个人中心数据请求
-(void)personalCenterResqustDate{
    SecondCommand *scc = [[SecondCommand alloc]init ];
//    AppToken *apptoken = [AppTokenDao getAppToken];
    scc.page = @"1";
    scc.length = @"10";
    [scc setSuccessBlock:^(SecondCommand *scc){
        if (scc.status == 0 ) {
           
        }
    }];
    [scc execute];
}

- (void)requestData
{
//    DataInterface *data = [[DataInterface alloc]initWithDelegate:self];
//    NSString *appUrl = @"http://apps.secwk.com/V310//bugcrowds/app3index";
//    [data Home_secwkappindex:nil appUrl:appUrl andType:@"appindex"];
}

- (void)dataInterfaceRequestFinishedWithReturnStatus:(NSInteger)status andResult:(NSDictionary *)result andType:(NSString *)type
{
    if(status == 0)
    {
        if([result[@"code"] intValue] == 0)
        {
            mainTableView.dataArray = result[@"data"][@"list"];
            mainTableView.viewController = self;
            
            [mainTableView reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
