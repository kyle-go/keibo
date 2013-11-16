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

@implementation WeiboTableCell {
    UIWeibo *cellData;
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
    if (self.webViewHeight == self.webView.scrollView.contentSize.height && btnRepost) {
        return;
    }
    
    self.webViewHeight = self.webView.scrollView.contentSize.height;
    self.webView.frame = CGRectMake(0, 50, 320, self.webViewHeight);
    
    //移动按钮位置
    NSString *textRepost = [[NSString alloc] initWithFormat:@"(%ld)", (long)self.repost];
    NSString *textComment = [[NSString alloc] initWithFormat:@"(%ld)", (long)self.comment];
    NSString *textLike = [[NSString alloc] initWithFormat:@"(%ld)", (long)self.like];
    
    [btnRepost removeFromSuperview];
    [btnComment removeFromSuperview];
    [btnLike removeFromSuperview];
    
    [self addSubview: btnRepost = [self createUIButton:CGRectMake(30, self.webViewHeight+50, 22+40, 22) title:textRepost]];
    [self addSubview: btnComment = [self createUIButton:CGRectMake(130, self.webViewHeight+50, 22+40, 22) title:textComment]];
    [self addSubview: btnLike = [self createUIButton:CGRectMake(230, self.webViewHeight+50, 22+40, 22) title:textLike]];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:cellData forKey:@"cell"];
    [param setObject:[[NSNumber alloc] initWithFloat:self.webViewHeight + 80.0] forKey:@"height"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"freshTableView" object:nil userInfo:param];
}

- (void)prepareForReuse
{
    NSLog(@"prepare For Reuse.");
}

- (void)updateWithWeiboData:(UIWeibo *)data
{
    cellData = data;

    [self.avatarImageView setImage:[UIImage imageNamed:@"avatar-0"]];
    self.nameLabel.text = data.name;
    self.dateLabel.text = [data.date description];
    self.comeFromLabel.text = data.feedComeFrom;
    
    self.repost = data.reposts;
    self.comment = data.comments;
    self.like = data.likes;

    //set webview content
    [self.webView stopLoading];
    self.webView.delegate = self;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.opaque = NO;
    
    NSString *htmlString = [KUnits weiboFormat:data.content repost:data.originWeiboId? data.originContent:nil reposter:data.originName];
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

@end
