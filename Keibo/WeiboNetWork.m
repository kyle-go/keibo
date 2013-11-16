//
//  WeiboNetWork.m
//  Keibo
//
//  Created by kyle on 13-11-13.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "WeiboNetWork.h"
#import "AFNetworking.h"
#import "AFTextResponseSerializer.h"
#import "DTUser.h"
#import "DTWeibo.h"
#import "DTWeiboMedia.h"
#import "KUnits.h"

@implementation WeiboNetWork

#pragma mark ------------------- 私有接口 -------------------
+ (DTWeibo *)getWeiboByJson:(NSDictionary *)json
{
    //debugLog(@"%@", json);
    
    //解析数据
    DTWeibo *weibo = [[DTWeibo alloc] init];
    weibo.weiboId = [[json objectForKey:@"id"] longLongValue];
    weibo.date = [KUnits getNSDateByDateString:[json objectForKey:@"created_at"]];
    weibo.source = [KUnits getWeiboSourceText:[json objectForKey:@"source"]];
    
    NSDictionary *jsonUser = [json objectForKey:@"user"];
    DTUser *user = [self getDTUserByJson:jsonUser];
    weibo.owner = user.uid;
    
    NSDictionary *visiable = [json objectForKey:@"visible"];
    weibo.visible = [[visiable objectForKey:@"type"] intValue];
    if (weibo.visible == 2) {
        weibo.visible *= 10000;
        weibo.visible += [[visiable objectForKey:@"list_id"] intValue];
    }
    weibo.content = [json objectForKey:@"text"];
    weibo.repostCount = [[json objectForKey:@"reposts_count"] intValue];
    weibo.commentCount = [[json objectForKey:@"comments_count"] intValue];
    weibo.likeCount = [[json objectForKey:@"attitudes_count"] intValue];
    weibo.favorite = [[json objectForKey:@"favorited"] intValue];
    
    NSDictionary *repost= [json objectForKey:@"retweeted_status"];
    weibo.isRepost = repost? 1:0;
    if (weibo.isRepost) {
        weibo.picture = 0;
        weibo.originalWeiboId = [[repost objectForKey:@"idstr"] longLongValue];
        NSDictionary *pics = [repost objectForKey:@"pic_urls"];
        if ([pics count] == 0) {
            weibo.originalWeiboPicture = 0;
        } else {
            weibo.originalWeiboPicture = 1;
        }
        jsonUser = [repost objectForKey:@"user"];
        if (jsonUser) {
            user = [self getDTUserByJson:jsonUser];
            weibo.originalOwner = user.uid;
            weibo.originalWeiboContent = [repost objectForKey:@"text"];
        }
    } else {
        NSDictionary *pics = [json objectForKey:@"pic_urls"];
        if ([pics count] == 0) {
            weibo.picture = 0;
        } else {
            weibo.picture = 1;
            
            int index = 0;
            for (NSDictionary *each in pics) {
                NSString *url = [each objectForKey:@"thumbnail_pic"];
                DTWeiboMedia *media = [[DTWeiboMedia alloc] init];
                media.weiboId = weibo.weiboId;
                media.type = Type_Picture;
                media.index = index++;
                media.url = url;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboNetWork_WbMedia" object:nil userInfo:@{@"WbMedia": media}];
            }
        }
    }
    
    //TODO: 这个要改
    weibo.isIndex = 1;
    
    return weibo;
}

+ (void)getLoginUserWeibos:(NSString *)accessToken since:(NSString *)since_id max:(NSString *)max_id notify:(NSString *)notify
{
    void (^success) (AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSError *error;
        NSDictionary *json;
        if ([responseObject isKindOfClass:[NSString class]]) {
            NSData *data = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        } else {
            json = [responseObject objectForKey:@"statuses"];
        }
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *each in json) {
            DTWeibo *weibo = [WeiboNetWork getWeiboByJson:each];
            if (weibo.isRepost) {
                [WeiboNetWork getWeibo:accessToken weiboId:weibo.originalWeiboId];
            }
            [array addObject:weibo];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboNetWork_LoginUserWeibos" object:nil userInfo:@{@"type": notify, @"array":array}];
    };
    
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"get Weibo Error: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboNetWork_LoginUserWeibos" object:nil];
    };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager setResponseSerializer:[AFTextResponseSerializer serializer]];
    NSDictionary *params = @{@"access_token":accessToken, @"trim_user":@"0", @"count":kWeiboCountString, @"since_id":@"0", @"max_id":@"0"};
    if ([since_id length] > 0) {
        [params setValue:since_id forKey:@"since_id"];
    }
    if ([max_id length] > 0) {
        [params setValue:max_id forKey:@"max_id"];
    }
    [manager GET:@"https://api.weibo.com/2/statuses/friends_timeline.json" parameters:params success:success failure:failure];
}

