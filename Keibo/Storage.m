//
//  DataModel.m
//  Keibo
//
//  Created by kyle on 10/28/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "Storage.h"
#import "KUnits.h"
#import "AFNetworking.h"
#import "FMDatabase.h"
#import "DTUser.h"
#import "DTWeibo.h"
#import "DTWeiboMedia.h"

@implementation Storage {
    FMDatabase *db;
    NSString *ownerId;
}

+ (instancetype)storageInstance
{
    static id instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        //创建media文件夹
        NSString *imagesPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:kMedia];
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    return self;
}

//根据当前帐号id，初始化数据库
- (void)initStorageWithUId:(NSString *)uid
{
    //检查参数
    if ([uid length] == 0) {
        NSLog(@"initStorage uid = nil.");
        abort();
        return;
    }
    
    //用uid初始化数据库
    NSString *dbFile = [PATH_OF_DOCUMENT stringByAppendingPathComponent:uid];
    dbFile = [dbFile stringByAppendingString:@"_v1"]; //for v1 database
    
    db = [FMDatabase databaseWithPath:dbFile];
    if (!db) {
        NSLog(@"FMDatabase databaseWithPath failed.");
        abort();
    }
    if (![db open]) {
        NSLog(@"FMDatabase open failed.");
        abort();
    }
    
    //保存用户名
    ownerId = uid;
    
    //--------------------------------------------- 创建各种表 ---------------------------------------------------------
    //创建用户信息表(User) --- 记录用户一些信息，包括自己
    //uid, 名称，昵称，头像url，大头像url，性别，归属地，微博数，粉丝数，关注人数，签名，是否加V，加v原因，是否达人，是否会员，最新一条微博id，是否正在关注,
    //uid, name, nickName，avatar，avatarLarge,sex,address,weiboCount,fanCount，followingCount，sign，verified，verifiedReason，star,weiboMember，lastMyWeiboId, following，blog
    //是否此用户正在关注我, 是否所有人可以发私信，是否所有人可以评论, 互粉数
    //followMe，allowAllMsg，allowAllComment, biFollowerCount
    NSString *sql = @"CREATE TABLE IF NOT EXISTS 'User' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'uid' VARCHAR(16), 'name' VARCHAR(30), 'nickName' VARCHAR(30), 'avatar' VARCHAR(512), 'avatarLarge' VARCHAR(512), 'sex' INTEGER, 'address' VARCHAR(128), 'weiboCount' INTEGER, 'fanCount' INTEGER, 'followingCount' INTEGER, 'sign' VARCHAR(70), 'verified' INTEGER, 'verifiedReason' VARCHAR(128), 'star' INTEGER, 'weiboMember' INTEGER, 'lastMyWeiboId' BIGINTEGER, 'following' INTEGER, 'followMe' INTEGER, 'allowAllMsg' INTEGER, 'allowAllComment' INTEGER, 'biFollowCount' INTEGER, 'blog' VARCHAR(128))";
    if (![db executeUpdate:sql]) {
        NSLog(@"Create User table failed. error=%@", [db lastError]);
        abort();
    }
    
    //我最近@过的用户，最多存10条记录
    sql = @"CREATE TABLE IF NOT EXISTS 'LatestUser' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'uid' VARCHAR(16), 'name' VARCHAR(30), 'nickName' VARCHAR(30), 'avatar' VARCHAR(512), 'avatarLarge' VARCHAR(512), 'sex' INTEGER, 'address' VARCHAR(128), 'weiboCount' INTEGER, 'fanCount' INTEGER, 'followingCount' INTEGER, 'sign' VARCHAR(70), 'verified' INTEGER, 'verifiedReason' VARCHAR(128), 'star' INTEGER, 'weiboMember' INTEGER, 'lastMyWeiboId' BIGINTEGER, 'following' INTEGER, 'followMe' INTEGER, 'allowAllMsg' INTEGER, 'allowAllComment' INTEGER, 'biFollowCount' INTEGER, 'blog' VARCHAR(128), 'date' DATE)";
    if (![db executeUpdate:sql]) {
        NSLog(@"Create User table failed. error=%@", [db lastError]);
        abort();
    }
    
    //微博表(Weibo) --- 微博表
    //微博唯一Id，创建时间，所属人，来源，可见性，内容, 转发数，评论数，赞数，收藏，有图片
    //weiboId，date, owner，source，visible，content, repostCount, commentCount, likeCount, favorite，picture
    //是否转发，原转发微博id，原微博创建者,原微博内容，是否有图片
    //isRepost，originalWeiboId,originalOwner,originalWeiboContent，originalWeiboPicture
    
    //0：普通微博，1：私密微博，3：指定分组微博，4：密友微博；list_id为分组的组号
    sql = @"CREATE TABLE IF NOT EXISTS 'Weibo' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'weiboId' BITINTEGER, 'date' DATE, 'owner' VARCHAR(16), 'source' VARCHAR(32), 'visible' INTEGER, 'content' VARCHAR(160), 'repostCount' INTEGER, 'commentCount' INTEGER, 'likeCount' INTEGER, 'favorite' INTEGER, 'picture' INTEGER, 'isRepost' INTEGER, 'originalWeiboId' BIGINTEGER, 'originalOwner' VARCHAR(16), 'originalWeiboContent' VARCHAR(160), 'originalWeiboPicture' INTEGER, 'isIndexWeibo' INTEGER)";
    if (![db executeUpdate:sql]) {
        NSLog(@"Create Weibo table failed. error=%@", [db lastError]);
        abort();
    }
    
    //微博资源表（WbMedia）
    //微博唯一Id，类型（图片，音乐，视频,目前只有图片这一种），资源序号，URL地址
    sql = @"CREATE TABLE IF NOT EXISTS 'WbMedia' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'weiboId' BITINTEGER, 'type' INTEGER, 'index' INTEGER, 'url' VARCHAR(512))";
    if (![db executeUpdate:sql]) {
        NSLog(@"Create WbMedia table failed. error=%@", [db lastError]);
        abort();
    }
    
    //多媒体库(Media) --- 多媒体资源url跟本地路径关系
    //多媒体url，本地全路径（文件名是uuid随机生存）
    //url，path
    sql = @"CREATE TABLE IF NOT EXISTS 'Media' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'url' VARCHAR(512), 'file' VARCHAR(260))";
    if (![db executeUpdate:sql]) {
        NSLog(@"Create Media table failed. error=%@", [db lastError]);
        abort();
    }
}

