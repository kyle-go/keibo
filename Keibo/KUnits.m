//
//  KUnits.m
//  Keibo
//
//  Created by kyle on 11/10/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "KUnits.h"

@implementation KUnits

+ (NSString *)generateUuidString {
    CFStringRef uuid = CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(kCFAllocatorDefault));
    return [NSString stringWithString:CFBridgingRelease(uuid)];
}

+ (NSString *)weiboFormat:(NSString *)content repost:(NSString *)repostContent reposter:(NSString *)name;
{
    NSString *templateName;
    BOOL hasOriginWeibo = [repostContent length];
    if (hasOriginWeibo) {
        templateName = @"weibo-repost.html";
    } else {
        templateName = @"weibo-simple.html";
    }
    
    NSString *temp_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/%@", templateName];
    NSData *tmp_data = [[NSFileManager defaultManager] contentsAtPath:temp_path];
    NSString *templateContent = [[NSString alloc] initWithData:tmp_data encoding:NSUTF8StringEncoding];
    
    NSString *(^stringTranslate)(NSString *) = ^(NSString *content){
        NSMutableString *html = [NSMutableString stringWithString:content];
        //匹配话题##之间非@#的符号（有bug，需要转义为%那样的，否则标签解析有问题）
        NSString *regTopic = @"#[^[@#]]+#";
        [html replaceOccurrencesOfString:regTopic withString:@"<a href=\"$0\">$0</a>" options:NSRegularExpressionSearch range:NSMakeRange(0, [html length])];
        //匹配 http:// 或者 https://
        NSString *regHttp = @"http://t.cn/[a-zA-Z0-9]+\\b";
        [html replaceOccurrencesOfString:regHttp withString:@"<a href=\"$0\">$0</a>" options:NSRegularExpressionSearch range:NSMakeRange(0, [html length])];
        //匹配 @后跟1个或者多个字母、数字、汉字、下划线、减号
        [html replaceOccurrencesOfString:@"@[-\\w]+" withString:@"<a href=\"$0\">$0</a>" options:NSRegularExpressionSearch range:NSMakeRange(0, [html length])];
        return html;
    };
    
    NSString *html = [templateContent stringByReplacingOccurrencesOfString:@"WEIBO-BODY" withString:stringTranslate(content)];
    if (hasOriginWeibo) {
        NSString *translate = [[NSString alloc] initWithFormat:@"<strong>@%@:</strong>%@", name, stringTranslate(repostContent)];
        html = [html stringByReplacingOccurrencesOfString:@"WEIBO-REPOST" withString:translate];
    }
    
    return html;
}

+ (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params
{
	if (params) {
		NSMutableArray* pairs = [[NSMutableArray alloc] init];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
			NSString* escapedValue = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
																						  NULL, /* allocator */
																						  (CFStringRef)value,
																						  NULL, /* charactersToLeaveUnescaped */
																						  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																						  kCFStringEncodingUTF8));
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escapedValue]];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
		return [NSURL URLWithString:url];
	} else {
		return [NSURL URLWithString:baseURL];
	}
}

+ (NSString *)getWeiboSourceText:(NSString *)text
{
    NSString *defaultValue = @"未知应用";
    if ([text length] == 0) {
        return defaultValue;
    }
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@">[^[><]]+</a>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSRange range = [regex rangeOfFirstMatchInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, [text length])];
    if (range.location != NSNotFound) {
        return [text substringWithRange:NSMakeRange(range.location+1, range.length-5)];
    }
    return defaultValue;
}



//Thu Nov 14 20:19:09 +0800 2013
+ (NSDate *)getNSDateByDateString:(NSString *)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE MMM dd HH:mm:ss z yyyy"];
    return [formatter dateFromString:dateString];
}

/*
 由具体时间获取一个“微博时间”，比如“1分钟前”
 
 先说逻辑：
 1. 1分钟以内，返回此数据向后取10整数倍（如取整遇到60则返回“1分钟前”） 例如“20秒前”
 2. 1分钟～60分钟，返回此数据加一 （如取整遇到60则返回“1小时前”） 例如“7分钟前”
 3. 1小时～10小时，返回此数据加一 例如“9小时前”
 4. 今天的微博，返回今天时分 例如“今天 11:24”
 5. 昨天的微博，返回昨天时分 例如“昨天 12:08”
 6. 今年的微博，返回月日时分 例如"10月23日 23:18"
 7. 其他的，返回完整格式 例如“2012-12-08 12:38:46”
 
 备注：
 1. 参数时间与本地当前时间对比（没找到获取微博服务器当前时间接口，哪位仁兄知道类似接口烦请告知，感激不尽）
 2.本函数不会返回“刚刚”这样的结果，“刚刚”这种情况只会在自己发微博，然后返回微博呈现页时，把刚发送新微博插入到显示列表中
 3.如果参数时间比当前时间晚，这种情况（a.微博数据错误，b.本地时间不准确）显示全格式，例如“2014-12-08 12:38:46”
 */

