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
        self.text = dictionary[@"text"];
        NSString *createdString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        self.createdAt = [formatter dateFromString:createdString];
        self.retweetCount = dictionary[@"retweet_count"];
        self.favoriteCount = dictionary[@"favorite_count"];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
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