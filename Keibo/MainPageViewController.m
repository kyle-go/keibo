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
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
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
    if ([userName length] > 0) {
        self.title = userName;
    }
    self.tabBarItem.title = @"首页";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshTableView:) name:@"freshTableView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLoginUser:) name:@"NotificationCenter_LoginUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWeibos:) name:@"NotificationCenter_LoginUserWeibos" object:nil];
    
    //从数据库取数据
    NSArray *array = [DataAdapter getLoginUserWeibos:[kWeiboCountString intValue] date:nil];
    if ([array count] == 0 || [array count] >= 100) {
        [WeiboNetWork getLoginUserWeibos:accessToken];
    } else {
        [self setWeiboArray:array];
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
    
    EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    view.delegate = self;
    [self.tableView addSubview:view];
    _refreshHeaderView = view;
    
	//update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(-65,0,0,0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)getLoginUser:(NSNotification *)notify
{
    NSDictionary *param = notify.userInfo;
    UIUser *user = [param objectForKey:@"User"];
    self.title = user.name;
    self.tabBarItem.title = @"首页";
}

-(void)getWeibos:(NSNotification *)notify
{
    NSLog(@"getWeibs...callbakc...");
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


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}

@end