//添加/更新一条用户数据
- (void)addUser:(DTUser *)user
{
    NSString *sql = @"SELECT * FROM User WHERE uid=(?)";
    FMResultSet *fs = [db executeQuery:sql, user.uid];
    if ([fs next]) {
        sql = @"DELETE FROM User WHERE uid=(?)";
        [db executeUpdate:sql, user.uid];
    }
    
    //插入一条数据
    sql = @"INSERT INTO User (uid,name,nickName,avatar,avatarLarge,sex,address,weiboCount,fanCount,followingCount,sign,verified,verifiedReason,star,weiboMember,lastMyWeiboId,following,followMe,allowAllMsg,allowAllComment,biFollowCount,blog) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    BOOL rs = [db executeUpdate:sql,
               user.uid,
               user.name,
               user.nickName,
               user.avatar,
               user.avatarLarge,
               [[NSNumber alloc] initWithLong:user.sex],
               user.address,
               [[NSNumber alloc] initWithLong:user.weiboCount],
               [[NSNumber alloc] initWithLong:user.fanCount],
               [[NSNumber alloc] initWithLong:user.followingCount],
               user.sign,
               [[NSNumber alloc] initWithLong:user.verified],
               user.verifiedReason,
               [[NSNumber alloc] initWithLong:user.star],
               [[NSNumber alloc] initWithLong:user.weiboMember],
               [[NSNumber alloc] initWithLongLong:user.lastMyWeiboId],
               [[NSNumber alloc] initWithLong:user.following],
               [[NSNumber alloc] initWithLong:user.followMe],
               [[NSNumber alloc] initWithLong:user.allowAllMsg],
               [[NSNumber alloc] initWithLong:user.allowAllComment],
               [[NSNumber alloc] initWithLong:user.biFollowCount],
               user.blog];
    if (!rs) {
        NSLog(@"Storage addUser failed. error=%@", [db lastError]);
    }
}

