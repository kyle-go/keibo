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

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat height = self.webView.scrollView.contentSize.height;
    self.webView.frame = CGRectMake(0, 57, 320, height);
    
    //移动按钮位置
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
    self.repostLabel.text = [[NSString alloc] initWithFormat:@"%d", data.reposts];
    self.commentLabel.text = [[NSString alloc] initWithFormat:@"%d", data.comments];
    self.likeLabel.text = [[NSString alloc] initWithFormat:@"%d", data.likes];

    //set webview content
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    NSString *temp_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/weibo.html"];
    NSData *tmp_data = [[NSFileManager defaultManager] contentsAtPath:temp_path];
    NSString *webContent = [[NSString alloc] initWithData:tmp_data encoding:NSUTF8StringEncoding];
    [self.webView loadHTMLString:webContent baseURL:nil];
}

@end
