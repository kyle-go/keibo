//
//  appInitialize.m
//  Keibo
//
//  Created by kyle on 13-11-14.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "appInitialize.h"
#import "NotificationCenter.h"
#import "Storage.h"

//define global variable instance.
NotificationCenter * notifyCenter;
Storage *storage;

@implementation appInitialize

+ (void)appInit
{
    notifyCenter = [NotificationCenter NCInstance];
    storage = [Storage storageInstance];
}

@end