//添加/更新一条微博
- (void)addWeibo:(DTWeibo *)weibo
{
    NSString *sql = @"SELECT * FROM Weibo WHERE weiboId=(?)";
    FMResultSet *fs = [db executeQuery:sql, [[NSNumber alloc]initWithLongLong:weibo.weiboId]];
    if ([fs next]) {
        sql = @"DELETE FROM Weibo WHERE weiboId=(?)";
        [db executeUpdate:sql, [[NSNumber alloc]initWithLongLong:weibo.weiboId]];
    }
    
    sql = @"INSERT INTO weibo (weiboId,date,owner,source,visible,content,repostCount,commentCount,likeCount,favorite,picture,isRepost,originalWeiboId,originalOwner,originalWeiboContent,originalWeiboPicture,isIndexWeibo) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    BOOL rs = [db executeUpdate:sql,
               [[NSNumber alloc] initWithLongLong:weibo.weiboId],
               weibo.date,
               weibo.owner,
               weibo.source,
               [[NSNumber alloc] initWithLong:weibo.visible],
               weibo.content,
               [[NSNumber alloc] initWithLong:weibo.repostCount],
               [[NSNumber alloc] initWithLong:weibo.commentCount],
               [[NSNumber alloc] initWithLong:weibo.likeCount],
               [[NSNumber alloc] initWithLong:weibo.favorite],
               [[NSNumber alloc] initWithLong:weibo.picture],
               [[NSNumber alloc] initWithLong:weibo.isRepost],
               [[NSNumber alloc] initWithLongLong:weibo.originalWeiboId],
               weibo.originalOwner,
               weibo.originalWeiboContent,
               [[NSNumber alloc] initWithLong:weibo.originalWeiboPicture],
               [[NSNumber alloc] initWithLong:weibo.isIndex]];
    if (!rs) {
        NSLog(@"Storage addWeibo failed. error=%@", [db lastError]);
    }
}

//批量添加weibo
- (void)addWeibos:(NSArray *)weibos
{
    for (DTWeibo *wb in weibos) {
        [self addWeibo:wb];
    }
}

//根据uid批量删除非Index weibo
- (void)deleteWeibosByUid:(NSString *)uid
{
    NSString *sql = @"DELETE FROM Weibo WHERE owner=(?) AND isIndexWeibo='0'";
    BOOL rs = [db executeUpdate:sql, uid];
    if (!rs) {
        NSLog(@"Storage deleteWeibosByUid failed. error=%@", [db lastError]);
    }
}

//批量删除index微博
- (void)deleteIndexWeibos
{
    NSString *sql = @"DELETE FROM Weibo WHERE isIndexWeibo='1'";
    BOOL rs = [db executeUpdate:sql];
    if (!rs) {
        NSLog(@"Storage deleteIndexWeibos failed. error=%@", [db lastError]);
    }
}

- (void)addMedia:(NSString *)url File:(NSString *)path
{
    NSString *sql = @"SELECT * FROM Media WHERE url=(?)";
    FMResultSet *fs = [db executeQuery:sql, url];
    if ([fs next]) {
        sql = @"DELETE FROM Media WHERE url=(?)";
        [db executeUpdate:sql, url];
    }
    
    sql = @"INSERT INTO Media (url, file) values (?,?)";
    if (![db executeUpdate:sql, url, path]) {
        NSLog(@"Storage addMedia failed. error=%@", [db lastError]);
    }
}

- (NSString *)getMediaByUrl:(NSString *)url
{
    NSString *sql = @"SELECT * FROM Media WHERE url=(?)";
    FMResultSet *fs = [db executeQuery:sql, url];
    if ([fs next]) {
        return [fs stringForColumn:@"file"];
    }
    return nil;
}

- (void)addWeiboMedia:(DTWeiboMedia *)media
{
    NSString *sql = @"INSERT INTO WbMedia (weiboId, type, index, url) values (?,?,?,?)";
    BOOL rs = [db executeUpdate:sql,
               [[NSNumber alloc] initWithLongLong:media.weiboId],
               [[NSNumber alloc] initWithLong:media.type],
               [[NSNumber alloc] initWithLong:media.index],
               media.url];
    if (!rs) {
        NSLog(@"Storage addWeiboMedia failed. error=%@", [db lastError]);
    }
}

