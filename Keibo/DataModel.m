//
//  DataModel.m
//  Keibo
//
//  Created by kyle on 10/28/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "DataModel.h"

@implementation DataModel

#pragma mark ---------- private -----------------
//-(NSString *)dataFilePath
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"keibo.plist"];
//}

+ (NSString *)getAccessToken
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:@"accessToken"];
}

+ (void)saveAccessToken:(NSString *)accessToken
{
    if (!accessToken) {
        return;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:accessToken forKey:@"accessToken"];
    [ud synchronize];
}

@end
