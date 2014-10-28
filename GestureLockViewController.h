//
//  GestureLockViewController.h
//  MobileAppProjMobileAppIpad
//
//  Created by xuyunfei on 14-3-26.
//
//

#import <UIKit/UIKit.h>
#import "KKGestureLockView.h"

//手势密码视图工作模式
typedef enum {
    GestureLockViewInput=0,
    GestureLockViewSet,
    GestureLockViewReset
}GestureLockViewMode;

//手势密码视图显示模式 add by 胡皓 2014-9-9
typedef enum {
    GestureLockViewAddView=0,
    GestureLockViewPresentView,
    GestureLockViewPushView
}GestureLockViewShowMode;

@protocol GestureLockViewDelgate <NSObject>
- (void)GestureLockInputOK;

@end

@interface GestureLockViewController : UIViewController<KKGestureLockViewDelegate>{
    NSInteger mode;
    id<GestureLockViewDelgate> delegate;
}
@property(assign)NSInteger mode;
@property(strong,nonatomic)IBOutlet UILabel * lbTip;
@property(strong,nonatomic)IBOutlet UIImageView * bgImage;
@property(strong)id delegate;

- (BOOL)hasGestureLock;


@property (strong, nonatomic) IBOutlet UIButton *modifyGestureLockBtn;
- (IBAction)modifyGestureLock:(id)sender;
-(void)show:(GestureLockViewShowMode)gestureLockViewShowMode inParentViewController:(UIViewController *)parentViewController animated:(BOOL)animated;
;
@end
