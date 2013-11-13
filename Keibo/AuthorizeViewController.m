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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---- UIWebViewDelegate ---------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSLog(@"webview's url = %@",url);
    
	NSArray *array = [[url absoluteString] componentsSeparatedByString:@"#"];
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
        
        //获取个人资料

        //取消本view的显示
        [self showMainView];
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

- (void)showMainView
{
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
