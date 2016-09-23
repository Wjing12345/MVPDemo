//
//  PersonalCenterViewController.m
//  coolooknews
//
//  Created by 车玉 on 16/6/6.
//  Copyright © 2016年 coolook. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import "LocalInfoDao.h"
#import "SignOutCommand.h"
#import "PersonalCenterCommand.h"
#import "UpdatePersonalCommand.h"
#import "RCDraggableButton.h"
#import "SidebarViewController.h"
#import "FadeOutView.h"
#import "UpheadCommand.h"
#import "ReqactiveCommand.h"
#import "UIImageView+WebCache.h"
#import "Base64.h"
#import "ArtUtil.h"
#import "UserInfoDao.h"
#import "MBProgressHUD.h"
#import "POPView.h"
#import "ExecuteCommand.h"
#import "YSHYClipViewController.h"

@interface PersonalCenterViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,ClipViewControllerDelegate>{
    UIView* vwDialog;
    
}
//枚举性别
typedef NS_ENUM(NSInteger, Sex) {
    unkounw = 0,
    man,
    Woman
};
@property(nonatomic,assign)NSInteger Sex;
@property (weak, nonatomic) IBOutlet UIButton *manIcon;
@property (weak, nonatomic) IBOutlet UIButton *womanIcon;
@property (weak, nonatomic) IBOutlet UILabel *anewName;
@property(nonatomic,strong)UITextView *textview;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImageHeight;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
//@property(nonatomic,strong) UIImageView *headImage;

//@property (weak, nonatomic) IBOutlet UIImageView *headImageone;
@property(nonatomic,strong) UIImage *upheadImage;
@property (weak, nonatomic) IBOutlet UIButton *activeEmailIcon;
@property (weak, nonatomic) IBOutlet UILabel *NIckName;
@property (weak, nonatomic) IBOutlet UILabel *Gender;
@property (weak, nonatomic) IBOutlet UILabel *Account;
@property (weak, nonatomic) IBOutlet UILabel *ChangePassword;
@property (weak, nonatomic) IBOutlet UIButton *Exit;



@end

@implementation PersonalCenterViewController



- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.NIckName.text =NSLocalizedStringFromTable(@"NIckName", @"coolook", @"");
	self.Gender.text =NSLocalizedStringFromTable(@"Gender", @"coolook", @"");
	self.Account.text = NSLocalizedStringFromTable(@"Account", @"coolook", @"");
	self.ChangePassword.text = NSLocalizedStringFromTable(@"ChangePassword", @"coolook", @"");
	[self.Exit setTitle:NSLocalizedStringFromTable(@"Exit current account", @"coolook", @"") forState:UIControlStateNormal];
    
	[self.headImage.layer setMasksToBounds:YES];
	[self.headImage.layer setBorderWidth:1];
	[self.headImage.layer setBorderColor:[UIColor whiteColor].CGColor];
	self.headImage.layer.shadowOpacity = 0.8;
	self.headImage.layer.shadowColor =[UIColor blackColor].CGColor;
	UITapGestureRecognizer *headTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(XIV:)];
	[self.headImage addGestureRecognizer:headTap];
	self.headImage.userInteractionEnabled = YES;
	//个人中心数据加载
	[self personalCenterResqustDate];
	//读取图片
	NSString *fullPach = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"avatar.png"];
	UIImage *savedImage = [[UIImage alloc]initWithContentsOfFile:fullPach];
	
    self.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    CGRect rx = [UIScreen mainScreen].bounds;
    
    NSLog(@"rx.size.height == %f",rx.size.height);
    if(rx.size.height == 480){
        self.headImageWidth.constant =58 ;
        self.headImageHeight.constant = 58;
        self.headImage.layer.cornerRadius = 58/ 2.0f;
        self.headImage.layer.masksToBounds = 58/ 2.0f;
        self.headImage.clipsToBounds = YES;
				}else{
                    self.headImage.layer.cornerRadius = self.headImage.frame.size.width / 2.0f;
                    self.headImage.layer.masksToBounds = self.headImage.frame.size.width / 2.0f;
                    self.headImage.clipsToBounds = YES;
                }
    [self.headImage setImage:savedImage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark 移除键盘监听通知
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma 退出登录提示
- (IBAction)exitAccount:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Confirm exit", @"coolook", @"") message:NSLocalizedStringFromTable(@"Confirm exit login current accout", @"coolook", @"") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"coolook", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //[self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    UIAlertAction *signOutAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Sign out", @"coolook", @"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self signOutRequestDate];
    }];
    [alert addAction:cancleAction];
     [alert addAction:signOutAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma 更换头像
- (void)XIV:(UIButton *)sender{
   
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"coolook", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //[self dismissViewControllerAnimated:YES completion:nil];
            
        }];
        UIAlertAction *SelectAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Photograph", @"coolook", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                UIImagePickerController * picker=[[UIImagePickerController alloc]init];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.allowsEditing = NO;
                picker .delegate = self;
                [self presentViewController:picker animated:YES completion:nil];
            } else {
                showFadeOutView(NSLocalizedStringFromTable(@"The camera is not available", @"coolook", @""), NO, 1);
            }
            
                    }];
    
    UIAlertAction *PhotoAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Select from album", @"coolook", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }];
        [alert addAction:SelectAction];
        [alert addAction:PhotoAction];
        [alert addAction:cancleAction];
        [self presentViewController:alert animated:YES completion:nil];
 //自定义的弹出头像选择
 /*
    UIView *backview = [[UIView alloc]init];
    backview.tag= 2200;
    backview.backgroundColor=[UIColor blackColor];
    backview.alpha = 0.4f;
    backview.tag = 2300;
    backview.frame=self.view.frame;
    UITapGestureRecognizer  *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelclick)];
    [backview addGestureRecognizer:tap];
    [[UIApplication sharedApplication].keyWindow addSubview:backview];
    //添加手势
    //UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPage)];
    //[vwFullScreenView addGestureRecognizer:tapGesturRecognizer];
    
    UIView *centerview = [[UIView alloc] init];
    centerview.frame=CGRectMake(20, 0, backview.frame.size.width - 40, 150);
    centerview.tag = 2301;
    centerview.backgroundColor = [UIColor whiteColor];
    centerview.center = self.view.center;
    [[UIApplication sharedApplication].keyWindow addSubview:centerview];
    //分割线
    UILabel *oneline = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, centerview.frame.size.width, 1)];
    oneline.backgroundColor = kUIColorFromRGB(0XBEBEBE);
    [centerview addSubview:oneline];
    UILabel *twoline = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, centerview.frame.size.width, 1)];
    twoline.backgroundColor = kUIColorFromRGB(0XBEBEBE);
    [centerview addSubview:twoline];
    //点击事件
    UILabel *album = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, centerview.frame.size.width, 49)];
    album.backgroundColor = [UIColor whiteColor];
    //album.textAlignment = NSTextAlignmentCenter;
    album.text =NSLocalizedStringFromTable(@"  Select from album", @"coolook", @"");
    album.textColor = kUIColorFromRGB(0X212121);
    album.userInteractionEnabled = YES;
    [centerview addSubview:album];
    UITapGestureRecognizer *albumGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(albumclick)];
    [album addGestureRecognizer:albumGesturRecognizer];

    
    UILabel *photograph = [[UILabel alloc]initWithFrame:CGRectMake(0, 51, centerview.frame.size.width, 49)];
    photograph.backgroundColor = [UIColor whiteColor];
    //photograph.textAlignment = NSTextAlignmentCenter;
    photograph.text = NSLocalizedStringFromTable(@"  Photograph", @"coolook", @""); //字体前两次空格
    photograph.textColor = kUIColorFromRGB(0X212121);
    photograph.userInteractionEnabled = YES;
    [centerview addSubview:photograph];
    UITapGestureRecognizer *photographGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoclick)];
    [photograph addGestureRecognizer:photographGesturRecognizer];
    
    UILabel *Cancel = [[UILabel alloc]initWithFrame:CGRectMake(0, 101, centerview.frame.size.width, 50)];
    Cancel.backgroundColor = [UIColor whiteColor];
    //Cancel.textAlignment = NSTextAlignmentCenter;
    Cancel.text = NSLocalizedStringFromTable(@"  Cancel", @"coolook", @"");
    Cancel.textColor = kUIColorFromRGB(0X212121);
    Cancel.userInteractionEnabled = YES;
    [centerview addSubview:Cancel];
    UITapGestureRecognizer *cancelGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelclick)];
    [Cancel addGestureRecognizer:cancelGesturRecognizer];
    */
}
//自定义的弹出头像选择的执行方法
   /*
-(void)albumclick{
    [[self.view.window viewWithTag:2300]removeFromSuperview];
    [[self.view.window viewWithTag:2301]removeFromSuperview];
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController * picker=[[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = NO;
        picker .delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        showFadeOutView(NSLocalizedStringFromTable(@"The camera is not available", @"coolook", @""), NO, 1);
    }
}
-(void)photoclick{
    [[self.view.window viewWithTag:2300]removeFromSuperview];
    [[self.view.window viewWithTag:2301]removeFromSuperview];
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}
-(void)cancelclick{
    [[self.view.window viewWithTag:2300]removeFromSuperview];
    [[self.view.window viewWithTag:2301]removeFromSuperview];
}
*/

