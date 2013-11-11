//
//  WeiboTableCell.m
//  Keibo
//
//  Created by kyle on 11/8/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "WeiboTableCell.h"
#import "WeiboCellData.h"
#import "DataModel.h"

@implementation WeiboTableCell

//remember IndexpathsForVisibleCells

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
    self.webViewHeight = self.webView.scrollView.contentSize.height;
    self.webView.frame = CGRectMake(0, 57, 320, self.webViewHeight);
    
    //移动按钮位置
    NSString *textRepost = [[NSString alloc] initWithFormat:@"(%d)", self.repost];
    NSString *textComment = [[NSString alloc] initWithFormat:@"(%d)", self.comment];
    NSString *textLike = [[NSString alloc] initWithFormat:@"(%d)", self.like];
    
    [self addSubview:[self createUIButton:CGRectMake(30, self.webViewHeight+60, 22+40, 22) title:textRepost]];
    [self addSubview:[self createUIButton:CGRectMake(130, self.webViewHeight+60, 22+40, 22) title:textComment]];
    [self addSubview:[self createUIButton:CGRectMake(230, self.webViewHeight+60, 22+40, 22) title:textLike]];
}

- (void)updateWithWeiboData:(WeiboCellData *)data
{
    DataModel *model = [DataModel DMInstance];
    NSString *localFile = [model translateUrlToLocalPath:data.avatarUrl notificationName:nil customObj:nil];
    
    if ([localFile length] == 0) {
        [self.avatarImageView setImage:[UIImage imageNamed:@"avatar-0"]];
    } else {
        [self.avatarImageView setImage:[UIImage imageNamed:localFile]];
    }
    
    self.nameLabel.text = data.name;
    self.dateLabel.text = [data.date description];
    self.comeFromLabel.text = data.feedComeFrom;
    
    self.repost = data.reposts;
    self.comment = data.comments;
    self.like = data.likes;

    //set webview content
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.opaque = NO;
    NSString *temp_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/weibo.html"];
    NSData *tmp_data = [[NSFileManager defaultManager] contentsAtPath:temp_path];
    NSString *webContent = [[NSString alloc] initWithData:tmp_data encoding:NSUTF8StringEncoding];
    [self.webView loadHTMLString:webContent baseURL:nil];
}

@end
