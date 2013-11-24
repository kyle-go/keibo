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
    UITableView *tableView;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    EGORefreshTableFooterView *_refreshFooterView;
    BOOL isReloading;
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

- (void)addWeiboArray:(NSArray *)weibos front:(BOOL)front
{
    if ([weibos count] == 0) {
        return;
    }
    
    if (front) {
        NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:weibos];
        [tmp addObjectsFromArray:weiboArray];
        [weiboArray setArray:tmp];
    } else {
        [weiboArray addObjectsFromArray:weibos];
    }
    
    NSUInteger count = [weibos count];
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
    
    CGRect frame = CGRectMake(0, 65, 320, 568-65-50);
    UIView *tempView = [[UIView alloc] initWithFrame:frame];
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,568-65-50) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tempView addSubview:tableView];
    [self.view addSubview:tempView];
    
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
    
    //下拉刷新
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [tableView addSubview:_refreshHeaderView];
	[_refreshHeaderView refreshLastUpdatedDate];
    
    //执行一下下拉刷新动作
    [self actionPullDown];
}

- (void)setFooterView
{
    CGFloat height = MAX(tableView.contentSize.height, tableView.frame.size.height);
    if (_refreshFooterView && [_refreshFooterView superview]) {
        // reset position
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              tableView.frame.size.width,
                                              self.view.bounds.size.height);
    } else {
        // create the footerView
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         tableView.frame.size.width, self.view.bounds.size.height)];
        _refreshFooterView.delegate = self;
        [tableView addSubview:_refreshFooterView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView refreshLastUpdatedDate];
    }
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
    NSDictionary *param = notify.userInfo;
    if ([param count] == 0) {
        return;
    }
    
    id array = [param objectForKey:@"array"];
    NSString *type = [param objectForKey:@"type"];
    
    if ([type isEqualToString:@"latest"]) {
        [self setWeiboArray:array];
    } else if ([type isEqualToString:@"since"]) {
        [self addWeiboArray:array front:YES];
        isReloading = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tableView];
    } else{
        assert([type isEqualToString:@"max"]);
        [self addWeiboArray:array front:NO];
        isReloading = NO;
        //用完footer赶紧删！
        [_refreshFooterView removeFromSuperview];
    }
    
    [tableView reloadData];
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
    
    [tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [weiboArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView2 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //只在最后一个cell出来的时候 加载footer
    if (indexPath.row == [weiboArray count] - 1) {
        if (_refreshFooterView) {
            [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:tableView];
        }
        [self setFooterView];
    }
    
    static NSString *cellIdentifier = @"weiboCellIdentifier";
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [tableView2 registerNib:[UINib nibWithNibName:@"WeiboTableCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    });
    
    WeiboTableCell *cell = [tableView2 dequeueReusableCellWithIdentifier:cellIdentifier];
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

- (void)wtfDone
{
    isReloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tableView];
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:tableView];
        [self setFooterView];
    }
}

//下拉刷新动作
- (void)actionPullDown
{
    isReloading = YES;
    if ([weiboArray count] > 0) {
        UIWeibo *weibo = [weiboArray objectAtIndex:0];
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
        [WeiboNetWork getLoginUserWeibos:accessToken since:[[NSString alloc] initWithFormat:@"%lld", weibo.weiboId]];
    } else {
        [self performSelector:@selector(wtfDone) withObject:nil afterDelay:0.6];
    }
}

//上拉刷新
- (void)actionPullUp
{
    isReloading = YES;
    if ([weiboArray count] > 0) {
        NSInteger count = [weiboArray count];
        UIWeibo *weibo = [weiboArray objectAtIndex:count - 1];
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
        [WeiboNetWork getLoginUserWeibos:accessToken max:[[NSString alloc] initWithFormat:@"%lld", weibo.weiboId]];
    } else {
        [self performSelector:@selector(wtfDone) withObject:nil afterDelay:0.6];
    }
}

#pragma mark- EGORefreshTableDelegate
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    if(aRefreshPos == EGORefreshHeader) {
        [self actionPullDown];
    } else {
        assert(aRefreshPos == EGORefreshFooter);
        [self actionPullUp];
    }
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view
{
    return isReloading;
}

- (NSDate *)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
    return [NSDate date];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
	
	if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	
	if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

@end