#pragma mark 图片选取完成后调用该方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
//    [picker dismissViewControllerAnimated:YES completion:^{
//        
//    }];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    YSHYClipViewController * clipView = [[YSHYClipViewController alloc]initWithImage:image];
    clipView.delegate = self;
    clipView.clipType = SQUARECLIP; //支持圆形:CIRCULARCLIP 方形裁剪:SQUARECLIP   默认:圆形裁剪
    
    // 改变状态栏的颜色  为正常  这是这个独有的地方需要处理的
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [picker pushViewController:clipView animated:YES];

    }

#pragma mark - ClipViewControllerDelegate
-(void)ClipViewController:(YSHYClipViewController *)clipViewController FinishClipImage:(UIImage *)editImage
{
     [clipViewController dismissViewControllerAnimated:YES completion:^{
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
         [[UIApplication sharedApplication] setStatusBarHidden:NO];
         
         
            self.upheadImage = editImage;
            //保存图片到本地,上传到服务器
         UserInfo *user = [UserInfoDao getUserinfo];
         
            [self saveImage:editImage withName:user.email];
            //
            [self upLoadHeadResqustDate];
        
            NSString *fullPach = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:user.email];
            UIImage *savedImage = [[UIImage alloc]initWithContentsOfFile:fullPach];
            //设置图片
            self.headImage.layer.cornerRadius = self.headImage.frame.size.width / 2.0f;
            self.headImage.layer.masksToBounds = self.headImage.frame.size.width / 2.0f;
            self.headImage.clipsToBounds = YES;
            [self.headImage setImage:savedImage];
        
        
    }];
    
    
}



#pragma 按取消按钮执行该方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma 保存图片到本地
-(void)saveImage:(UIImage *)currenImage withName:(NSString *)imageName{
    
    NSData *imageData = UIImageJPEGRepresentation(currenImage, 1);
    //获取沙盒路径
    NSString *fullpath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    //写入图片
    [imageData writeToFile:fullpath atomically:NO];
    
}

