//
//  DTWeiboMedia.h
//  Keibo
//
//  Created by kyle on 13-11-14.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

//DataBase Table WbMedia
@interface DTWeiboMedia : NSObject

@property (nonatomic, assign)long long weiboId;
@property (nonatomic, assign)NSInteger type;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, strong)NSString *url;

@end
