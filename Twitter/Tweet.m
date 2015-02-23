//
//  Tweet.m
//  Twitter
//
//  Created by Sarp Centel on 2/17/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id) initWithDictionary: (NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.tweetId = [dictionary[@"id"] stringValue];
        self.text = dictionary[@"text"];
        NSString *createdString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        self.createdAt = [formatter dateFromString:createdString];
        self.retweetCount = [dictionary[@"retweet_count"] stringValue];
        self.favoriteCount = [dictionary[@"favorite_count"] stringValue];
        self.isRetweeted = [dictionary[@"retweeted"] boolValue];
        NSDictionary *retweetInfo = dictionary[@"current_user_retweet"];
        self.currentUserRetweetId = retweetInfo[@"id_str"];
        self.isFavorited = [dictionary[@"favorited"] boolValue];
        if (dictionary[@"retweeted_status"] != nil) {
            self.retweetedTweet = [[Tweet alloc] initWithDictionary:dictionary[@"retweeted_status"]];
        }
    }
    return self;
}

+ (NSArray *) tweetsWithArray:(NSArray *) array {
    NSMutableArray *tweets = [NSMutableArray array];
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    return tweets;
}

@end