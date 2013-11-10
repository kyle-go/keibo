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
    
    //self.webView
}

@end
