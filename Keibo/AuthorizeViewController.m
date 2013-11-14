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

@interface AuthorizeViewController ()

@end

@implementation AuthorizeViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceed:) name:@"loginSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginUnSucceed) name:@"loginUnSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenExpired) name:@"accessTokenExpired" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenNoExpired) name:@"accessTokenNoExpired" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenNetWorkFailure) name:@"accessTokenNetWorkFailure" object:nil];
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    if (!accessToken) {
        [self Login];
        return;
    }
    [WeiboNetWork checkAccessToken:accessToken];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)Login {
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   kAppKey,                         @"client_id",       //申请的appkey
                                   kRedirectUri,                    @"redirect_uri",    //申请时的重定向地址
								   @"mobile",                       @"display",         //web页面的显示方式
                                   @"all",                          @"scope",
                                   @"true",                         @"forcelogin",
                                   nil];
	
	NSURL *url = [KUnits generateURL:@"https://open.weibo.cn/oauth2/authorize" params:params];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
	[self.webView loadRequest:request];
}

#pragma mark ------ net working callback ------
- (void)accessTokenExpired
{
    //已经过期，重新登陆
    [self Login];
}

- (void)accessTokenNoExpired
{
    //没过期，显示主界面
    [self forMainView];
}

- (void)accessTokenNetWorkFailure
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请检查网络" message:@"验证token失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

- (void)loginSucceed:(NSNotification *)notify
{
    NSDictionary *param = notify.userInfo;
    NSString *accessToken = [param objectForKey:@"access_token"];
    NSString *userId = [param objectForKey:@"uid"];
    
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kAccessToken];
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kUserId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self forMainView];
}

- (void)loginUnSucceed
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请检查网络" message:@"登陆失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark ---- UIWebViewDelegate ---------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [[request URL] absoluteString];
    NSLog(@"webview's url = %@", url);
    
    NSRange range = [url rangeOfString:@"https://github.com/kylescript?code="];
    if (range.location == NSNotFound) {
        return YES;
    }
    
    NSString *code = [url substringFromIndex:range.location + range.length];
    [WeiboNetWork getAccessTokenByCode:code];
    return NO;
}

- (void)forMainView
{
    //获取登录者个人资料
    
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
    
    MMDrawerController *drawerController = [[MMDrawerController alloc]
                                            initWithCenterViewController:tabBarController
                                            leftDrawerViewController:[[LeftViewController alloc] init]];
    
    [drawerController setShouldStretchDrawer:NO];
    [drawerController setMaximumLeftDrawerWidth:250];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self presentViewController:drawerController animated:YES completion:nil];
}

@end
