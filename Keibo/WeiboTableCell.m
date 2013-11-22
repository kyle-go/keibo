//
//  WeiboTableCell.m
//  Keibo
//
//  Created by kyle on 11/8/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "WeiboTableCell.h"
#import "UIWeibo.h"
#import "WeiboImageCreator.h"
#import "Storage.h"
#import "KUnits.h"
#import "DataAdapter.h"

@implementation WeiboTableCell {
    NSInteger cellIndex;
    UIView *btnRepost;
    UIView *btnComment;
    UIView *btnLike;
}

//remember IndexpathsForVisibleCells
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)btnMoreAction:(id)sender {
    
}

- (UIButton *)createUIButton:(CGRect)rect title:(NSString *)title
{
    UIButton *button = [[UIButton alloc] initWithFrame:rect];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    [button setTitle:title forState:UIControlStateNormal];
    UIImage *image = [UIImage imageNamed:@"comments.png"];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-5.0, 2.0, 0.0, 0.0)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0.0, -5.0, 0.0, 0.0)];
    
    button.titleLabel.font = [UIFont systemFontOfSize:10];
    return button;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    
    if (self.webViewHeight == webView.frame.size.height) {
        //添加按钮并放置合适位置
        NSString *textRepost = [[NSString alloc] initWithFormat:@"(%ld)", (long)self.repost];
        NSString *textComment = [[NSString alloc] initWithFormat:@"(%ld)", (long)self.comment];
        NSString *textLike = [[NSString alloc] initWithFormat:@"(%ld)", (long)self.like];
        
        [btnRepost removeFromSuperview];
        [btnComment removeFromSuperview];
        [btnLike removeFromSuperview];
        
        btnRepost = [self createUIButton:CGRectMake(30, self.webViewHeight+45, 22+40, 22) title:textRepost];
        btnComment = [self createUIButton:CGRectMake(130, self.webViewHeight+45, 22+40, 22) title:textComment];
        btnLike = [self createUIButton:CGRectMake(230, self.webViewHeight+45, 22+40, 22) title:textLike];
        
        [self addSubview: btnRepost];
        [self addSubview: btnComment];
        [self addSubview: btnLike];
        return;
    }
    
    self.webViewHeight = webView.frame.size.height;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[[NSNumber alloc] initWithLong:cellIndex] forKey:@"index"];
    [param setObject:[[NSNumber alloc] initWithFloat:self.webViewHeight + 75.0] forKey:@"height"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"freshTableView" object:nil userInfo:param];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.nameLabel.text = @".";
    [self.nameLabel sizeToFit];
    self.starImageView.image = nil;
}

- (void)updateWithWeiboData:(UIWeibo *)data index:(NSInteger)index;
{
    cellIndex = index;
    
    //设置头像
    NSString *avatarPath = [DataAdapter getMediaByUrl:data.avatarUrl];
    if ([avatarPath length] == 0) {
        self.avatarImageView.image = [UIImage imageNamed:data.sex? @"avatar-1":@"avatar-0"];
    } else {
        UIImage *image = [UIImage imageWithContentsOfFile:avatarPath];
        self.avatarImageView.image = image;
    }

    //设置名字，自适应长度
    self.nameLabel.text = data.name;
    [self.nameLabel sizeToFit];
    
    //设置达人、认证
    if (data.star || data.verified) {
        if (data.star) {
            self.starImageView.image = [WeiboImageCreator weiboImage:IMAGE_STAR];
        }
        
        if (data.verified == 1) {
            self.starImageView.image = [WeiboImageCreator weiboImage:IMAGE_YELLOW_V];
        } else if(data.verified == 2) {
            self.starImageView.image = [WeiboImageCreator weiboImage:IMAGE_BLUE_V];
        } else {
            //...
        }
        
        //调整位置
        CGRect frame = self.starImageView.frame;
        frame.origin.x = 2 + self.nameLabel.frame.origin.x + self.nameLabel.frame.size.width;
        self.starImageView.frame = frame;
    }
    
    //设置时间
    static NSInteger type = 7;
    NSString *dateString = [KUnits getProperDateStringByDate:data.date type:&type];
    self.dateLabel.text = dateString;
    if (type <= 2) {
        UIColor *color = [[UIColor alloc] initWithRed:1.0 green:128.0/255.0 blue:0.0 alpha:1.0];
        [self.dateLabel setTextColor:color];
    } else {
        [self.dateLabel setTextColor:[UIColor darkGrayColor]];
    }
    [self.dateLabel sizeToFit];
    
    //设置微博来源
    CGRect frame = self.comeFromLabel.frame;
    frame.origin.x = 4 + self.dateLabel.frame.origin.x + self.dateLabel.frame.size.width;
    self.comeFromLabel.frame = frame;
    self.comeFromLabel.text = [[NSString alloc] initWithFormat:@"来自%@", data.feedComeFrom];
    
    
    self.repost = data.reposts;
    self.comment = data.comments;
    self.like = data.likes;
    
    //set webview content
    self.webView.delegate = self;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.opaque = NO;
    
    NSString *htmlString = [KUnits weiboFormat:data.content repost:data.originWeiboId? data.originContent:nil reposter:data.originName];
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

@end
