//
//  SelectAtViewController.m
//  Keibo
//
//  Created by kyle on 12/7/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "SelectAtViewController.h"
#import "WeiboNetWork.h"
#import "KxMenu.h"

@interface SelectAtViewController ()

@end

@implementation SelectAtViewController {
    NSInteger _cursor;
    NSString *uid;
}

- (UIButton *)createNavButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(80, 30, 120, 40)];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:@"联系人" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"nav-more.png"] forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 6.0, 0.0, 40.0)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(2, 80, 0.0, 2.0)];
    
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    return button;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _cursor = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *navButton = [self createNavButton];
    [navButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = navButton;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(Cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(Finished)];
    
    //添加我关注的人观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followingUsers:) name:@"NotificationCenter_FollowingUsers" object:nil];
    
    uid = [[NSUserDefaults standardUserDefaults] objectForKey:kUid];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];

    //数据库中获取最近联系人&我关注的人
    
    //网络请求最新的我关注的人
    [WeiboNetWork getUserFollowings:accessToken uid:uid cursor:_cursor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)followingUsers:(NSNotification *)notify
{
    NSDictionary *param = [notify userInfo];
    if ([param count] == 0) {
        return;
    }
    NSString *userId = [param objectForKey:@"uid"];
    if ([userId isEqualToString:uid] == NO) {
        return;
    }
    NSArray *users = [param objectForKey:@"array"];
}

- (void)showMenu:(UIButton *)sender

{
    NSArray *menuItems = @[[KxMenuItem menuItem:@"刷新"
                     image:[UIImage imageNamed:@"reload"]
                    target:self.navigationController
                    action:@selector(reloadFollowing)]];
    
    CGRect frame = sender.frame;
    frame.origin.y += 10;
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:frame
                 menuItems:menuItems];
}

- (void)reloadFollowing
{
    
}

- (void)Cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)Finished
{
    [self Cancel];
}

@end