+ (NSString *)getProperDateStringByDate:(NSDate *)date type:(NSInteger *)type
{
    if (!date) {
        return nil;
    }
    
    //是否是同一年
    BOOL (^isTheDateSameYear)(NSDate* date1, NSDate *date2) = ^(NSDate* date1, NSDate *date2){
        NSDateFormatter *formatatter = [[NSDateFormatter alloc] init];
        [formatatter setDateFormat:@"yyyy"];
        return [[formatatter stringFromDate:date1] isEqualToString:[formatatter stringFromDate:date2]];
    };
    
    //是否是同一天
    BOOL (^isTheDateSameDay)(NSDate* date1, NSDate *date2) = ^(NSDate* date1, NSDate *date2){
        NSDateFormatter *formatatter = [[NSDateFormatter alloc] init];
        [formatatter setDateFormat:@"yyyy-MM-dd"];
        return [[formatatter stringFromDate:date1] isEqualToString:[formatatter stringFromDate:date2]];
    };
    
    //是否是昨天
    BOOL (^isYesterdayDate)(NSDate *date, NSDate *dstDate) = ^(NSDate *date, NSDate *dstDate) {
        NSDate *datePlus = [date dateByAddingTimeInterval:24*60*60.0];
        return isTheDateSameDay(datePlus, dstDate);
    };
    
    
    //参数时间比当前时间晚
    if ([date timeIntervalSinceNow] > 0) {
        *type = 7;
        NSDateFormatter *formatatter = [[NSDateFormatter alloc] init];
        [formatatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        return [formatatter stringFromDate:date];
    }
    
    //获取当前时间
    NSDate *curDate = [NSDate date];
    NSInteger second = lround([curDate timeIntervalSinceDate:date]);
    
    //1分钟以内，返回此数据向后取10整数倍（如取整遇到60则返回“1分钟前”） 例如“20秒前”
    if (second <= 60) {
        *type = 1;
        NSInteger tmp = 1 + second/10;
        if (tmp <= 5) {
            return [[NSString alloc] initWithFormat:@"%d秒前", 10*tmp];
        } else {
            return @"1分钟前";
        }
        
        //1分钟～60分钟，返回此数据加一 （如取整遇到60则返回“1小时前”） 例如“7分钟前”
    } else if (second <= 60*60) {
        *type = 2;
        NSInteger tmp = second/60 + 1;
        if (tmp <= 59) {
            return [[NSString alloc] initWithFormat:@"%d分钟前", tmp];
        } else {
            return @"1小时前";
        }
        
        //1小时～10小时，返回此数据加一 例如“9小时前”
    } else if (second < 10*60*60) {
        *type = 3;
        NSInteger tmp = second/(60*60) + 1;
        return [[NSString alloc] initWithFormat:@"%d小时前", tmp];
        
        //今天的微博，返回今天时分 例如“今天 11:24”
    } else if (isTheDateSameDay(date, curDate)) {
        *type = 4;
        NSDateFormatter *formatatter = [[NSDateFormatter alloc] init];
        [formatatter setDateFormat:@"'今天' HH:mm"];
        return [formatatter stringFromDate:date];
        
        //昨天的微博，返回昨天时分 例如“昨天 12:08”
    } else if (isYesterdayDate(date, curDate)) {
        *type = 5;
        NSDateFormatter *formatatter = [[NSDateFormatter alloc] init];
        [formatatter setDateFormat:@"'昨天' HH:mm"];
        return [formatatter stringFromDate:date];
        
        //今年的微博，返回月日时分 例如"10月23日 23:18"
    } else if(isTheDateSameYear(date, curDate)){
        *type = 6;
        NSDateFormatter *formatatter = [[NSDateFormatter alloc] init];
        [formatatter setDateFormat:@"MM'月'dd'日' HH:mm"];
        return [formatatter stringFromDate:date];
        
        //其他的，返回完整格式 例如“2012-12-08 12:38:46”
    } else {
        *type = 7;
        NSDateFormatter *formatatter = [[NSDateFormatter alloc] init];
        [formatatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        return [formatatter stringFromDate:date];
    }
}

@end