- (NSArray *)privateGetDTWeiboArrayByFMResult:(FMResultSet *)rs count:(NSInteger)count
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    while ([rs next]) {
        DTWeibo *weibo = [[DTWeibo alloc] init];
        weibo.weiboId = [rs longLongIntForColumn:@"weiboId"];
        weibo.date = [rs dateForColumn:@"date"];
        weibo.owner = [rs stringForColumn:@"owner"];
        weibo.source = [rs stringForColumn:@"source"];
        weibo.visible = [rs intForColumn:@"visible"];
        weibo.content = [rs stringForColumn:@"content"];
        weibo.repostCount = [rs intForColumn:@"repostCount"];
        weibo.commentCount = [rs intForColumn:@"commentCount"];
        weibo.likeCount = [rs intForColumn:@"likeCount"];
        weibo.favorite = [rs intForColumn:@"favorite"];
        weibo.picture = [rs intForColumn:@"picture"];
        weibo.isRepost = [rs intForColumn:@"isRepost"];
        weibo.originalWeiboId = [rs longLongIntForColumn:@"originalWeiboId"];
        weibo.originalOwner = [rs stringForColumn:@"originalOwner"];
        weibo.originalWeiboContent = [rs stringForColumn:@"originalWeiboContent"];
        weibo.originalWeiboPicture = [rs intForColumn:@"originalWeiboPicture"];
        weibo.isIndex = [rs intForColumn:@"isIndexWeibo"];
        [array addObject:weibo];
        
        if (count == ++index) {
            return array;
        }
    }
    
    if ([array count]) {
        return array;
    }
    
    return nil;
}

//根据uid获取其weibos, 若date为空则获取最新的，否则获取比此时间早的微博（更旧的）
- (NSArray *)getWeibosByUid:(NSString *)uid  count:(NSInteger)count date:(NSDate*)date
{
    FMResultSet *rs;
    NSString *sql = @"SELECT * FROM Weibo WHERE owner=(?) ";
    if (!date) {
        sql = [sql stringByAppendingString:@"ORDER BY date DESC"];
        rs = [db executeQuery:uid, sql];
    } else {
        sql = [sql stringByAppendingString:@"AND date<(?) ORDER BY date DESC"];
        rs = [db executeQuery:sql, uid, date];
    }
    
    return [self privateGetDTWeiboArrayByFMResult:rs count:count];
}

//获取当前用户weibos，若date为空则获取最新的，否则获取比此时间早的微博（更旧的）
- (NSArray *)getLoginUserWeibos:(NSInteger)count date:(NSDate *)date
{
    FMResultSet *rs;
    NSString *sql = @"SELECT * FROM Weibo WHERE isIndexWeibo='1' ";
    if (!date) {
        sql = [sql stringByAppendingString:@"ORDER BY date DESC"];
        rs = [db executeQuery:sql];
    } else {
        sql = [sql stringByAppendingString:@"AND date<(?) ORDER BY date DESC"];
        rs = [db executeQuery:sql, date];
    }
    
    return [self privateGetDTWeiboArrayByFMResult:rs count:count];
}

- (DTUser *)privateGetDTUserByFMResultSet:(FMResultSet *)rs
{
    DTUser *user = [[DTUser alloc] init];
    user.uid = [rs stringForColumn:@"uid"];
    user.name = [rs stringForColumn:@"name"];
    user.nickName = [rs stringForColumn:@"nickName"];
    user.avatar = [rs stringForColumn:@"avatar"];
    user.avatarLarge = [rs stringForColumn:@"avatarLarge"];
    user.sex = [rs intForColumn:@"sex"];
    user.address = [rs stringForColumn:@"address"];
    user.weiboCount = [rs intForColumn:@"weiboCount"];
    user.fanCount = [rs intForColumn:@"fanCount"];
    user.followingCount = [rs intForColumn:@"followingCount"];
    user.sign = [rs stringForColumn:@"sign"];
    user.verified = [rs intForColumn:@"verified"];
    user.verifiedReason =[rs stringForColumn:@"verifiedReason"];
    user.star = [rs intForColumn:@"star"];
    user.weiboMember = [rs intForColumn:@"weiboMember"];
    user.lastMyWeiboId = [rs longLongIntForColumn:@"lastMyWeiboId"];
    user.following = [rs intForColumn:@"following"];
    user.followMe = [rs intForColumn:@"followMe"];
    user.allowAllMsg = [rs intForColumn:@"allowAllMsg"];
    user.allowAllComment = [rs intForColumn:@"allowAllComment"];
    user.biFollowCount = [rs intForColumn:@"biFollowCount"];
    user.blog = [rs stringForColumn:@"blog"];
    return user;
}

