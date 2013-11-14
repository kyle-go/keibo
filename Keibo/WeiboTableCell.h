//
//  WeiboTableCell.h
//  Keibo
//
//  Created by kyle on 11/8/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UIWeibo;

@interface WeiboTableCell : UITableViewCell <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *comeFromLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (assign, nonatomic)NSInteger repost;
@property (assign, nonatomic)NSInteger comment;
@property (assign, nonatomic)NSInteger like;

@property (assign, nonatomic) CGFloat webViewHeight;
- (IBAction)btnMoreAction:(id)sender;

- (void)updateWithWeiboData:(UIWeibo *)data;

@end
