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
								   @"token",                        @"response_type",   //access_token
                                   kRedirectUri,                    @"redirect_uri",    //申请时的重定向地址
								   @"mobile",                       @"display",         //web页面的显示方式
                                   nil];
	
	NSURL *url = [KUnits generateURL:@"https://api.weibo.com/oauth2/authorize" params:params];
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

#pragma mark ---- UIWebViewDelegate ---------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"webview's url = %@", [request URL]);
    
	NSArray *array = [[[request URL] absoluteString] componentsSeparatedByString:@"#"];
    if ([array count] <= 1) {
        return YES;
    }
    
    NSString *value = [array objectAtIndex:1];
    NSRange range1 = [value rangeOfString:@"error_code%3A=" options:NSCaseInsensitiveSearch];
    NSRange range2 = [value rangeOfString:@"error_code:=" options:NSCaseInsensitiveSearch];
    
    if (range1.location == NSNotFound && range2.location == NSNotFound) {
        //access_token=2.00vVnMpDjoxjvDbc593cb4eft_exCE&remind_in=556237&expires_in=556237&uid=3505041903
        NSString *access_token = [KUnits getSubSplitString:value sub:@"access_token="];
        NSString *expires_in = [KUnits getSubSplitString:value sub:@"expires_in"];
        NSString *uid = [KUnits getSubSplitString:value sub:@"uid="];
        
        //登陆成功
        [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:kAccessToken];
        [[NSUserDefaults standardUserDefaults] setObject:uid forKey:kUserId];
        [[NSUserDefaults standardUserDefaults] setObject:expires_in forKey:kExpirseIn];
        [[NSUserDefaults standardUserDefaults] synchronize];

        //显示主界面
        [self forMainView];
    } else {
        //error%3A=appkey%20permission%20denied&error_code%3A=21337
        NSRange range = (range1.location == NSNotFound? range2 : range1);
        NSString *code = [value substringFromIndex:range.location + range.length];
        NSString *text = [[NSString alloc] initWithFormat:@"错误码:%@", code];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登录失败" message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
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
