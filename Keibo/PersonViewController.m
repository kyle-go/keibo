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

@interface PersonViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tView;

@end

@implementation PersonViewController {
    UIUser *user;
    NSMutableArray *weiboData;
    NSMutableArray *weiboHeight;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我";
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar_me"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5 + [weiboData count];
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
            return cell;
        }
            break;
        case 1: {
            PersonBasicNumberCell *cell = [tableView dequeueReusableCellWithIdentifier:personBasicNumberIdentifier];
            return cell;
            
        }
            break;
        case 2: {
            PersonWeiboTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:personWeiboTypeIdentifier];
            [cell.textSlider setDefaultIndex:0 type:KTextSliderTypeAdjusted withTexts:@"全部", @"原创微博", nil];
            return cell;
        }
            break;
        default:
            break;
    }
    
    //simple weibo
    if (indexPath.row >= 3 && indexPath.row <= [weiboData count] + 2) {
        //
    }
    
    //查看所有xx条微博
    if (indexPath.row == [weiboData count] + 3) {
        CheckMoreWeibosCell *cell = [tableView dequeueReusableCellWithIdentifier:checkMoreWeiboIdentifier];
        cell.checkMore.layer.masksToBounds = YES;
        cell.checkMore.layer.cornerRadius = 4;
        return cell;
    }
    
    //微博相册
    if (indexPath.row == [weiboData count] + 4) {
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
            return 80.0;
            break;
        case 1:
            return 40.0;
            break;
        case 2:
            return 30.0;
            break;
        default:
            break;
    }
    //simple weibo
    if (indexPath.row >= 3 && indexPath.row <= [weiboData count] + 2) {
        //
    }
    //查看所有xx条微博
    if ((indexPath.row == [weiboData count] + 3)) {
        return 46.0;
    }
    //微博相册
    if (indexPath.row == [weiboData count] + 4) {
        return 80.0;
    }
    
    return 40.0;
}

@end
