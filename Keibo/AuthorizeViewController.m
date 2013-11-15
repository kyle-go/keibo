//
//  AuthorizeViewController.m
//  Keibo
//
//  Created by kyle on 11/13/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "AuthorizeViewController.h"
#import "MMDrawerController.h"
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceed:) name:@"AuthorizeView_loginSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed) name:@"AuthorizeView_loginFailed" object:nil];
    
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

- (void)loginSucceed:(NSNotification *)notify
{
    NSDictionary *param = notify.userInfo;
    NSString *accessToken = [param objectForKey:@"access_token"];
    NSString *uid = [param objectForKey:@"uid"];
    
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kAccessToken];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:kUid];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //初始化数据库
    [[Storage storageInstance] initStorageWithUId:uid];
    
    //准备显示主界面
    [self getLoginInformation:accessToken uid:uid];
    [self showMainView];
}

- (void)loginFailed
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"token过期了么?" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
    [self login];
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

#pragma mark ---- get information when login -----------
- (void)getLoginInformation:(NSString *)accessToken uid:(NSString *)uid
{
    //获取登录者个人资料
    [WeiboNetWork getUser:accessToken uid:uid];
    
    //获取最近6条微博
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
    [mainNav.navigationBar setBarTintColor:[UIColor darkGrayColor]];
    
    UINavigationController *messageNav = [[UINavigationController alloc] initWithRootViewController:messageViewController];
    [messageNav.navigationBar setBarTintColor:[UIColor darkGrayColor]];
    
    UINavigationController *personNav = [[UINavigationController alloc] initWithRootViewController:personViewController];
    [personNav.navigationBar setBarTintColor:[UIColor darkGrayColor]];
    
    UINavigationController *settingNav = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    [settingNav.navigationBar setBarTintColor:[UIColor darkGrayColor]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:[[NSArray alloc] initWithObjects:mainNav, messageNav, personNav, settingNav, nil]];
    
    drawerController = [[MMDrawerController alloc]
                                            initWithCenterViewController:tabBarController
                                            leftDrawerViewController:[[LeftViewController alloc] init]];
    
    [drawerController setShouldStretchDrawer:NO];
    [drawerController setMaximumLeftDrawerWidth:250];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self presentViewController:drawerController animated:YES completion:nil];
}

@end
