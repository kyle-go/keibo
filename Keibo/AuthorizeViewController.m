//
//  AuthorizeViewController.m
//  Keibo
//
//  Created by kyle on 11/13/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "AuthorizeViewController.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "LeftViewController.h"
#import "MainPageViewController.h"
#import "MessageViewController.h"
#import "PersonViewController.h"
#import "MoreViewController.h"
#import "KUnits.h"
#import "WeiboNetWork.h"
#import "Storage.h"

@interface AuthorizeViewController ()

@end

@implementation AuthorizeViewController {
    MMDrawerController *drawerController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCallBack:) name:@"NotificationCenter_Login" object:nil];
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    if (!accessToken) {
        [self login];
        return;
    }
    
    [WeiboNetWork checkAccessToken:accessToken];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -------- 登录相关 ------------------------
- (void)login {
	[self.webView loadRequest:[WeiboNetWork loginRequest]];
}

- (void)loginCallBack:(NSNotification *)notify
{
    if (!notify.userInfo) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"token过期了么?" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        [self login];
        return;
    }
    
    //获取登录者个人资料
    [WeiboNetWork getUser:[[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken] uid:[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
    
    //准备显示主界面
    [self showMainView];
}

#pragma mark ---- UIWebViewDelegate ---------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [[request URL] absoluteString];
    NSString *searchString = [[NSString alloc] initWithFormat:@"%@?code=", kRedirectUri];
    NSRange range = [url rangeOfString:searchString];
    if (range.location == NSNotFound) {
        return YES;
    }
    
    NSString *code = [url substringFromIndex:range.location + range.length];
    [WeiboNetWork getAccessTokenByCode:code];
    return NO;
}

#pragma mark ---- show main window ---------
- (void)showMainView
{
    //帐号注销的情况
    if (drawerController) {
        [self presentViewController:drawerController animated:YES completion:nil];
        return;
    }
    
    //显示主界面
    MainPageViewController *mainViewController = [[MainPageViewController alloc] init];
    MessageViewController *messageViewController = [[MessageViewController alloc] init];
    PersonViewController *personViewController = [[PersonViewController alloc] init];
    MoreViewController *settingViewController = [[MoreViewController alloc] init];
    
    UINavigationController *mainNav = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    //[mainNav.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    UINavigationController *messageNav = [[UINavigationController alloc] initWithRootViewController:messageViewController];
    //[messageNav.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    UINavigationController *personNav = [[UINavigationController alloc] initWithRootViewController:personViewController];
    //[personNav.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    UINavigationController *settingNav = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    //[settingNav.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:[[NSArray alloc] initWithObjects:mainNav, messageNav, personNav, settingNav, nil]];
    
    drawerController = [[MMDrawerController alloc]
                                            initWithCenterViewController:tabBarController
                                            leftDrawerViewController:[[LeftViewController alloc] init]];
    
    [drawerController setShouldStretchDrawer:NO];
    [drawerController setMaximumLeftDrawerWidth:250];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [drawerController setDrawerVisualStateBlock:[MMDrawerVisualState slideAndScaleVisualStateBlock]];
    
    [self presentViewController:drawerController animated:YES completion:nil];
}

@end
