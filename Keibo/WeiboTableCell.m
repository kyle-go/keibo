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

NSMutableDictionary *htmlHeight;

@implementation WeiboTableCell {
    UIWeibo *cellData;
    NSString *html;
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
//- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.webView sizeToFit];
    
    CGSize mWebViewTextSize = [webView sizeThatFits:CGSizeMake(1.0f, 1.0f)];  // Pass about any size
    CGRect mWebViewFrame = webView.frame;
    mWebViewFrame.size.height = mWebViewTextSize.height;
    webView.frame = mWebViewFrame;
    assert(webView.frame.size.height == self.webView.scrollView.contentSize.height);
    
    assert(self.webView == webView);
    if (self.webViewHeight == self.webView.scrollView.contentSize.height && btnRepost) {
        return;
    }
    
    [btnRepost removeFromSuperview];
    [btnComment removeFromSuperview];
    [btnLike removeFromSuperview];
    
    self.webViewHeight = self.webView.scrollView.contentSize.height;
    self.webView.frame = CGRectMake(0, 50, 320, self.webViewHeight);
    
    //添加按钮并放置合适位置
    NSString *textRepost = [[NSString alloc] initWithFormat:@"(%ld)", (long)self.repost];
    NSString *textComment = [[NSString alloc] initWithFormat:@"(%ld)", (long)self.comment];
    NSString *textLike = [[NSString alloc] initWithFormat:@"(%ld)", (long)self.like];
    
    [self addSubview: btnRepost = [self createUIButton:CGRectMake(30, self.webViewHeight+50, 22+40, 22) title:textRepost]];
    [self addSubview: btnComment = [self createUIButton:CGRectMake(130, self.webViewHeight+50, 22+40, 22) title:textComment]];
    [self addSubview: btnLike = [self createUIButton:CGRectMake(230, self.webViewHeight+50, 22+40, 22) title:textLike]];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:cellData forKey:@"cell"];
    [param setObject:[[NSNumber alloc] initWithFloat:self.webViewHeight + 80.0] forKey:@"height"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"freshTableView" object:nil userInfo:param];
    [htmlHeight setObject:[[NSNumber alloc] initWithFloat:self.webViewHeight + 80.0] forKey:html];
    
    static int sss = 0;
    NSLog(@"ssssssssssss=%d", ++sss);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    NSLog(@"prepare For Reuse.");
}

- (void)updateWithWeiboData:(UIWeibo *)data
{
    if (htmlHeight == nil) {
        htmlHeight = [[NSMutableDictionary alloc] init];
    }
    
    cellData = data;

    [self.avatarImageView setImage:[UIImage imageNamed:@"avatar-0"]];
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
    //self.webView.suppressesIncrementalRendering = YES;
    
    NSString *htmlString = [KUnits weiboFormat:data.content repost:data.originWeiboId? data.originContent:nil reposter:data.originName];
    [self.webView loadHTMLString:htmlString baseURL:nil];
    id dicHeight = [htmlHeight objectForKey:htmlString];
    if (dicHeight) {
        self.webViewHeight = [dicHeight floatValue];
        self.webView.delegate = nil;
    }
    html = htmlString;
    
    static int load = 0;
    NSLog(@"Lllllllllllll=%d", ++load);
}

@end