+ (DTUser *)getDTUserByJson:(NSDictionary *)json
{
    //解析数据
    DTUser *user = [[DTUser alloc] init];
    user.uid = [json objectForKey:@"idstr"];
    user.name = [json objectForKey:@"screen_name"];
    user.nickName = [json objectForKey:@"remark"];
    user.avatar = [json objectForKey:@"profile_image_url"];
    user.avatarLarge = [json objectForKey:@"avatar_large"];
    user.address = [json objectForKey:@"location"];
    user.sign = [json objectForKey:@"description"];
    user.blog = [json objectForKey:@"url"];
    user.sex = [[json objectForKey:@"gender"] isEqualToString:@"m"]? 0:1;
    user.weiboCount = [[json objectForKey:@"statuses_count"] intValue];
    user.fanCount = [[json objectForKey:@"followers_count"] intValue];
    user.followingCount = [[json objectForKey:@"friends_count"] intValue];
    user.verified = [[json objectForKey:@"verified"] intValue];
    user.verifiedReason = [json objectForKey:@"verified_reason"];
    int verified_type = [[json objectForKey:@"verified_type"] intValue];
    if (verified_type == 2) {
        user.verified = 2;
    }
    user.star = (verified_type == 200 || verified_type == 220)? 1:0; //官方说了，这个子段为200或者220都是达人
    user.weiboMember = 0; //官方说了，这个会员接口现在获取不到（2013-2-1）
    user.following = [[json objectForKey:@"following"] intValue];
    user.followMe = [[json objectForKey:@"follow_me"] intValue];
    user.allowAllComment = [[json objectForKey:@"allow_all_comment"] intValue];
    user.allowAllMsg = [[json objectForKey:@"allow_all_act_msg"] intValue];
    user.biFollowCount = [[json objectForKey:@"bi_followers_count"] intValue];
    
    //TODO: -------- for test ------
    if (user.verified && user.star) {
        NSLog(@"达人和v是不能共存的！！！---");
        abort();
    }
    
    NSDictionary *jsonWeibo = [json objectForKey:@"status"];
    if (jsonWeibo) {
        user.lastMyWeiboId = [[jsonWeibo objectForKey:@"id"] longLongValue];
        //[WeiboNetWork getWeibo:accessToken weiboId:user.lastMyWeiboId];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboNetWork_User" object:nil userInfo:@{@"User": user}];
    
    return user;
}


#pragma mark ------------------------------ 网络请求 ----------------------
//获取登录request
+ (NSURLRequest *)loginRequest
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            kAppKey,                         @"client_id",       //申请的appkey
                            kRedirectUri,                    @"redirect_uri",    //申请时的重定向地址
                            @"mobile",                       @"display",         //web页面的显示方式
                            @"all",                          @"scope",
                            @"true",                         @"forcelogin",
                            nil];
	
	NSURL *url = [KUnits generateURL:@"https://open.weibo.cn/oauth2/authorize" params:params];
    return [[NSURLRequest alloc]initWithURL:url];
}

+ (void)checkAccessToken:(NSString *)accessToken
{
    //获取token是否过期成功回调
    void (^success_callback) (AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSError *error;
        NSData *data = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSNumber *expire = [json objectForKey:@"expire_in"];
        
        //已经过期则重新认证
        if ([expire intValue] <= 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboNetWork_Login" object:nil];
        } else {
            NSNumber *uid = [json objectForKey:@"uid"];
            NSDictionary *params = @{@"access_token":accessToken, @"uid":[[NSString alloc] initWithFormat:@"%lld", [uid longLongValue]]};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboNetWork_Login" object:nil userInfo:params];
        }
    };
    
    //获取token是否过期失败回调
    void (^failure_callback)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"checkAccessToken Error: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboNetWork_Login" object:nil];
    };
    
    //判断token是否过期POST请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFTextResponseSerializer serializer]];
    [manager POST:@"https://api.weibo.com/oauth2/get_token_info" parameters:@{@"access_token":accessToken} success:success_callback failure:failure_callback];
}

