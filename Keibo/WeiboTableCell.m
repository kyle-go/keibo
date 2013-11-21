//
//  WeiboTableCell.m
//  Keibo
//
//  Created by kyle on 11/8/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "WeiboTableCell.h"
#import "UIWeibo.h"
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
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 2.0, 0.0, 0.0)];
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
        
        btnRepost = [self createUIButton:CGRectMake(30, self.webViewHeight+54, 22+40, 22) title:textRepost];
        btnComment = [self createUIButton:CGRectMake(130, self.webViewHeight+54, 22+40, 22) title:textComment];
        btnLike = [self createUIButton:CGRectMake(230, self.webViewHeight+54, 22+40, 22) title:textLike];
        
        [self addSubview: btnRepost];
        [self addSubview: btnComment];
        [self addSubview: btnLike];
        return;
    }
    
    self.webViewHeight = webView.frame.size.height;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[[NSNumber alloc] initWithLong:cellIndex] forKey:@"index"];
    [param setObject:[[NSNumber alloc] initWithFloat:self.webViewHeight + 80.0] forKey:@"height"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"freshTableView" object:nil userInfo:param];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)updateWithWeiboData:(UIWeibo *)data index:(NSInteger)index;
{
    cellIndex = index;
    NSString *avatarPath = [DataAdapter getMediaByUrl:data.avatarUrl];
    if ([avatarPath length] == 0) {
        self.avatarImageView.image = [UIImage imageNamed:data.sex? @"avatar-1":@"avatar-0"];
    } else {
        UIImage *image = [UIImage imageWithContentsOfFile:avatarPath];
        self.avatarImageView.image = image;
    }

    self.nameLabel.text = data.name;
    self.dateLabel.text = [data.date description];
    self.comeFromLabel.text = data.feedComeFrom;
    
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
