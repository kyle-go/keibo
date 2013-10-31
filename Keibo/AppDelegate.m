//
//  KSAppDelegate.m
//  Keibo
//
//  Created by kyle on 13-9-29.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "AppDelegate.h"
#import "WeiboSDK.h"
#import "WeiboInstance.h"
#import "MMDrawerController.h"
#import "LeftViewController.h"
#import "MainPageViewController.h"
#import "MessageViewController.h"
#import "PersonViewController.h"
#import "SettingViewController.h"


@implementation AppDelegate

MMDrawerController *drawerController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    MainPageViewController *mainViewController = [[MainPageViewController alloc] init];
    MessageViewController *messageViewController = [[MessageViewController alloc] init];
    PersonViewController *personViewController = [[PersonViewController alloc] init];
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    [tabBarController setViewControllers:[[NSArray alloc] initWithObjects:mainViewController, messageViewController, personViewController, settingViewController, nil]];
    
    drawerController = [[MMDrawerController alloc]
                                            initWithCenterViewController:tabBarController
                                            leftDrawerViewController:[[LeftViewController alloc] init]];
    [drawerController setShouldStretchDrawer:NO];
    [drawerController setMaximumLeftDrawerWidth:250];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    self.window.rootViewController = drawerController;
    [self.window makeKeyAndVisible];
    
    [WeiboInstance weiboInstance];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WeiboSDK handleOpenURL:url delegate:[WeiboInstance weiboInstance]];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WeiboSDK handleOpenURL:url delegate:[WeiboInstance weiboInstance]];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) changeLeftViewController:(UIViewController *)viewController
{
    
}

@end