+ (void)getAccessTokenByCode:(NSString *)code
{
    void (^success_callback) (AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSError *error;
        NSData *data = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSNumber *expire = [json objectForKey:@"expires_in"];
        
        //已经过期则重新认证
        if ([expire intValue] <= 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboNetWork_Login" object:nil];
            return;
        }
        
        NSString *accessToken = [json objectForKey:@"access_token"];
        NSString *uid = [json objectForKey:@"uid"];
        NSDictionary *params = @{@"access_token":accessToken, @"uid":uid};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboNetWork_Login" object:nil userInfo:params];
    };
    
    void (^failure_callback)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"getAccessTokenByCode Error: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboNetWork_Login" object:nil];
    };
    
    //判断token是否过期POST请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFTextResponseSerializer serializer]];
    NSDictionary *params = @{@"client_id":kAppKey, @"client_secret":kAppSecret, @"grant_type":@"authorization_code", @"code":code, @"redirect_uri":kRedirectUri};
    [manager POST:@"https://api.weibo.com/oauth2/access_token" parameters:params success:success_callback failure:failure_callback];
}

+ (void)getUser:(NSString *)accessToken uid:(NSString *)uid
{
    void (^success) (AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSError *error;
        NSDictionary *json;
        if ([responseObject isKindOfClass:[NSString class]]) {
            NSData *data = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        } else {
            json = responseObject;
        }
        
        [self getDTUserByJson:json];
    };
    
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"get User Error: %@", error);
    };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager setResponseSerializer:[AFTextResponseSerializer serializer]];
    NSDictionary *params = @{@"access_token":accessToken, @"uid":uid};
    [manager GET:@"https://api.weibo.com/2/users/show.json" parameters:params success:success failure:failure];
}

+ (void)getWeibo:(NSString *)accessToken weiboId:(long long)weiboId
{
    void (^success) (AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSError *error;
        NSDictionary *json;
        if ([responseObject isKindOfClass:[NSString class]]) {
            NSData *data = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        } else {
            json = responseObject;
        }
        
        DTWeibo *weibo = [WeiboNetWork getWeiboByJson:json];
        if (weibo) {
            if (weibo.isRepost) {
                [WeiboNetWork getWeibo:accessToken weiboId:weibo.originalWeiboId];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboNetWork_OneWeibo" object:nil userInfo:@{@"Weibo": weibo}];
        }
    };
    
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"get Weibo Error: %@", error);
    };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager setResponseSerializer:[AFTextResponseSerializer serializer]];
    NSDictionary *params = @{@"access_token":accessToken, @"id":[[NSString alloc] initWithFormat:@"%lld", weiboId]};
    [manager GET:@"https://api.weibo.com/2/statuses/show.json" parameters:params success:success failure:failure];
}

//批量获取最新微博，只有本地列表为空时才调用，覆盖当前用户weibo表，默认kWeiboCount条
+ (void)getLoginUserWeibos:(NSString *)accessToken
{
    [WeiboNetWork getLoginUserWeibos:accessToken since:nil max:nil notify:@"latest"];
}

//批量获取比since_id更新的微博，默认最多为kWeiboCount条，如果实际获取条数＝kWeiboCount则覆盖当前用户weibo表
+ (void)getLoginUserWeibos:(NSString *)accessToken since:(NSString *)since_id
{
    [WeiboNetWork getLoginUserWeibos:accessToken since:since_id max:nil notify:@"since"];
}

//批量获取比max_id更旧的微博，默认每次为kWeiboCount条，添加到当前用户weibo表
+ (void)getLoginUserWeibos:(NSString *)accessToken max:(NSString *)max_id
{
    [WeiboNetWork getLoginUserWeibos:accessToken since:nil max:max_id notify:@"max"];
}

//下载一个媒体(图片,音乐，视频）
+ (void)getOneMedia:(NSString *)url
{
    if ([url length] == 0) {
        abort();
    }
    
    NSString *uuid = [KUnits generateUuidString];
    //从网络上下载此文件
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *filePath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:kMedia];
        NSString *file = [[NSString alloc] initWithFormat:@"%@/%@", filePath, uuid];
        return [NSURL fileURLWithPath:file isDirectory:NO];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboNetWork_Media" object:nil
            userInfo:@{@"url": url, @"path": [filePath path]}];
        }
    }];
    [downloadTask resume];
}

@end
