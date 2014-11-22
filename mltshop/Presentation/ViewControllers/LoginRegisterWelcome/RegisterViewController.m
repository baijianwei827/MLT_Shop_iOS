//
//  RegisterViewController.m
//  merchant
//
//  Created by mactive.meng on 23/6/14.
//  Copyright (c) 2014 kkche. All rights reserved.
//

#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "ColorNavigationController.h"
#import "AppRequestManager.h"
#import "AppDelegate.h"
#import "KKTextField.h"
#import "KKFlatButton.h"
#import "UIViewController+ImageBackButton.h"
#import "Me.h"
#import "ModelHelper.h"
#import <HTProgressHUD/HTProgressHUD.h>
#import <HTProgressHUD/HTProgressHUDIndicatorView.h>
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@interface RegisterViewController ()<UITextFieldDelegate, UIScrollViewDelegate>
@property(nonatomic, strong)UIScrollView *loginPanel;
@property(nonatomic, strong)UIView *logoView;
@property(nonatomic, strong)KKTextField *userTextView;
@property(nonatomic, strong)KKTextField *passTextView;
@property(nonatomic, strong)KKTextField *emailTextView;
@property(nonatomic, strong)KKFlatButton *verifyButton;
@property(nonatomic, strong)KKFlatButton *signinButton;
@property(nonatomic, strong)KKFlatButton *tourButton;
@property(nonatomic, assign)NSInteger nowEditing;

// 编辑完成按钮
@property(nonatomic, strong)UIView *editAssistView;
@property(nonatomic, strong)UIButton *doneButton;


@end

#define LOGO_SIDE           140.0f
#define ANIMATION_OFFSET    TOTAL_HEIGHT * 0.3
#define OFFSET_Y            H_80
#define INVITE_TAG          101
#define MY_TAG              102
#define CODE_TAG            103
#define PASSWORD_TAG        104
#define REPASSWORD_TAG      105


