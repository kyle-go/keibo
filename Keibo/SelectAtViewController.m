//
//  SelectAtViewController.m
//  Keibo
//
//  Created by kyle on 12/7/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "SelectAtViewController.h"
#import "UITableViewFollowingCell.h"
#import "WeiboNetWork.h"
#import "KxMenu.h"
#import "pinyin.h"
#import "UIUser.h"

@interface SelectAtViewController ()

@property (weak, nonatomic) IBOutlet UITableView *followingTableView;

@end

@implementation SelectAtViewController {
    NSInteger _cursor;
    NSString *uid;
    NSString *accessToken;

    //sth with table view
    NSMutableArray *sectionNames;
    NSMutableDictionary *sectionItems;
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
        sectionNames = [[NSMutableArray alloc] init];
        sectionItems = [[NSMutableDictionary alloc] init];
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
    accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];

    //数据库中获取最近联系人&我关注的人
    //
    //[self reloadTableViewData:users];
    
    //网络请求最新的我关注的人
    [self networkingFreshFollowing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//network data call back.
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
    [self reloadTableViewData:users];
}

- (void)showMenu:(UIButton *)sender

{
    NSArray *menuItems = @[[KxMenuItem menuItem:@"刷新"
                     image:[UIImage imageNamed:@"reload"]
                    target:self.navigationController
                    action:@selector(networkingFreshFollowing)]];
    
    CGRect frame = sender.frame;
    frame.origin.y += 10;
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:frame
                 menuItems:menuItems];
}

- (void)networkingFreshFollowing
{
    [WeiboNetWork getUserFollowings:accessToken uid:uid cursor:_cursor];
}

- (void)reloadTableViewData:(NSArray *)users
{
    /**********************
     * (search_bar,latest)
     A
     B
     ...
     Z
     #
     **********************/
    [sectionNames removeAllObjects];
    [sectionItems removeAllObjects];
    
    [sectionNames addObject:@"search"];
    [sectionNames addObject:@"最近联系人"];
    
    NSMutableArray *letters = [[NSMutableArray alloc] init];
    for (UIUser *u in users) {
        NSString *key;
        unichar ch = [u.name characterAtIndex:0];
        if (0x4e00 <= ch && ch <= 0x9fa6) {
            key = [NSString stringWithFormat:@"%c", pinyinFirstLetter(ch)];
        } else {
            key = [NSString stringWithFormat:@"%c", ch];
        }
        key = [key uppercaseString];
        if (key.length == 0 ||'A' > [key characterAtIndex:0] || [key characterAtIndex:0]> 'Z') {
            key = @"#";
        }
        
        NSMutableArray *value = [sectionItems objectForKey:key];
        if (!value) {
            value = [[NSMutableArray alloc] init];
            [value addObject:u.name];
            [sectionItems setObject:value forKey:key];
        } else {
            [value addObject:u.name];
        }
        
        if (![letters containsObject:key]) {
            [letters addObject:key];
        }
    }
    
    [letters sortUsingSelector:@selector(compare:)];
    BOOL anySharp = NO;
    for (NSString *ch in letters) {
        if (![ch isEqualToString:@"#"]) {
            [sectionNames addObject:ch];
        } else {
            anySharp = YES;
        }
    }
    if (anySharp) {
        [sectionNames addObject:@"#"];
    }
    
    [self.followingTableView reloadData];
}

#pragma mark -- sth with table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionNames count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionNames objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 5; //TODO default 10 latest.
    }
    
    NSString *sectionName = [sectionNames objectAtIndex:section];
    NSArray *cellNames = [sectionItems objectForKey:sectionName];
    return [cellNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"followingUserIdenty";
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [tableView registerNib:[UINib nibWithNibName:@"UITableViewFollowingCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    });
    
    UITableViewFollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.nameLabel.text = @"test";
    if (indexPath.section >= 2) {
        NSString *sectionName = [sectionNames objectAtIndex:indexPath.section];
        NSArray *cellNames = [sectionItems objectForKey:sectionName];
        cell.nameLabel.text = [cellNames objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01;
    }
    return 18;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark -- Cancel，Finished
- (void)Cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)Finished
{
    [self Cancel];
}

@end
