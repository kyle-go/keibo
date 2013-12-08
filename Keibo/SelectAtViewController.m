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
#import "DataAdapter.h"
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
    NSMutableArray *users;
    NSMutableArray *sectionNames;
    NSMutableDictionary *sectionItems;
    NSMutableDictionary *sectionItemsStatus;
    UISearchBar *searchBar;
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
        users = [[NSMutableArray alloc] init];
        sectionNames = [[NSMutableArray alloc] init];
        sectionItems = [[NSMutableDictionary alloc] init];
        sectionItemsStatus = [[NSMutableDictionary alloc] init];
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
    
    
    self.followingTableView.sectionIndexColor = [UIColor darkGrayColor];
    self.followingTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.followingTableView.sectionIndexTrackingBackgroundColor = [UIColor lightGrayColor];
    
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
    NSArray *tmp = [param objectForKey:@"array"];

    _cursor += tmp.count;
    [users addObjectsFromArray:tmp];
    
    [self reloadTableViewData];
    
    //未获取完，继续获取
    if (tmp.count >= 50) {
        [self networkingFreshFollowing];
    }
}

- (void)showMenu:(UIButton *)sender
{
    [searchBar resignFirstResponder];

    NSArray *menuItems = @[[KxMenuItem menuItem:@"刷新"
                     image:[UIImage imageNamed:@"reload"]
                    target:self.navigationController
                    action:@selector(networkingFreshAllFollowing)]];
    
    CGRect frame = sender.frame;
    frame.origin.y += 10;
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:frame
                 menuItems:menuItems];
}

- (void)networkingFreshAllFollowing
{
    _cursor = 0;
    [self networkingFreshFollowing];
}

- (void)networkingFreshFollowing
{
    [WeiboNetWork getUserFollowings:accessToken uid:uid cursor:_cursor];
}

- (void)reloadTableViewData
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
    [sectionItemsStatus removeAllObjects];
    
    [sectionNames addObject:@"search"];
    [sectionNames addObject:@"最近联系人"];
    
    //TODO for latest user.
    //
    
    
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
        NSMutableArray *status = [sectionItemsStatus objectForKey:key];
        if (!value) {
            value = [[NSMutableArray alloc] init];
            status = [[NSMutableArray alloc] init];
            [value addObject:u];
            [sectionItems setObject:value forKey:key];
            [status addObject:[[NSNumber alloc] initWithBool:NO]];
            [sectionItemsStatus setObject:status forKey:key];
        } else {
            [value addObject:u];
            [status addObject:[NSNumber numberWithBool:NO]];
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

- (void)registerAvatarImageFresh
{
    [[NSNotificationCenter defaultCenter] addObserver:self.followingTableView selector:@selector(reloadData) name:@"NotificationCenter_Media" object:nil];
}

#pragma mark -- sth with table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionNames count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
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
    //for search bar
    if (indexPath.section == 0) {
        if (!searchBar) {
            searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
        }
        searchBar.placeholder = [NSString stringWithFormat:@"共有 %d 位联系人", _cursor];
        
        static NSString *cellIdentifier = @"searchBarIdenty";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        [cell addSubview:searchBar];
        return cell;
    }
    
    static NSString *cellIdentifier = @"followingUserIdenty";    
    UITableViewFollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"UITableViewFollowingCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    cell.nameLabel.text = @"test";
    
    //最近联系人
    if (indexPath.section == 1) {
        
    //我关注的人
    } else if (indexPath.section >= 2) {
        NSString *sectionName = [sectionNames objectAtIndex:indexPath.section];
        NSArray *cellNames = [sectionItems objectForKey:sectionName];
        UIUser *user = [cellNames objectAtIndex:indexPath.row];
        cell.nameLabel.text = user.name;
        UIImage *avatarImage;
        NSString *avatar = [DataAdapter getMediaByUrl:user.avatar];
        if ([avatar length] == 0) {
            avatarImage = [UIImage imageNamed:user.sex? @"avatar-1":@"avatar-0"];
            [self registerAvatarImageFresh];
            [WeiboNetWork getOneMedia:user.avatarLarge];
        } else {
            avatarImage = [UIImage imageWithContentsOfFile:avatar];
        }
        cell.avatarImageView.image = avatarImage;
        
        NSArray *statusArray = [sectionItemsStatus objectForKey:sectionName];
        NSNumber *status = [statusArray objectAtIndex:indexPath.row];
        if ([status longValue]) {
            cell.flagImageView.image = [UIImage imageNamed:@"user_selected"];
        } else {
            cell.flagImageView.image = [UIImage imageNamed:@"user_un_selected"];
        }
    }

    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:sectionNames];
    if (sectionNames.count >= 2) {
        //[array replaceObjectAtIndex:0 withObject:@"◆"]; //查找
        [array replaceObjectAtIndex:0 withObject:@"@"]; //查找
        [array replaceObjectAtIndex:1 withObject:@"★"]; //最近
    }
    return array;
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
    return 16;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [searchBar resignFirstResponder];
    
    //
    
    NSString *sectionName = [sectionNames objectAtIndex:indexPath.section];
    NSMutableArray *statusArray = [sectionItemsStatus objectForKey:sectionName];
    NSNumber *status = [statusArray objectAtIndex:indexPath.row];
    [statusArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:!status.boolValue]];
    
    [tableView reloadData];
    
    return nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchBar resignFirstResponder];
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
