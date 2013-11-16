//
//  WeiboImageCreator.m
//  Keibo
//
//  Created by kyle on 11/16/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "WeiboImageCreator.h"

UIImage *bg_line;

@implementation WeiboImageCreator

+ (UIImage*)getSubImage:(CGRect)rect
{
    if (!bg_line) {
        bg_line = [UIImage imageNamed:@"bg_line"];
    }
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(bg_line.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}

+ (UIImage *)weiboImage:(IMAGE_TYPE)type
{
    CGRect rect = CGRectMake(0, 6, 0, 0);
    switch (type) {
        case IMAGE_BOY:
            rect.size.width = 12;
            rect.size.height = 12;
            break;
        case IMAGE_GIRL:
            rect.size.width = 12;
            rect.size.height = 12;
            rect.origin.x = 25;
            break;
        case IMAGE_YELLOW_V:
            rect.size.width = 16;
            rect.size.height = 14;
            rect.origin.x = 25*2;
            break;
        case IMAGE_BLUE_V:
            rect.size.width = 16;
            rect.size.height = 14;
            rect.origin.x = 25*3;
            break;
        case IMAGE_STAR:
            rect.size.width = 13;
            rect.size.height = 13;
            rect.origin.x = 25*5;
            break;
        default:
            return nil;
            break;
    }
    
    return [self getSubImage:rect];
}

@end
