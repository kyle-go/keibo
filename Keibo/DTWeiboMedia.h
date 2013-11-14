//
//  DTWeiboMedia.h
//  Keibo
//
//  Created by kyle on 13-11-14.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

enum DTWeiboMedia_Type {
    Type_Picture = 0,
    Type_Music = 1,
    Type_Movie = 2,
};

//DataBase Table WbMedia
@interface DTWeiboMedia : NSObject

@property (nonatomic, assign)long long weiboId;
@property (nonatomic, assign)NSInteger type;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, strong)NSString *url;

@end
