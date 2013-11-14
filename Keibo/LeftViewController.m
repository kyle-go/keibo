//
//  LeftViewController.m
//  Keibo
//
//  Created by kyle on 13-10-31.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "LeftViewController.h"
#import "UIUser.h"
#import "Storage.h"
#import "WeiboNetWork.h"

@interface LeftViewController ()

@end

@implementation LeftViewController {
    NSArray *defaultSectionNames;
    NSArray *sectionNames;
    
    NSString *avatarUrl;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        defaultSectionNames = [[NSArray alloc] initWithObjects: @"全部微博", @"提到我", @"评论", @"私信", @"收藏", @"搜索", nil];
        sectionNames = [[NSArray alloc] initWithObjects:@"", @"分组", @"话题", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshLoginUser:) name:@"LeftView_LoginUser" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerAvatarImageFresh
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshAvatar:) name:@"WeiboNetWork_Media" object:nil];
}

- (void)freshAvatar:(NSNotification *)nofity
{
    NSDictionary *param = [nofity userInfo];
    NSString *url = [param objectForKey:@"url"];
    if ([url isEqualToString:avatarUrl]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        //刷新头像
        NSString *path = [param objectForKey:@"path"];
        self.avatarImageView.image = [UIImage imageWithContentsOfFile:path];
    }
}

- (void)freshLoginUser:(NSNotification *)notify
{
    NSDictionary *params = notify.userInfo;
    UIUser *user = [params objectForKey:@"user"];
    
    //刷新界面
    NSString *avatar = [[Storage storageInstance] getMediaByUrl:user.avatar];
    if ([avatar length] == 0) {
        avatarUrl = user.avatar;
        avatar = @"avatar-0";
        if (user.sex) {
            avatar = @"avatar-1";
        }
        [self registerAvatarImageFresh];
        [WeiboNetWork getOneMedia:user.avatar];
    }
    
    self.avatarImageView.image = [UIImage imageNamed:avatar];
    self.nameLabel.text = user.name;
    self.signLabel.text = user.sign;
    self.fanCount.text = [[NSString alloc] initWithFormat:@"粉丝:%d", user.fanCount];
    self.followingCount.text = [[NSString alloc] initWithFormat:@"关注:%d", user.followingCount ];
    self.weiboCount.text = [[NSString alloc] initWithFormat:@"微博:%d", user.weiboCount];
    
}

#pragma mark -- table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [defaultSectionNames count];
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 1;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionNames objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [defaultSectionNames objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"互粉微博";
    } else if (indexPath.section == 2) {
       cell.textLabel.text = @"热门话题";
    }
    
    return cell;
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
