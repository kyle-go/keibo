//
//  LeftViewController.m
//  Keibo
//
//  Created by kyle on 13-10-31.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "LeftViewController.h"
#import "UIUser.h"
#import "DataAdapter.h"
#import "WeiboNetWork.h"
#import "WeiboImageCreator.h"

@interface LeftViewController ()

@end

@implementation LeftViewController {
    NSArray *sectionsName;
    NSArray *defaultSectionItemsName;
    NSMutableArray *friendSectionItemsName;
    
    NSString *avatarUrl;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        sectionsName = [[NSArray alloc] initWithObjects:@"", @"好友分组", nil];
        defaultSectionItemsName = [[NSArray alloc] initWithObjects: @"全部微博", @"消息", @"话题", @"收藏", @"搜索", nil];
        friendSectionItemsName = [[NSMutableArray alloc] initWithObjects:@"特别关注", @"互粉好友", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshLoginUser:) name:@"NotificationCenter_LoginUser" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerAvatarImageFresh
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshAvatar:) name:@"NotificationCenter_Media" object:nil];
}

- (void)freshAvatar:(NSNotification *)nofity
{
    NSDictionary *param = [nofity userInfo];
    NSString *url = [param objectForKey:@"url"];
    if ([url isEqualToString:avatarUrl]) {
        
        //刷新头像
        NSString *path = [param objectForKey:@"file"];
        self.avatarImageView.image = [UIImage imageWithContentsOfFile:path];
    }
}

- (void)freshLoginUser:(NSNotification *)notify
{
    NSDictionary *params = notify.userInfo;
    UIUser *user = [params objectForKey:@"User"];
    
    //刷新界面
    UIImage *avatarImage;
    NSString *avatar = [DataAdapter getMediaByUrl:user.avatarLarge];
    if ([avatar length] == 0) {
        avatarUrl = user.avatarLarge;
        avatarImage = [UIImage imageNamed:user.sex? @"avatar-1":@"avatar-0"];
        [self registerAvatarImageFresh];
        [WeiboNetWork getOneMedia:avatarUrl];
    } else {
        avatarImage = [UIImage imageWithContentsOfFile:avatar];
    }
                
    self.avatarImageView.image = avatarImage;
    self.sexImageView.image = [WeiboImageCreator weiboImage:user.sex?IMAGE_GIRL:IMAGE_BOY];
    self.nameLabel.text = user.name;
    [self.nameLabel sizeToFit];
    self.signLabel.text = user.sign;
    [self.signLabel sizeToFit];
    self.fanCount.text = [[NSString alloc] initWithFormat:@"粉丝:%ld", (long)user.fanCount];
    self.followingCount.text = [[NSString alloc] initWithFormat:@"关注:%ld", (long)user.followingCount ];
    self.weiboCount.text = [[NSString alloc] initWithFormat:@"微博:%ld", (long)user.weiboCount];
}

#pragma mark -- table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionsName count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [defaultSectionItemsName count];
    } else if (section == 1) {
        return [friendSectionItemsName count];
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionsName objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [defaultSectionItemsName objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [friendSectionItemsName objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

//设置section头部
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.001;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

@end
