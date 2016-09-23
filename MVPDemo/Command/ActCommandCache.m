//
//  ActCommandCache.m
//  coolooknews
//
//  Created by zhoujie on 15/11/24.
//  Copyright © 2015年 coolook. All rights reserved.
//

#import "ActCommandCache.h"
//#import "GKMD5.h"
#import <UIKit/UIKit.h>

NSString *currentTimeString(void)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateNow = [NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]];
    NSString *vTime = [formatter stringFromDate:dateNow];
    
    return vTime;
}

NSInteger numberOfMinutesFromTodayByTime(NSString *aDate, NSString*aTimeStringFormat)
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitMinute;
    
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:aTimeStringFormat];
    
    NSDate *fromdate=[format dateFromString:aDate];
    NSTimeZone *fromzone = [NSTimeZone systemTimeZone];
    NSInteger frominterval = [fromzone secondsFromGMTForDate:fromdate];
    NSDate *fromDate = [fromdate  dateByAddingTimeInterval:frominterval];
    //NSLog(@"fromdate=%@",fromDate);
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    //NSLog(@"enddate=%@",localeDate);
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:fromDate toDate:localeDate options:0];
    NSInteger minutes = [components minute];
    
    //NSLog(@"numberOfMinutesFromTodayByTime = %d",minutes);
    return minutes;
}

static NSInteger cacheMaxCacheAge = 60*60*24*7; // 1 week

@interface ActCommandCache ()

@property (nonatomic, strong) NSString* fileCacheDirectory;

@property (nonatomic, strong) NSCache *memCache;

@end

@implementation ActCommandCache

#pragma mark - Notify

- (void)clearMemory
{
    [self.memCache removeAllObjects];
}

- (void)cleanDisk
{
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheMaxCacheAge];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.fileCacheDirectory];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [self.fileCacheDirectory stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.memCache = [[NSCache alloc] init];
        self.memCache.name = @"RequestFileCache";
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        self.fileCacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"RequestFileCache"];
        NSFileManager* fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:self.fileCacheDirectory]) {
            [fm createDirectoryAtPath:self.fileCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
#if TARGET_OS_IPHONE
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0
        UIDevice *device = [UIDevice currentDevice];
        if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported)
        {
            // When in background, clean memory in order to have less chance to be killed
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(clearMemory)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
        }
#endif
#endif
    }
    return self;
}

- (NSString *)createFileName
{
    static NSInteger magicNumber = 0;
    NSString* timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    NSString* str = [[NSString stringWithFormat:@"%@", @(magicNumber++)] stringByAppendingString:timestamp];
    return str;//[GKMD5 MD5:str];
}

- (NSString *)getTotalRequestURLStringCommand:(ActCommand *)aCommand
{
    NSMutableString* requestURLString = [NSMutableString stringWithString:aCommand.requestURLString];
    if (aCommand.requestType == ActCommandRequestTypeGET) {
        NSString* params = [aCommand stringForEncodeURL:aCommand.params];
        if (params.length) {
            if ([requestURLString rangeOfString:@"?"].length == 0) {
                [requestURLString appendFormat:@"?%@", [params substringToIndex:params.length - 1]];
            } else {
                [requestURLString appendFormat:@"&%@", [params substringToIndex:params.length - 1]];
            }
        }
    } else {
        NSData* postData = [aCommand postData];
        if (postData == nil) {
            NSString* params = [aCommand stringForEncodeURL:aCommand.params];
            [requestURLString appendFormat:@"?%@", params];
        }
    }
    return requestURLString;
}

#pragma mark - extern Methods

- (NSData *)cachedResponseDataWithCommand:(ActCommand *)aCommand
{
    if (aCommand.checkCache == NO) {
        // 不检查缓存
        return nil;
    }
    
    NSString* requestURLString = [self getTotalRequestURLStringCommand:aCommand];
    
    // 检查缓存
    NSDictionary *cacheDict = [self.memCache objectForKey:requestURLString];
    NSString *cacheTimeStamp = [cacheDict objectForKey:@"cacheTimeStamp"];
    if (cacheTimeStamp == nil || [cacheTimeStamp length] <= 0) {
        // 小于等于0
        return nil;
    }
    NSString *fileName = [cacheDict objectForKey:@"fileName"];
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", self.fileCacheDirectory, fileName];
    NSInteger lastnumberOfMinutes = numberOfMinutesFromTodayByTime(cacheTimeStamp, @"yyyy-MM-dd HH:mm:ss");
    if (lastnumberOfMinutes > self.limitNumberOfMinutes) {
        // 大于限制的时间, 移除之前缓存的数据
        NSFileManager* fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:filePath]) {
            [fm removeItemAtPath:filePath error:nil];
        }
        
        [self.memCache removeObjectForKey:requestURLString];
        return nil;
    }
    
    NSData *responseData = [NSData dataWithContentsOfFile:filePath];
    return responseData;
}

- (void)cacheRequestWithCommand:(ActCommand *)aCommand responseData:(NSData *)aData
{
    if (aCommand.checkCache == NO) {
        // 不检查缓存
        return;
    }
    
    if (aData) {
        NSString* requestURLString = [self getTotalRequestURLStringCommand:aCommand];
        
        NSString *cacheTimeStamp = currentTimeString();
        NSString* fileName = [[self createFileName] stringByAppendingString:@".txt"];
        NSString* filePath = [NSString stringWithFormat:@"%@/%@", self.fileCacheDirectory, fileName];
        [aData writeToFile:filePath atomically:YES];
        
        NSDictionary *cacheDict = [NSDictionary dictionaryWithObjectsAndKeys:cacheTimeStamp, @"cacheTimeStamp", fileName, @"fileName", nil];
        
        // 保存到缓存中
        [self.memCache setObject:cacheDict forKey:requestURLString];
    }
}

@end
