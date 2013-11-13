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
#import "WeiboCellData.h"

@interface MainPageViewController ()

@end

@implementation MainPageViewController {
    NSMutableArray *weiboArray;
    NSMutableDictionary *weiboHeights;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar_home"]];
        self.title = @"首页";
        weiboArray = [[NSMutableArray alloc] init];
        weiboHeights = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //show登陆窗口
    AuthorizeViewController *authController = [[AuthorizeViewController alloc] init];
    [self addChildViewController:authController];
    
    self.navigationItem.title = @"程序猿卡尔";
    
    //添加左按钮
    self.navigationItem.leftBarButtonItem = [[MMDrawerBarButtonItem alloc]
                                             initWithTarget:self
                                             action:@selector(showLeftView)];
    //添加右按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                              target:self
                                              action:@selector(newWeibo)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshMainWindowTable:) name:@"freshMainWindowTable" object:nil];
    
    //假数据
    WeiboCellData *a = [[WeiboCellData alloc] init];
    a.weiboId = 1001;
    a.avatarUrl = @"http://tp2.sinaimg.cn/1496915057/50/40020993740/1";
    a.name = @"OnlySwan";
    a.feedComeFrom = @"vivo X3";
    a.date = [NSDate date];
    a.content = @"未来世界[挖鼻屎]//@珏铭:腾讯WE，一直不知道有这个活动。。 //@D狐狸：腾讯？ //@珏铭:[挖鼻屎]真好， @HaichunZ";
    a.reposts = 1;
    a.likes = 3;
    a.hasOriginWeibo = YES;
    a.originWeiboId = 100;
    a.originName = @"大亨heng";
    a.originContent = @"位置太好了吧，第二排～";
    a.originFeedComeFrom = @"新浪微博";
    a.originReposts = 2;
    a.originComments = 0;
    a.originLikes = 8;
    
    WeiboCellData *b = [[WeiboCellData alloc] init];
    b.weiboId = 1002;
    b.avatarUrl = @"http://tp1.sinaimg.cn/1496850204/50/1283204010/1";
    b.name = @"封新城";
    b.feedComeFrom = @"iPad客户端";
    b.date = [NSDate date];
    b.content = @"//@陈晓阳改革: 难怪日本这一AV大国日比较长寿呢[哈哈]懂了！";
    b.reposts = 1;
    b.likes = 3;
    b.hasOriginWeibo = YES;
    b.originWeiboId = 200;
    b.originName = @"日本新闻网微博";
    b.originContent = @"【专家称性生活能减中老年人癌变】被称为“世界治疗ED第一人”的东京都浜松町第一医院院长竹越昭彦，在最近出版的《生涯性爱的推荐》一书中指出，为了防止心脏病和前列腺癌的发生，中老年男性应该多从事性生活，性生活能促进血液循环，提高免疫力，富有朝气。详情http://t.cn/zRy9FLT";
    b.originFeedComeFrom = @"iPhone客户端";
    b.originReposts = 2;
    b.originComments = 0;
    b.originLikes = 8;
    
    WeiboCellData *c = [[WeiboCellData alloc] init];
    c.weiboId = 1001;
    c.avatarUrl = @"http://tp2.sinaimg.cn/1496915057/50/40020993740/1";
    c.name = @"OnlySwan";
    c.feedComeFrom = @"vivo X3";
    c.date = [NSDate date];
    c.content = @"未来世界[挖鼻屎]//@珏铭:腾讯WE，一直不知道有这个活动。。 //@D狐狸：腾讯？ //@珏铭:[挖鼻屎]真好， @HaichunZ";
    c.reposts = 1;
    c.likes = 3;
    c.hasOriginWeibo = YES;
    c.originWeiboId = 100;
    c.originName = @"大亨heng";
    c.originContent = @"位置太好了吧，第二排～";
    c.originFeedComeFrom = @"新浪微博";
    c.originReposts = 2;
    c.originComments = 0;
    c.originLikes = 8;
    
    [weiboArray addObject:b];
    [weiboArray addObject:a];
    [weiboArray addObject:c];
    
    [weiboHeights setObject:[[NSNumber alloc] initWithFloat:250.0] forKey:@"a"];
    [weiboHeights setObject:[[NSNumber alloc] initWithFloat:250.0] forKey:@"b"];
    [weiboHeights setObject:[[NSNumber alloc] initWithFloat:250.0] forKey:@"c"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showLeftView {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)newWeibo {
    
}

#pragma mark -- table View Data Source
- (void) freshMainWindowTable:(NSNotification *)param
{
    id cell = [param.userInfo objectForKey:@"cell"];
    CGFloat height = [[param.userInfo objectForKey:@"height"] floatValue];
    
    if ([weiboArray objectAtIndex:0] == cell) {
        [weiboHeights setObject: [[NSNumber alloc]initWithFloat:height] forKey:@"a"];
    }
    
    if ([weiboArray objectAtIndex:1] == cell) {
        [weiboHeights setObject: [[NSNumber alloc]initWithFloat:height] forKey:@"b"];
    }
    
    if ([weiboArray objectAtIndex:2] == cell) {
        [weiboHeights setObject: [[NSNumber alloc]initWithFloat:height] forKey:@"c"];
    }
    
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
    if (!cell) {
        cell = [[WeiboTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.webView.delegate = cell;

    [cell updateWithWeiboData:[weiboArray objectAtIndex:indexPath.row]];
    
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
    if (indexPath.row == 0) {
        return [[weiboHeights objectForKey:@"a"] floatValue];
    }
    else if (indexPath.row == 1) {
        return [[weiboHeights objectForKey:@"b"] floatValue];
    }
    else {//(indexPath.row == 2) {
        return [[weiboHeights objectForKey:@"c"] floatValue];
    }
}

@end
