//
//  GestureLockViewController.m
//  MobileAppProjMobileAppIpad
//
//  Created by xuyunfei on 14-3-26.
//
//
#import "DebugViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "GestureLockViewController.h"
#import "AppDelegate.h"
#import "DemoViewController.h"
@interface GestureLockViewController (){
    KKGestureLockView * _lockView;
    NSString * _lastCode;   //上一次的输入
    BOOL    _noEqual;   //确认两次密码是否一致
    NSString * _gesureCodeKey;  //手势密码的KEY
    int inputStep;
}
@end

@implementation GestureLockViewController

@synthesize lbTip;
@synthesize mode;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //默认为输入模式
        mode = GestureLockViewInput;
        inputStep = 0;
        _lastCode = nil;
        _noEqual = NO;
        //初始化key
        NSString * loginSession = [AresSession singleton].
        key;
        NSString * userNo = loginSession;
        _gesureCodeKey = [NSString stringWithFormat:@"%@_GestureCode",userNo];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createGestureLockView];
    //根据模式设置显示
    [self updateViewByMode];
}

//检查是否设置了手势密码
- (BOOL)hasGestureLock
{
    NSString * passcode = [[NSUserDefaults standardUserDefaults] objectForKey:_gesureCodeKey];
    if(passcode != nil && [passcode length]>4) {
        return YES;
    }
    return NO;
}

static float scale  = 0.9f;
- (void)createGestureLockView
{
    CGRect rect =  [[UIScreen mainScreen] bounds];
    _lockView = [[KKGestureLockView alloc] initWithFrame:CGRectMake(362, 224, 300*scale, 300*scale)];
    [_lockView setCenter:CGPointMake(rect.size.width/2, rect.size.height/2+20)];
    _lockView.normalGestureNodeImage = [UIImage imageNamed:@"gesture_node_normal_iphone.png"];
    _lockView.selectedGestureNodeImage = [UIImage imageNamed:@"gesture_node_iphone_selected.png"];
    _lockView.lineColor = [UIColor colorWithRed:225.0/255 green:42.0/255 blue:42.0/255 alpha:1.0f];
    _lockView.lineWidth = 3;
    _lockView.delegate = self;
    [self.view addSubview:_lockView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender
{
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//    }];
    [self.view removeFromSuperview];
}

#pragma mark 手势
- (void)gestureLockView:(KKGestureLockView *)gestureLockView didEndWithPasscode:(NSString *)passcode
{
    //NSLog(@"%@",passcode);
    NSArray * codes = [passcode componentsSeparatedByString:@","];
    if([codes count] < 4) {
        return;
    }
    if(mode == GestureLockViewInput) {
        [self dealInputMode:passcode];
    }
    else if(mode == GestureLockViewSet) {
        [self dealSetMode:passcode];
    }
    else if(mode == GestureLockViewReset){
        [self dealResetMode:passcode];
    }
}

- (void)updateViewByMode
{
    if(mode == GestureLockViewInput) {
        if(_noEqual) {
            lbTip.text = @"手势密码不正确，请重新输入！";
        }
        else {
            lbTip.text = @"请输入设置的手势密码";
        }
    }
    else if(mode == GestureLockViewSet) {
        if(inputStep == 0) {
            if(_noEqual)
                lbTip.text = @"两次输入不一致，请重新设置";
            else
                lbTip.text = @"请绘制密码图案";
        }
        else if(inputStep == 1 ) {
            lbTip.text = @"请再次绘制密码图案";
        }
        else if (inputStep == 2) {
            lbTip.text = @"设置完毕，请返回";
        }
    }
}

- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}

- (void)dealInputMode:(NSString*)passcode
{
    NSString * passcodeStored = [[NSUserDefaults standardUserDefaults] objectForKey:_gesureCodeKey];
    if([[self md5:passcode] isEqualToString:passcodeStored]) {
        if(delegate !=nil &&[delegate respondsToSelector:@selector(GestureLockInputOK)]) {
//            [self dismissViewControllerAnimated:NO completion:^{
//                
//            }];
            [self.view removeFromSuperview];
            [delegate GestureLockInputOK];
        }
    }
    else {
        _noEqual = YES;
    }
    [self updateViewByMode];
}

- (void)dealSetMode:(NSString*)passcode
{
    //第一次输入
    if(inputStep == 0) {
        _lastCode = passcode;
        inputStep=1;
    }
    else if(inputStep == 1) {
        if([_lastCode isEqualToString:passcode] != YES) {
            _noEqual = YES;
            inputStep = 0;
        }
        else {
            _noEqual = NO;
            inputStep=2;
            _lockView.userInteractionEnabled = NO;
            //保存手势密码
            [self setPassword:passcode];
            return;
        }
    }
    
    [self updateViewByMode];
}

//
- (void)setPassword:(NSString*)passcode
{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[self md5:passcode] forKey:_gesureCodeKey];
    [userDefault synchronize];
    //设置成功 返回
    UIAlertView * avTip = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设置成功！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [avTip show];
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//    }];
    [self.view removeFromSuperview];
}

- (void)dealResetMode:(NSString*)passcode
{
    
}

- (IBAction)modifyGestureLock:(id)sender {
    NSLog(@"modify");
    lbTip.text = @"请绘制新的密码图案";
    mode = GestureLockViewSet;
    return;
    //退出重新登陆
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    UINavigationController * nav1 =(UINavigationController *) [[[UIApplication sharedApplication] delegate] window].rootViewController;
    NSLog(@"nav1:%@",nav1);
    NSLog(@"viewControllers:%@",[nav1.viewControllers description]);
    [nav1 popToRootViewControllerAnimated:YES];
    
}

-(void)show:(GestureLockViewShowMode)gestureLockViewShowMode inParentViewController:(UIViewController *)parentViewController animated:(BOOL)animated{
    switch (gestureLockViewShowMode) {
        case GestureLockViewAddView:
            [parentViewController.view addSubview:self.view];
            if (animated) {
                [self.view setAlpha:0.0];
                [UIView animateWithDuration:0.35 animations:^{
                    [self.view setAlpha:1.0];
                }];
            }
            break;
        case GestureLockViewPresentView:
            [parentViewController presentViewController:self animated:YES completion:^{
                
            }];
            break;
        case GestureLockViewPushView:
            [parentViewController.navigationController pushViewController:self animated:YES];
            break;
        default:
             [parentViewController.view addSubview:self.view];
            break;
    }
}

-(IBAction)loginOut:(id)sender{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.bocPay logOut];
    [app.bocPay onLogoutSuccess:^{
        DemoViewController *theDemoViewController = [[DemoViewController alloc] init];
        [app.window addSubview:theDemoViewController.view];
    }];
}

-(IBAction)changHost:(id)sender{
    DebugViewController *debug = [[DebugViewController alloc]initWithNibName:@"DebugViewController" bundle:nil];
    [self presentViewController:debug animated:YES completion:^{
        
    }];
}


@end