//根据uid获取DTUser
- (DTUser *)getUserByUid:(NSString *)uid
{
    NSString *sql = @"select * from User where uid=(?)";
    FMResultSet *rs = [db executeQuery:sql, uid];
    if (![rs next]) {
        return nil;
    }
    
    return [self privateGetDTUserByFMResultSet:rs];
}


//获取登录用户关注人
- (NSArray *)getLoginUserFollowings
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *sql = @"select * from User where following=1";
    FMResultSet *rs = [db executeQuery:sql];
    while ([rs next]) {
        [array addObject: [self privateGetDTUserByFMResultSet:rs]];
    }
    
    if (array.count) {
        return  array;
    }
    
    return nil;
}

//获取最近@过的好友
- (NSArray *)getLatestUsers
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *sql = @"select * from LatestUser ORDER BY date DESC";
    FMResultSet *rs = [db executeQuery:sql];
    while ([rs next]) {
        [array addObject: [self privateGetDTUserByFMResultSet:rs]];
    }
    
    if (array.count) {
        return  array;
    }
    
    return nil;
}

//更新最近@过的好友
- (void)updateLatestUser:(DTUser *)user
{
    //插入一条数据
    void(^insertOneUser)(DTUser *) = ^(DTUser *user) {
        BOOL result = [db executeUpdate:@"DELETE FROM LatestUser WHERE uid=(?)", user.uid];
        if (!result) {
            NSLog(@"updateLatestUser delete failed.error=%@", [db lastError]);
        }
        
        NSString *sql = @"INSERT INTO LatestUser (uid,name,nickName,avatar,avatarLarge,sex,address,weiboCount,fanCount,followingCount,sign,verified,verifiedReason,star,weiboMember,lastMyWeiboId,following,followMe,allowAllMsg,allowAllComment,biFollowCount,blog,date) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        result = [db executeUpdate:sql,
                       user.uid,
                       user.name,
                       user.nickName,
                       user.avatar,
                       user.avatarLarge,
                       [[NSNumber alloc] initWithLong:user.sex],
                       user.address,
                       [[NSNumber alloc] initWithLong:user.weiboCount],
                       [[NSNumber alloc] initWithLong:user.fanCount],
                       [[NSNumber alloc] initWithLong:user.followingCount],
                       user.sign,
                       [[NSNumber alloc] initWithLong:user.verified],
                       user.verifiedReason,
                       [[NSNumber alloc] initWithLong:user.star],
                       [[NSNumber alloc] initWithLong:user.weiboMember],
                       [[NSNumber alloc] initWithLongLong:user.lastMyWeiboId],
                       [[NSNumber alloc] initWithLong:user.following],
                       [[NSNumber alloc] initWithLong:user.followMe],
                       [[NSNumber alloc] initWithLong:user.allowAllMsg],
                       [[NSNumber alloc] initWithLong:user.allowAllComment],
                       [[NSNumber alloc] initWithLong:user.biFollowCount],
                       [NSDate date],
                       user.blog];
        if (!result) {
            NSLog(@"Storage LatestUser addUser failed. error=%@", [db lastError]);
        }
    };
    
    //判断是否超过10条
    int count = 0;
    NSString *sql = @"select count(*) AS count from LatestUser";
    FMResultSet *rs = [db executeQuery:sql];
    if ([rs next]) {
        count = [rs intForColumn:@"count"];
    }
    
    //没超过10条，直接插入
    if (count < 10) {
        insertOneUser(user);
        
    //超过10条，更新最旧的一条数据
    } else {
        NSString *sql = @"select * from LatestUser ORDER BY date DESC";
        rs = [db executeQuery:sql];
        if (![rs next]) {
            return;
        }
        NSString *userId = [rs stringForColumn:@"uid"];
        BOOL result = [db executeUpdate:@"DELETE FROM LatestUser WHERE uid=(?)", userId];
        if (!result) {
            NSLog(@"delete failed.error=%@", [db lastError]);
        }
        insertOneUser(user);
    }
}

@end