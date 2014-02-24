//
//  PersonViewController.m
//  Keibo
//
//  Created by kyle on 13-10-31.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "PersonViewController.h"
#import "PersonHeaderCell.h"
#import "PersonBasicNumberCell.h"
#import "PersonWeiboTypeCell.h"
#import "CheckMoreWeibosCell.h"
#import "AlbumCell.h"
#import "UIUser.h"
#import "UIWeibo.h"
#import "WeiboNetWork.h"
#import "DataAdapter.h"

@interface PersonViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tView;

@end

@implementation PersonViewController {
    NSString *_uid;
    UIUser *_user;
    NSMutableArray *_weiboData;
    NSMutableArray *_weiboHeight;
    
    CGFloat _headerCellHeight;
    UIActivityIndicatorView *_activeIndicator;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我";
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar_me"]];
        _headerCellHeight = 78.0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //注册观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetUserInfomation:) name:@"NotificationCenter_User" object:nil];
    
    //************本地缓存************
    //1.获取个人基本信息
    _user = [DataAdapter UserAdapter:_uid];
    //2.获取个人最新3条微博
    //TODO

    
    //************发起网络请求************
    //1.个人基本信息
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    [WeiboNetWork getUser:accessToken uid:_uid];
    //2.个人最新3条微博
    //TODO
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUserId:(NSString *)uid
{
    _uid = uid;
}

- (void)didGetUserInfomation:(NSNotification *)notify
{
    NSDictionary *params = notify.userInfo;
    UIUser *user = [params objectForKey:@"User"];
    if (![user.uid isEqualToString:_uid]) {
        return;
    }
    _user = user;
    [self.tView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5 + [_weiboData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *personHeaderIdentifier = @"personHeaderIdentifier";
    static NSString *personBasicNumberIdentifier = @"personBasicNumberIdentifier";
    static NSString *personWeiboTypeIdentifier = @"PersonWeiboTypeIdentifier";
    static NSString *weiboSimpleIdentifier = @"weiboSimpleIndentifier";
    static NSString *checkMoreWeiboIdentifier = @"checkMoreWeibosIndentifier";
    static NSString *albumIdentifier = @"albumIdentifier";
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [tableView registerNib:[UINib nibWithNibName:@"PersonHeaderCell" bundle:nil] forCellReuseIdentifier:personHeaderIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"PersonBasicNumberCell" bundle:nil] forCellReuseIdentifier:personBasicNumberIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"PersonWeiboTypeCell" bundle:nil] forCellReuseIdentifier:personWeiboTypeIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"WeiboSimpleCell" bundle:nil] forCellReuseIdentifier:weiboSimpleIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"CheckMoreWeibosCell" bundle:nil] forCellReuseIdentifier:checkMoreWeiboIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"AlbumCell" bundle:nil] forCellReuseIdentifier:albumIdentifier];
    });
    
    switch (indexPath.row) {
        case 0: {
            PersonHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:personHeaderIdentifier];
            [cell setValuesWithUserInfo:_user];
            if (![_user.uid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUid]]) {
                cell.detailInfo.hidden = YES;
            } else {
                [cell.detailInfo addTarget:self action:@selector(detailInfo) forControlEvents:UIControlEventTouchUpInside];
            }
            
            cell.avatarImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailInfo)];
            [cell.avatarImageView addGestureRecognizer:tapGestureRecognizer];
            
            return cell;
        }
            break;
        case 1: {
            PersonBasicNumberCell *cell = [tableView dequeueReusableCellWithIdentifier:personBasicNumberIdentifier];
            [cell setWeibosNumber:_user.weiboCount followings:_user.followingCount fans:_user.fanCount];
            if (![_user.uid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUid]]) {
                cell.moreInfo.hidden = YES;
            } else {
                [cell.moreInfo addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        }
            break;
        case 2: {
            PersonWeiboTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:personWeiboTypeIdentifier];
            _activeIndicator = cell.activeIndicator;
            _activeIndicator.hidden = YES;
            [cell.textSlider setDefaultIndex:0 type:KTextSliderTypeAdjusted withTexts:@"全部", @"原创微博", nil];
            return cell;
        }
            break;
        default:
            break;
    }
    
    //simple weibo
    if (indexPath.row >= 3 && indexPath.row <= [_weiboData count] + 2) {
        //
    }
    
    //查看所有xx条微博
    if (indexPath.row == [_weiboData count] + 3) {
        CheckMoreWeibosCell *cell = [tableView dequeueReusableCellWithIdentifier:checkMoreWeiboIdentifier];
        cell.checkMore.layer.masksToBounds = YES;
        cell.checkMore.layer.cornerRadius = 4;
        return cell;
    }
    
    //微博相册
    if (indexPath.row == [_weiboData count] + 4) {
        AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:albumIdentifier];
        return cell;
    }
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

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
    switch (indexPath.row) {
        case 0:
            return [PersonHeaderCell rightHeight:_user];
            break;
        case 1:
            return 44.0;
            break;
        case 2:
            return 44.0;
            break;
        default:
            break;
    }
    //simple weibo
    if (indexPath.row >= 3 && indexPath.row <= [_weiboData count] + 2) {
        //
    }
    //查看所有xx条微博
    if ((indexPath.row == [_weiboData count] + 3)) {
        return 46.0;
    }
    //微博相册
    if (indexPath.row == [_weiboData count] + 4) {
        return 80.0;
    }
    
    return 40.0;
}


#pragma mark -  头部 “详细“ 按钮
- (void)detailInfo
{
    UIActionSheet  *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"更换头像", @"编辑个人资料", @"登出", nil];
    actionSheet.destructiveButtonIndex = 2;
    [actionSheet showInView:self.navigationController.view];
}


#pragma mark - 微博，关注，粉丝按钮 栏目中  “更多“ 按钮
- (void)moreInfo
{
    UIActionSheet  *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"我的收藏", @"分组设置", nil];
    [actionSheet showInView:self.navigationController.view];
}

@end
