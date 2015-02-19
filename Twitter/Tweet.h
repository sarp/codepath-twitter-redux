//
//  Tweet.h
//  Twitter
//
//  Created by Sarp Centel on 2/17/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, assign) NSString* tweetId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) User *user;
@property (nonatomic, assign) BOOL retweeted;
@property (nonatomic, assign) BOOL isFavorited;
@property (nonatomic, strong) Tweet *retweetedTweet;
@property (nonatomic, strong) NSString* retweetCount;
@property (nonatomic, strong) NSString* favoriteCount;

- (id) initWithDictionary: (NSDictionary *)dictionary;
+ (NSArray *) tweetsWithArray:(NSArray *) array;

@end