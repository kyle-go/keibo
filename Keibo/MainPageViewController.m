//
//  MainPageViewController.m
//  Keibo
//
//  Created by kyle on 13-10-31.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "MainPageViewController.h"
#import "AuthorizeViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "WeiboTableCell.h"
#import "UIUser.h"
#import "UIWeibo.h"
#import "DataAdapter.h"
#import "WeiboNetWork.h"

@interface MainPageViewController ()

@end

@implementation MainPageViewController {
    NSMutableArray *weiboArray;
    NSMutableArray *weiboHeights;
}

#pragma mark -------------------- private -----------------------------------
- (void)setWeiboArray:(NSArray *)weibos
{
    [weiboArray setArray:weibos];
    
    NSUInteger count = [weiboArray count];
    [weiboHeights removeAllObjects];
    for (NSUInteger i=0; i<count; i++) {
        [weiboHeights addObject:[[NSNumber alloc] initWithInt:150]];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar_home"]];
        weiboArray = [[NSMutableArray alloc] init];
        weiboHeights = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:kUid];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    
    self.title = @"正在获取...";
    NSString *userName = [DataAdapter UserAdapter:uid].name;
    if ([userName length] == 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLoginUser:) name:@"NotificationCenter_LoginUser" object:nil];
    } else {
        self.title = userName;
    }
    
    //添加左按钮
    self.navigationItem.leftBarButtonItem = [[MMDrawerBarButtonItem alloc]
                                             initWithTarget:self
                                             action:@selector(showLeftView)];
    //添加右按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                              target:self
                                              action:@selector(newWeibo)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshTableView:) name:@"freshTableView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWeibos:) name:@"NotificationCenter_LoginUserWeibos" object:nil];
    //从数据库取数据
    NSArray *array = [DataAdapter getLoginUserWeibos:[kWeiboCountString intValue] date:nil];
    if ([array count] == 0) {
        //TODO 发起网络请求
        [WeiboNetWork getLoginUserWeibos:accessToken];
    } else {
        [self setWeiboArray:array];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)getLoginUser:(NSNotification *)notify
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSDictionary *param = notify.userInfo;
    UIUser *user = [param objectForKey:@"User"];
    self.title = user.name;
}

-(void)getWeibos:(NSNotification *)notify
{
    NSDictionary *param = notify.userInfo;
    if ([param count] == 0) {
        return;
    }
    
    NSString *type = [param objectForKey:@"type"];
    if ([type isEqualToString:@"latest"]) {
        [self setWeiboArray:[param objectForKey:@"array"]];
    } else if ([type isEqualToString:@"since"]) {
        //
    } else if([type isEqualToString:@"max"]) {
        //
    } else {
        //
    }
    
    [self.tableView reloadData];
}

- (void)showLeftView {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)newWeibo {
    
}

#pragma mark -- table View Data Source
- (void) freshTableView:(NSNotification *)notify
{
    NSDictionary *param = notify.userInfo;
    
    id index = [param objectForKey:@"index"];
    id height = [param objectForKey:@"height"];
    
    [weiboHeights replaceObjectAtIndex:[index intValue] withObject:height];
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [weiboArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"weiboCellIdentifier";
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [tableView registerNib:[UINib nibWithNibName:@"WeiboTableCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    });
    
    WeiboTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    assert(cell);
    [cell updateWithWeiboData:[weiboArray objectAtIndex:indexPath.row] index:indexPath.row];
    
    return cell;
}

//取消选中状态
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

//隐藏section头部
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[weiboHeights objectAtIndex:indexPath.row] floatValue];
}

@end
