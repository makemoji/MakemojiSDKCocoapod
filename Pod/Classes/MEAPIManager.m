//
//  MEApiManager.m
//  Makemoji
//
//  Created by steve on 3/2/15.
//  Copyright (c) 2015 Makemoji. All rights reserved.
//

#import "MEAPIManager.h"
#import <AdSupport/AdSupport.h>

@implementation MEAPIManager

+(instancetype)client
{
    static MEAPIManager * requests = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requests = [[MEAPIManager alloc] initWithBaseURL:[NSURL URLWithString:kMESSLBaseUrl]];
        [requests setSdkKey:@"unknown"];
        [requests.reachabilityManager startMonitoring];
        requests.channel = @"";
        requests.categories = [NSArray array];
        requests.lockedCategories = [NSArray array];
        NSString * deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled] == YES) {
            deviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
        
        NSString *language = [NSLocale currentLocale].localeIdentifier;

        NSString *model = [[UIDevice currentDevice] name];
        if ([model isEqualToString:@"iPhone Simulator"]) { deviceId = @"SIMULATOR"; }
        [requests.requestSerializer  setValue:deviceId forHTTPHeaderField:@"makemoji-deviceId"];
        [requests.requestSerializer  setValue:language forHTTPHeaderField:@"makemoji-language"];
        [requests.requestSerializer  setValue:@"1.1" forHTTPHeaderField:@"makemoji-version"];

    });
    return requests;
}

-(NSString *)cacheNameWithChannel:(NSString *)cacheName {
    NSString * separator = @"-";
    NSString * cacheChannelName = @"";
    if ([self.channel length] == 0) {
        separator = @"";
    }

    if ([self.channel length] > 0) {
        cacheChannelName = [self.channel stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    }
    
    return [NSString stringWithFormat:@"%@%@%@.json", cacheChannelName, separator, cacheName];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response,
                                                        id responseObject,
                                                        NSError *error))completionHandler
{
    NSMutableURLRequest *modifiedRequest = request.mutableCopy;
    AFNetworkReachabilityManager *reachability = self.reachabilityManager;
    if (reachability.isReachable == NO) {
        modifiedRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    return [super dataTaskWithRequest:modifiedRequest
                    completionHandler:completionHandler];
}



-(void)imageViewWithId:(NSString *)emojiId {
    
    
    MEAPIManager * apiManager = [MEAPIManager client];

    if (apiManager.imageViewSessionStart != nil) {
        if (fabs([apiManager.imageViewSessionStart timeIntervalSinceNow]) > 30) {
            [apiManager endImageViewSession];
            apiManager.imageViews = nil;
            apiManager.imageViewSessionStart = nil;
        }
    }
    
    if (apiManager.imageViews == nil) {
        apiManager.imageViews = [NSMutableDictionary dictionary];
    }
    
    if (apiManager.imageViewSessionStart == nil) {
        apiManager.imageViewSessionStart = [NSDate date];
    }
    
    NSMutableDictionary * viewDict = [apiManager.imageViews objectForKey:emojiId];
    
    if (viewDict == nil) {
        NSMutableDictionary * newDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:emojiId, @"1", nil] forKeys:[NSArray arrayWithObjects:@"emoji_id", @"views", nil]];
        [apiManager.imageViews setObject:newDict forKey:emojiId];
    } else {
        NSString * viewNumber = [viewDict objectForKey:@"views"];
        NSInteger viewCount = [viewNumber integerValue];
        viewCount++;
        [viewDict setObject:[NSString stringWithFormat:@"%li", (long)viewCount] forKey:@"views"];
        [apiManager.imageViews setObject:viewDict forKey:emojiId];
    }
}

-(void)beginImageViewSessionWithTag:(NSString *)tag {
    MEAPIManager * apiManager = [MEAPIManager client];
    if (apiManager.imageViewSessionStart == nil) {
        apiManager.imageViewSessionStart = [NSDate date];
    }
}

-(void)endImageViewSession {
    MEAPIManager *manager = [MEAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary * sending = [[MEAPIManager client] imageViews];
    [sending setObject:[[MEAPIManager client] imageViewSessionStart] forKey:@"date"];
    manager.imageViewSessionStart = nil;
    manager.imageViews = nil;
    
    [manager POST:@"emoji/viewTrack" parameters:sending success:^(NSURLSessionDataTask *task, id responseObject) {

    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
    
}


-(void)clickWithEmoji:(NSDictionary *)emoji {
    
    MEAPIManager * apiManager = [MEAPIManager client];
    if (apiManager.emojiClicks == nil) {
        apiManager.emojiClicks = [NSMutableArray array];
        apiManager.clickSessionStart = [NSDate date];
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:emoji];

    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [gmtDateFormatter stringFromDate:[NSDate date]];
    
    [dict setObject:dateString forKey:@"click"];
    if ([dict objectForKey:@"image_url"]) {
        [dict removeObjectForKey:@"image_url"];
    }
    
    if ([dict objectForKey:@"username"]) {
        [dict removeObjectForKey:@"username"];
    }

    if ([dict objectForKey:@"access"]) {
        [dict removeObjectForKey:@"access"];
    }

    if ([dict objectForKey:@"origin_id"]) {
        [dict removeObjectForKey:@"origin_id"];
    }
    
    if ([dict objectForKey:@"likes"]) {
        [dict removeObjectForKey:@"likes"];
    }
    
    if ([dict objectForKey:@"deleted"]) {
        [dict removeObjectForKey:@"deleted"];
    }
    
    if ([dict objectForKey:@"created"]) {
        [dict removeObjectForKey:@"created"];
    }
    
    if ([dict objectForKey:@"remoji"]) {
        [dict removeObjectForKey:@"remoji"];
    }
    
    if ([dict objectForKey:@"shares"]) {
        [dict removeObjectForKey:@"shares"];
    }

    if ([dict objectForKey:@"legacy"]) {
        [dict removeObjectForKey:@"legacy"];
    }
    
    if ([dict objectForKey:@"link_url"]) {
        [dict removeObjectForKey:@"link_url"];
    }
    
    if ([dict objectForKey:@"name"]) {
        [dict removeObjectForKey:@"name"];
    }
    
    if ([dict objectForKey:@"flashtag"]) {
        [dict removeObjectForKey:@"flashtag"];
    }

    
    [apiManager.emojiClicks addObject:dict];
    
    if (apiManager.emojiClicks.count > 25) {
        NSError * error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:apiManager.emojiClicks options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [apiManager POST:@"emoji/clickTrackBatch" parameters:@{@"emoji": jsonString} success:^(NSURLSessionDataTask *task, id responseObject) {
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
        apiManager.emojiClicks = nil;
        apiManager.clickSessionStart = nil;
        
    }
    
}



@end
