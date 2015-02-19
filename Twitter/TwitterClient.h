//
//  TwitterClient.h
//  Twitter
//
//  Created by Sarp Centel on 2/17/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *) sharedInstance;
- (void) loginWithCompletion:(void (^)(User *user, NSError *error)) completion;
- (void) openURL:(NSURL*)url;

- (void) homeTimelineWithParams:(NSDictionary*) params completion:(void (^)(NSArray *tweets, NSError *error)) completion;
- (void) userTimelineForUser:(NSString*) user completion:(void (^)(NSArray *tweets, NSError *error)) completion;

- (void) tweet:(NSString*) text completion:(void (^) (Tweet *tweet, NSError *error)) completion;
- (void) reply:(NSString*) text original:(Tweet*) tweet completion:(void (^) (Tweet* tweet, NSError *error)) completion;
- (void) retweet:(Tweet*) tweet completion:(void (^) (Tweet* tweet, NSError *error)) completion;
- (void) favorite:(Tweet*) tweet completion:(void (^) (NSError *error)) completion;

@end