#pragma mark 男女性别切换
- (IBAction)manIcon:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Modify gender", @"coolook", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"coolook", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //[self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    UIAlertAction *signOutAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Sure", @"coolook", @"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        _Sex = 1;
        [self.womanIcon setBackgroundImage:[UIImage imageNamed:@"womanuncheck"] forState:UIControlStateNormal];
        [self.manIcon setBackgroundImage:[UIImage imageNamed:@"mancheck"] forState:UIControlStateNormal];
        [self upDateResqustDate];
    }];
    [alert addAction:cancleAction];
    [alert addAction:signOutAction];
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)womanIcon:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Modify gender", @"coolook", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"coolook", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //[self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    UIAlertAction *signOutAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Sure", @"coolook", @"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        _Sex = 2;
        [self.womanIcon setBackgroundImage:[UIImage imageNamed:@"womancheck"] forState:UIControlStateNormal];
        [self.manIcon setBackgroundImage:[UIImage imageNamed:@"manuncheck"] forState:UIControlStateNormal];
        [self upDateResqustDate];
    }];
    [alert addAction:cancleAction];
    [alert addAction:signOutAction];
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma mark 修改昵称
- (IBAction)nickName:(id)sender {
    
    vwDialog = [[UIView alloc] init];
    vwDialog.frame=CGRectMake(0, self.view.frame.size.height - 450, self.view.frame.size.width, 186);
    vwDialog.backgroundColor = kUIColorFromRGB(0XEEEEEE);
//    vwDialog.layer.borderColor=[UIColor blueColor].CGColor;
//    vwDialog.layer.borderWidth=0.6;
//    vwDialog.layer.cornerRadius=6;
    vwDialog.center = self.view.center;
    vwDialog.tag = 2001;
    [self.view addSubview:vwDialog];
    //top灰色的底色
    UIView* vwFullScreenView = [[UIView alloc]init];
    vwFullScreenView.tag= 2000;
    vwFullScreenView.backgroundColor=[UIColor blackColor];
    vwFullScreenView.alpha = 0.5f;
    vwFullScreenView.frame=CGRectMake(0, 0, self.view.frame.size.width, CGRectGetMinY(vwDialog.frame));
    UITapGestureRecognizer  *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAllSubviews)];
    [vwFullScreenView addGestureRecognizer:tap];
    [self.view addSubview:vwFullScreenView];
    //bottom灰色的底色
    UIView* bottomView = [[UIView alloc]init];
    bottomView.tag= 2002;
    bottomView.backgroundColor=[UIColor blackColor];
    bottomView.alpha = 0.5f;
    bottomView.frame=CGRectMake(0, CGRectGetMaxY(vwDialog.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(vwDialog.frame));
    [self.view addSubview:bottomView];

    
    
    UILabel *titlenickname = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
    titlenickname.text = NSLocalizedStringFromTable(@"Please enter a nickname", @"coolook", @"");
    titlenickname.font = [UIFont systemFontOfSize:18.f];
    titlenickname.textColor = kUIColorFromRGB(0X212121);
    titlenickname.textAlignment = NSTextAlignmentCenter;
    [vwDialog addSubview:titlenickname];
    
    self.textview = [[UITextView alloc]initWithFrame:CGRectMake(10, 46, vwDialog.frame.size.width - 20, 90)];
    self.textview.font = [UIFont systemFontOfSize:16.f];
    self.textview.textColor = kUIColorFromRGB(0x212121);
    [self.textview becomeFirstResponder];
    self.textview.delegate = self;
    [vwDialog addSubview:self.textview];
    UILabel *character = [[UILabel alloc]initWithFrame:CGRectMake(self.textview.frame.size.width - 90 -5, self.textview.frame.size.height - 20, 90, 20)];
    character.text = @"2-20 character";
    character.textAlignment = NSTextAlignmentRight;
    character.font = [UIFont systemFontOfSize:12.f];
    character.textColor = kUIColorFromRGB(0XBDBDBD);
    [self.textview addSubview:character];
    
    
    UIButton* sureClick = [UIButton buttonWithType:UIButtonTypeSystem];
    sureClick.layer.cornerRadius = 5.f;
    sureClick.backgroundColor = [UIColor blueColor];
    [sureClick setTitle:NSLocalizedStringFromTable(@"Sure", @"coolook", @"") forState:UIControlStateNormal];
    sureClick.titleLabel.font = [UIFont systemFontOfSize:18];
    [sureClick setTitleColor:kUIColorFromRGB(0XFFFFFF) forState:UIControlStateNormal];
    sureClick.frame=CGRectMake(vwDialog.frame.size.width - 70, vwDialog.frame.size.height - 40 , 60, 30);
    [sureClick addTarget:self action:@selector(doClickCloseDialog:) forControlEvents:UIControlEventTouchUpInside];
    [vwDialog addSubview:sureClick];
    
    UIButton *cancle = [UIButton buttonWithType:UIButtonTypeSystem];
    cancle.frame = CGRectMake(vwDialog.frame.size.width - 144, vwDialog.frame.size.height - 40 , 60, 30);
    cancle.backgroundColor = kUIColorFromRGB(0XEEEEEE);
    ;
    cancle.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancle setTitleColor:kUIColorFromRGB(0X777777) forState:UIControlStateNormal];
    [cancle setTitle:NSLocalizedStringFromTable(@"Cancel", @"coolook", @"") forState:UIControlStateNormal];
    [vwDialog addSubview:cancle];
    [cancle addTarget:self action:@selector(cancle:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) doClickCloseDialog : (UIButton*) sender {
    if (self.textview.text.length > 1 && self.textview.text.length < 20) {
        self.anewName.text = self.textview.text;
        [self upDateResqustDate];
        [[[UIApplication sharedApplication].keyWindow viewWithTag:2000]removeFromSuperview];
        [[[UIApplication sharedApplication].keyWindow viewWithTag:2001]removeFromSuperview];
        [[[UIApplication sharedApplication].keyWindow viewWithTag:2002]removeFromSuperview];
    }
    

}
#pragma return消失键盘
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
#pragma 视图消失
- (void)dismissAllSubviews{
    [[self.view.window viewWithTag:2000]removeFromSuperview];
    [[self.view.window viewWithTag:2001]removeFromSuperview];
    [[self.view.window viewWithTag:2002]removeFromSuperview];
}
#pragma 视图消失
-(void)cancle:(UIButton *)sender{
    [[self.view.window viewWithTag:2000]removeFromSuperview];
    [[self.view.window viewWithTag:2001]removeFromSuperview];
    [[self.view.window viewWithTag:2002]removeFromSuperview];
}

#pragma 激活邮箱
- (IBAction)emailActive:(id)sender {
    [self emailActiveRequestDate];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 上传头像请求
-(void)upLoadHeadResqustDate{
	UpheadCommand *uhc = [[UpheadCommand alloc]init];
	AppToken *apptoken = [AppTokenDao getAppToken];
	
	UserInfo *userinfo = [UserInfoDao getUserinfo];
    uhc.uuid = userinfo.uuid;
    uhc.accessToken = apptoken.access_token;
    uhc.headimg = UIImageJPEGRepresentation(self.upheadImage, 0.01);
    [uhc setSuccessBlock:^(PersonalCenterCommand *pcc){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateheadview" object:@""];
    }];
    [uhc execute];
}

#pragma mark 个人中心数据请求
-(void)personalCenterResqustDate{
	PersonalCenterCommand *pcc = [[PersonalCenterCommand alloc]init ];
	AppToken *apptoken = [AppTokenDao getAppToken];
    pcc.access_token = apptoken.access_token;
    pcc.uuid = apptoken.uuid;
    [pcc setSuccessBlock:^(PersonalCenterCommand *pcc){
       if (pcc.status == 0 ) {
			UserInfo *userinfo = [UserInfoDao getUserinfo];
		   
		   
            self.anewName.text = userinfo.nicename;
            self.emailLabel.text = userinfo.email;
           userinfo.sex = 1;
           UserInfo *user = [UserInfoDao getUserinfo];
           NSString *fullPach = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:user.email];
           UIImage *savedImage = [[UIImage alloc]initWithContentsOfFile:fullPach];
            if (userinfo.headurl.length != 0) {
                [self.headImage sd_setImageWithURL:[NSURL URLWithString:userinfo.headurl] placeholderImage:savedImage];
            }else{
                [self.headImage setImage:[UIImage imageNamed:@"default-tx-click"]];
            }
            
            if (userinfo.status == -1) {
                [_activeEmailIcon setImage:[UIImage imageNamed:@"unbinding"] forState:UIControlStateNormal];
                _activeEmailIcon.userInteractionEnabled = YES;
            }else{
                [_activeEmailIcon setImage:[UIImage imageNamed:@"binding"] forState:UIControlStateNormal];
                _activeEmailIcon.userInteractionEnabled = NO;
            }
            
            if (userinfo.sex == 1) {
                [self.manIcon setBackgroundImage:[UIImage imageNamed:@"mancheck"] forState:UIControlStateNormal];
                [self.womanIcon setBackgroundImage:[UIImage imageNamed:@"womanuncheck"] forState:UIControlStateNormal];
            }else if (userinfo.sex == 2){
                [self.womanIcon setBackgroundImage:[UIImage imageNamed:@"womancheck"] forState:UIControlStateNormal];
                [self.manIcon setBackgroundImage:[UIImage imageNamed:@"manuncheck"] forState:UIControlStateNormal];
			}
		}
	}];
	[pcc execute];
}

-(UIImage *)Base64StrToUIImage:(NSString *)_encodedImageStr

{
    
    NSData *_decodedImageData   = [Base64 decode: _encodedImageStr];
    UIImage *_decodedImage      = [UIImage imageWithData:_decodedImageData];
    return _decodedImage;
}

#pragma mark 修改个人中心数据请求
-(void)upDateResqustDate{
	UpdatePersonalCommand *udpc = [[UpdatePersonalCommand alloc] init];
	AppToken *apptoken = [AppTokenDao getAppToken];
    udpc.access_token = apptoken.access_token;
    udpc.uuid = apptoken.uuid;
    udpc.nickname = self.anewName.text;
    udpc.sex = [NSString stringWithFormat:@"%ld",(long)self.Sex];
   UserInfo *userinfo = [UserInfoDao getUserinfo];
    userinfo.nicename = self.anewName.text;
    [userinfo update];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateheadview" object:@""];
    [udpc execute];
}


#pragma mark 退出登录数据请求
-(void)signOutRequestDate{
	
	AppToken *apptoken = [AppTokenDao getAppToken];
	
	SignOutCommand *soc = [SignOutCommand new];
	soc.access_token = apptoken.access_token;
	soc.uuid = apptoken.uuid;
    [soc execute];
    
    UIStoryboard *mainst = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self.navigationController pushViewController:[mainst instantiateViewControllerWithIdentifier:@"Main"] animated:YES];
	
	apptoken.uuid = [ArtUtil updateNewUUID];
	apptoken.islogin = false;
	[AppTokenDao UpdateAppToken:apptoken];
	
    [self.headImage setImage:[UIImage imageNamed:@"headtwo"]];
    
}


