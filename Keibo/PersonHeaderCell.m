//
//  PersonHeaderCell.m
//  Keibo
//
//  Created by kyle on 2/22/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "PersonHeaderCell.h"
#import "UIImageView+WebCache.h"
#import "WeiboImageCreator.h"

#define TextColor [[UIColor alloc] initWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1.0]

@interface PersonHeaderCell()

@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *addrLabel;

- (IBAction)detailClick:(id)sender;

@end

@implementation PersonHeaderCell

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

- (IBAction)detailClick:(id)sender {
    
}

- (void)setValuesWithUserInfo:(UIUser *)user
{
    //头像设置
    NSURL *url = [[NSURL alloc] initWithString:user.avatarLarge];
    UIImage *image = [UIImage imageNamed:user.sex? @"avatar-1":@"avatar-0"];
    [self.avatarImageView setImageWithURL:url placeholderImage:image];
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = CGRectGetWidth(self.avatarImageView.bounds)/2.0f;
    
    //昵称设置
    self.userNameLabel.text = user.name;
    
    //性别
    self.sexLabel.text = user.sex? @"女":@"男";
    
    //达人，蓝v，黄v标识
    if (user.isStar) {
        self.sexImageView.image = [WeiboImageCreator weiboImage:IMAGE_STAR];
    } else if (user.isVerified == 1) {
        self.sexImageView.image = [WeiboImageCreator weiboImage:IMAGE_YELLOW_V];
    } else if (user.isVerified == 2) {
        self.sexImageView.image = [WeiboImageCreator weiboImage:IMAGE_BLUE_V];
    } else {
        self.sexImageView.image = [WeiboImageCreator weiboImage:user.sex? IMAGE_GIRL:IMAGE_BOY];
    }
    
    CGFloat cellHeight = 78;
    
    //认证
    if ([user.verifiedReason length]) {
        UILabel *verifyLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, cellHeight, 1, 1)];
        verifyLabel.text = @"新浪认证：";
        verifyLabel.font = [UIFont boldSystemFontOfSize:15.0];
        verifyLabel.textColor = TextColor;
        [verifyLabel sizeToFit];
        
        UILabel *verifiedReason = [[UILabel alloc] initWithFrame:CGRectMake(15 + verifyLabel.frame.size.width + 4, cellHeight, 1, 1)];
        verifiedReason.text = user.verifiedReason;
        verifiedReason.font = [UIFont systemFontOfSize:15.0];
        [verifiedReason sizeToFit];
        verifiedReason.textColor = TextColor;
        
        [self addSubview:verifiedReason];
        [self addSubview:verifyLabel];
        
        //假装只有一行。。。
        cellHeight += verifyLabel.frame.size.height + 8;
    }
    
    //签名
    if (user.sign) {
        UILabel *sign = [[UILabel alloc] initWithFrame:CGRectMake(15, cellHeight, 1, 1)];
        sign.text = user.sign;
        sign.font = [UIFont systemFontOfSize:15.0];
        sign.textColor = TextColor;
        [sign sizeToFit];
        
        [self addSubview:sign];
        cellHeight += sign.frame.size.height + 8;
    }

    //博客
    if (user.blog) {
        UILabel *blog = [[UILabel alloc] initWithFrame:CGRectMake(15, cellHeight, 1, 1)];
        blog.text = user.blog;
        blog.font = [UIFont systemFontOfSize:14.0];
        blog.textColor = [[UIColor alloc] initWithRed:75.0/255.0 green:137.0/255.0 blue:208.0/255.0 alpha:1.0];
        [blog sizeToFit];
        
        [self addSubview:blog];
        cellHeight += blog.frame.size.height + 8;
    }
    cellHeight += 4;
    
    //return cellHeight;
}

+ (CGFloat)rightHeight:(UIUser *)user
{
    CGFloat cellHeight = 78.0;
    //认证
    if ([user.verifiedReason length]) {
        UILabel *verifyLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, cellHeight, 1, 1)];
        verifyLabel.text = @"新浪认证：";
        verifyLabel.font = [UIFont boldSystemFontOfSize:15.0];
        verifyLabel.textColor = TextColor;
        [verifyLabel sizeToFit];
        
        UILabel *verifiedReason = [[UILabel alloc] initWithFrame:CGRectMake(15 + verifyLabel.frame.size.width + 4, cellHeight, 1, 1)];
        verifiedReason.text = user.verifiedReason;
        verifiedReason.font = [UIFont systemFontOfSize:15.0];
        [verifiedReason sizeToFit];
        verifiedReason.textColor = TextColor;
        
        //假装只有一行。。。
        cellHeight += verifyLabel.frame.size.height + 8;
    }
    
    //签名
    if (user.sign) {
        UILabel *sign = [[UILabel alloc] initWithFrame:CGRectMake(15, cellHeight, 1, 1)];
        sign.text = user.sign;
        sign.font = [UIFont systemFontOfSize:15.0];
        sign.textColor = TextColor;
        [sign sizeToFit];
        
        cellHeight += sign.frame.size.height + 8;
    }
    
    //博客
    if (user.blog) {
        UILabel *blog = [[UILabel alloc] initWithFrame:CGRectMake(15, cellHeight, 1, 1)];
        blog.text = user.blog;
        blog.font = [UIFont systemFontOfSize:14.0];
        blog.textColor = [[UIColor alloc] initWithRed:75.0/255.0 green:137.0/255.0 blue:208.0/255.0 alpha:1.0];
        [blog sizeToFit];
        
        cellHeight += blog.frame.size.height + 8;
    }
    cellHeight += 4;
    
    return cellHeight;
}

@end
