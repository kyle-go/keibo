//
//  AFTextResponseSerializer.m
//  test
//
//  Created by kyle on 10/29/13.
//  Copyright (c) 2013 nad. All rights reserved.
//

#import "AFTextResponseSerializer.h"

@implementation AFTextResponseSerializer

+ (instancetype)serializer
{
    return [[self alloc] init];
}

- (instancetype)init
{
    if (self = [super init]) {
        self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"text/plain", nil];
    }
    return self;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if ([(NSError *)(*error) code] == NSURLErrorCannotDecodeContentData) {
            return nil;
        }
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