#pragma mark 邮箱激活数据请求
-(void)emailActiveRequestDate{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = NSLocalizedStringFromTable(@"Emailvalidate",@"coolook", @"");
	
	ReqactiveCommand *rac = [[ReqactiveCommand alloc]init];
	AppToken *apptoken = [AppTokenDao getAppToken];
	
	UserInfo *userinfo = [UserInfoDao getUserinfo];
    rac.email = userinfo.email;
    rac.accessToken = apptoken.access_token;
    [rac execute];
    
    [rac setSuccessBlock:^(ReqactiveCommand *rac){
		if(rac.status == 0){
			[hud hide:YES afterDelay:3];
			//[POPView popView:NSLocalizedStringFromTable(@"Email has been sent to your email address please login confirmation", @"coolook",@"") showInview:self.view];
		}
	}];
}

-(void)tapPage{
    [[self.view.window viewWithTag:2200]removeFromSuperview];
    [[self.view.window viewWithTag:2201]removeFromSuperview];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    RCDraggableButton *avatar = [[UIApplication sharedApplication].keyWindow viewWithTag:1000];
    [avatar removeFromSuperview];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil]];
    [self.navigationItem.leftBarButtonItem setTarget:self];
    [self.navigationItem.leftBarButtonItem setAction:@selector(backToMian)];
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"whitebackgroup"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
   self.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    
}


#pragma 返回主界面
- (void)backToMian{
//    UIViewController *mainVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Main"];
//    [self.navigationController pushViewController:mainVC animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

///键盘显示事件
- (void) keyboardWillShow:(NSNotification *)notification {
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD)
    CGFloat offset = (vwDialog.frame.origin.y+vwDialog.frame.size.height) - (self.view.frame.size.height - kbHeight);
    
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //将视图上移计算好的偏移
    if(offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateheadview" object:nil];
}

///键盘消失事件
- (void) keyboardWillHide:(NSNotification *)notify {
    // 键盘动画时间
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //视图下沉恢复原状
    CGRect rect = [UIApplication sharedApplication].keyWindow.frame;
    [UIView animateWithDuration:duration animations:^{
        self.view.frame =CGRectMake(0, 0, rect.size.width, rect.size.height);
    }];
}



@end
