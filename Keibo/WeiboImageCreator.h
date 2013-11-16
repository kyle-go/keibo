//
//  WeiboImageCreator.h
//  Keibo
//
//  Created by kyle on 11/16/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum _IMAGE_TYPE
{
    IMAGE_GIRL = 0,
    IMAGE_BOY = 1,
    IMAGE_YELLOW_V = 2,
    IMAGE_BLUE_V = 3,
    IMAGE_STAR = 4,
}IMAGE_TYPE;

@interface WeiboImageCreator : NSObject

+ (UIImage *)weiboImage:(IMAGE_TYPE)type;

@end