@implementation RegisterViewController
@synthesize loginPanel;
@synthesize passTextView, userTextView,emailTextView;
@synthesize verifyButton;
@synthesize editAssistView, doneButton;
@synthesize inviteMobile;
@synthesize signinButton;
@synthesize tourButton;
@synthesize logoView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [NSString stringWithFormat:T(@"注册%@"),APP_NAME];
        self.view.backgroundColor = WHITECOLOR;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loginPanel = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, TOTAL_WIDTH, TOTAL_HEIGHT-1)];
    self.loginPanel.contentSize = CGSizeMake(TOTAL_WIDTH,TOTAL_HEIGHT);
    self.loginPanel.scrollEnabled = YES;
    self.loginPanel.delegate = self;
    [self.loginPanel setBackgroundColor:[UIColor clearColor]];
    self.loginPanel.showsVerticalScrollIndicator = NO;
    
    // logoview
    self.logoView = [[UIView alloc] initWithFrame:CGRectMake(130, H_50, H_60, H_60)];
    [self.logoView setBackgroundColor:GREENLIGHTCOLOR];
    [self.logoView.layer setCornerRadius:H_30];
    [self.logoView.layer setMasksToBounds:YES];
    
    UIImageView *logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 15, 36, 30)];
    [logoImageView setImage:[UIImage imageNamed:@"logo_luotuo"]];
    [self.logoView addSubview:logoImageView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [self.loginPanel addGestureRecognizer:singleTap];
    
    // userTextView
    self.userTextView = [[KKTextField alloc]initWithFrame:CGRectMake(LEFT_PADDING*3, OFFSET_Y+H_50,TOTAL_WIDTH-LEFT_PADDING*6, H_50)];
    self.userTextView.delegate = self;
    [self.userTextView setPlaceholder:T(@"用户名")];
    [self.userTextView setIconString:[NSString fontAwesomeIconStringForEnum:FAUser]];
    self.userTextView.keyboardType = UIKeyboardTypeNumberPad;
    self.userTextView.returnKeyType = UIReturnKeyNext;
    self.userTextView.tag = MY_TAG;
    
    // passTextView
    self.passTextView = [[KKTextField alloc]initWithFrame:CGRectMake(LEFT_PADDING*3, OFFSET_Y+H_50*2, TOTAL_WIDTH-LEFT_PADDING*6 , H_50)];
    self.passTextView.delegate = self;
    [self.passTextView setPlaceholder:T(@"密码")];
    [self.passTextView setIconString:[NSString fontAwesomeIconStringForEnum:FALock]];
    self.passTextView.returnKeyType = UIReturnKeyDone;
    self.passTextView.tag = PASSWORD_TAG;
    self.passTextView.secureTextEntry = YES;

    // emailTextView
    self.emailTextView = [[KKTextField alloc]initWithFrame:CGRectMake(LEFT_PADDING*3, OFFSET_Y+H_50*3, TOTAL_WIDTH-LEFT_PADDING*6 , H_50)];
    self.emailTextView.delegate = self;
    [self.emailTextView setPlaceholder:T(@"邮箱")];
    [self.emailTextView setIconString:[NSString fontAwesomeIconStringForEnum:FAEnvelope]];
    self.emailTextView.returnKeyType = UIReturnKeyDone;
    self.emailTextView.tag = REPASSWORD_TAG;
    self.emailTextView.secureTextEntry = YES;
    
    // verifyButton
    self.verifyButton = [KKFlatButton buttonWithType:UIButtonTypeCustom];
    [self.verifyButton setTitle:T(@"注册") forState:UIControlStateNormal];
    [self.verifyButton setFrame:CGRectMake(LEFT_PADDING*3, OFFSET_Y+H_50*4+TOP_PADDING*2, TOTAL_WIDTH-LEFT_PADDING*6 , H_50)];
    [self.verifyButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.verifyButton setBackgroundColor:BLUECOLOR];

    
    // change corner
    self.userTextView = (KKTextField *)[DataTrans roundCornersOnView:self.userTextView onTopLeft:YES topRight:YES bottomLeft:NO bottomRight:NO radius:5.0f];

    self.passTextView = (KKTextField *)[DataTrans roundCornersOnView:self.passTextView onTopLeft:YES topRight:YES bottomLeft:YES bottomRight:YES radius:0.0f];

    self.emailTextView = (KKTextField *)[DataTrans roundCornersOnView:self.emailTextView onTopLeft:NO topRight:NO bottomLeft:YES bottomRight:YES radius:5.0f];

    //
    [self.loginPanel addSubview:self.logoView];
    [self.loginPanel addSubview:self.userTextView];
    [self.loginPanel addSubview:self.passTextView];
    [self.loginPanel addSubview:self.emailTextView];
    [self.loginPanel addSubview:self.verifyButton];
    
    
    self.signinButton = [KKFlatButton buttonWithType:UIButtonTypeCustom];
    [self.signinButton setTitle:T(@"登录") forState:UIControlStateNormal];
    [self.signinButton setFrame:CGRectMake(0, TOTAL_HEIGHT-H_60*2, TOTAL_WIDTH , H_60)];
    [self.signinButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.signinButton setBackgroundColor:GREENCOLOR];
    self.signinButton = (KKFlatButton *)[DataTrans roundCornersOnView:self.signinButton onTopLeft:YES topRight:YES bottomLeft:YES bottomRight:YES radius:0.0f];
    
    
    self.tourButton = [KKFlatButton buttonWithType:UIButtonTypeCustom];
    [self.tourButton setTitle:T(@"随便看看") forState:UIControlStateNormal];
    [self.tourButton setFrame:CGRectMake(0, TOTAL_HEIGHT-H_60, TOTAL_WIDTH , H_60)];
    [self.tourButton addTarget:self action:@selector(tourAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tourButton setBackgroundColor:GREENLIGHTCOLOR];
    self.tourButton = (KKFlatButton *)[DataTrans roundCornersOnView:self.tourButton onTopLeft:YES topRight:YES bottomLeft:YES bottomRight:YES radius:0.0f];
    
    
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [bgView setImageToBlur:[UIImage imageNamed:@"train_bg"] completionBlock:^{
        [self.view addSubview:self.loginPanel];
        [self.view addSubview:self.signinButton];
        [self.view addSubview:self.tourButton];

    }];
    [self.view addSubview:bgView];
    
    
    [self setUpImageDownButton:0];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)loginAction
{
    LoginViewController *vc = [[LoginViewController alloc]initWithNibName:nil bundle:nil];
    ColorNavigationController *popNavController =
    [[ColorNavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:popNavController animated:YES completion:^{}];
}

- (void)tourAction
{
    [XAppDelegate showDrawerView];
}


- (void)registerAction
{
    if ([self checkAllTextField]) {
        [[AppRequestManager sharedManager]signUpWithMobile:self.userTextView.text password:self.passTextView.text email:self.emailTextView.text andBlock:^(id responseObject, NSError *error) {
            //
            if (responseObject != nil) {
//                [DataTrans showWariningTitle:T(@"注册成功,正在登陆") andCheatsheet:ICON_CHECK andDuration:1.0f];
//                run login and go main
//                SET_DEFAULT(NUM_BOOL(NO), @"HELPSEEN_INTRO");
//                SET_DEFAULT(NUM_BOOL(NO), @"HAS_SETTING_BINDING");
                [self verifyPasswordAction];
                
            }
            
            if (error != nil) {
                if ([(NSNumber *)responseObject[@"code"] integerValue] == 4006) {
                    [DataTrans showWariningTitle:T(@"该手机号已注册过") andCheatsheet:ICON_TIMES andDuration:1.0f];
                }
            }
            
        }];
    }
}


- (void)verifyPasswordAction
{
    // sign_in
    
    HTProgressHUD *HUD = [[HTProgressHUD alloc] init];
    HUD.indicatorView = [HTProgressHUDIndicatorView indicatorViewWithType:HTProgressHUDIndicatorTypeActivityIndicator];
    HUD.text = T(@"登录中...");
    [HUD showInView:self.view];
    
    
    [[AppRequestManager sharedManager] signInWithUsername:self.userTextView.text password:self.passTextView.text andBlock:^(id responseObject, NSError *error) {
        [HUD removeFromSuperview];

        if (responseObject != nil) {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
            //            dict[@"token"]  = responseObject[@"token"];
            //            dict[@"username"]   = responseObject[@"username"];
            
            [[ModelHelper sharedHelper]updateMeWithJsonData:dict];
            
            [XAppDelegate skipIntroView];
        }
        
        if(error != nil)
        {
            [HUD removeFromSuperview];
            [DataTrans showWariningTitle:T(@"用户名或密码错误") andCheatsheet:ICON_TIMES];
        }
        
    }];
}

- (void)checkPasswordAction
{
    NSString *pass = self.passTextView.text;
    NSString *repass = self.emailTextView.text;
    
    if (StringHasValue(pass) && StringHasValue(repass)) {
        if (![DataTrans isValidatePassword:pass] || ![DataTrans isValidatePassword:repass]) {
            [DataTrans showWariningTitle:T(@"密码应该设置为6位以上\n数字或字母组合") andCheatsheet:ICON_TIMES andDuration:1.0f];
        }else{
            if (![pass isEqualToString:repass]) {
                [DataTrans showWariningTitle:T(@"两次密码不同") andCheatsheet:ICON_CHECK andDuration:1.0f];
            }else{
                [self checkAllTextField];
            }
        }
    }else{
        if (StringHasValue(pass) && ![DataTrans isValidatePassword:pass] ) {
            [DataTrans showWariningTitle:T(@"密码应该设置为6位以上\n数字或字母组合") andCheatsheet:ICON_TIMES andDuration:1.0f];
        }
        if (StringHasValue(repass) && ![DataTrans isValidatePassword:repass] ) {
            [DataTrans showWariningTitle:T(@"密码应该设置为6位以上\n数字或字母组合") andCheatsheet:ICON_TIMES andDuration:1.0f];
        }
//        [DataTrans showWariningTitle:T(@"密码不可以为空") andCheatsheet:ICON_CHECK andDuration:1.0f];
    }
}



- (BOOL)checkAllTextField
{
    if (!StringHasValue(self.passTextView.text) || !StringHasValue(self.emailTextView.text)) {
        [DataTrans showWariningTitle:T(@"密码不能为空") andCheatsheet:ICON_TIMES andDuration:1.0f];
    }
    if ([DataTrans isValidateMobile:self.userTextView.text] &&
        [DataTrans isValidatePassword:self.passTextView.text] &&
        [DataTrans isValidatePassword:self.emailTextView.text] &&
        [self.passTextView.text isEqualToString:self.emailTextView.text]) {
        
        return YES;
    }else{
        return NO;
    }
}


/////////////////////////////////////////////////////////
#pragma mark - uitextfield delegate
/////////////////////////////////////////////////////////

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag == MY_TAG) {
        //检查用户名
    }
    else{
        [self checkAllTextField];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.nowEditing = textField.tag;
    [UIView animateWithDuration:0.5f animations:^{
        [self.loginPanel setY:-IOS7_CONTENT_OFFSET_Y];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == INVITE_TAG || textField.tag == MY_TAG) {
        if (![DataTrans isValidateMobile:textField.text]) {
            [textField.layer setBorderColor:REDCOLOR.CGColor];
            [DataTrans showWariningTitle:T(@"手机号格式有误") andCheatsheet:ICON_TIMES andDuration:1.0f];
        }else{
            [textField.layer setBorderColor:GRAYEXLIGHTCOLOR.CGColor];
        }
    }
    else if (textField.tag == PASSWORD_TAG || textField.tag == REPASSWORD_TAG){
        [self checkPasswordAction];
    }
    else{
        [self checkAllTextField];
    }
    
    return YES;
}


/////////////////////////////////////////////////////////
#pragma mark - delegate
/////////////////////////////////////////////////////////


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.userTextView resignFirstResponder];
    [self.passTextView resignFirstResponder];
    [self.emailTextView resignFirstResponder];
    
    [UIView animateWithDuration:0.5f animations:^{
        [self.loginPanel setY:0];
    }];
    

    
    if (self.passTextView.text.length == 0) {
        [self.passTextView setPlaceholder:T(@"密码")];
    }
    
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    [self.userTextView resignFirstResponder];
    [self.passTextView resignFirstResponder];
    [self.emailTextView resignFirstResponder];
    
    [UIView animateWithDuration:0.5f animations:^{
        [self.loginPanel setY:0];
    }];
    
//    [self checkAllTextField];
}


- (void)dealloc
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
