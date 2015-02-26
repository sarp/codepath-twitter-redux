//
//  TwitterClient.m
//  Twitter
//
//  Created by Sarp Centel on 2/17/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "TwitterClient.h"
#import "Tweet.h"

@interface TwitterClient ()

@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);

@end

@implementation TwitterClient

NSString * const kTwitterConsumerKey = @"LV9vxYu0zmjGelFu69Yc2G2z1";
NSString * const kTwitterConsumerSecret = @"pTEWpkxBgv4eYQeOeAwsbKsU2cx6isFF01GLoED6Y9c2QCwANT";
NSString * const kTwitterBaseUrl = @"https://api.twitter.com";

+ (TwitterClient *) sharedInstance {
    static TwitterClient *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
        }
    });
    
    return instance;
}

- (void) loginWithCompletion:(void (^)(User *user, NSError *error)) completion {
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        
        [[UIApplication sharedApplication] openURL:authURL];
    } failure:^(NSError *error) {
        self.loginCompletion(nil, error);
    }];
}

- (void) openURL:(NSURL*)url {
    [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query]  success:^(BDBOAuth1Credential *accessToken) {
        [self.requestSerializer saveAccessToken:accessToken];
        
        [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            User *user = [[User alloc] initWithDictionary:responseObject];
            [User setCurrentUser:user];
            self.loginCompletion(user, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.loginCompletion(nil, error);
        }];
    } failure:^(NSError *error) {
        self.loginCompletion(nil, error);
    }];
}

- (void) homeTimelineWithParams:(NSDictionary*) params completion:(void (^)(NSArray *tweets, NSError *error)) completion {
    [self GET:@"1.1/statuses/home_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void) userTimelineForUser:(NSString*) screenName completion:(void (^)(NSArray *tweets, NSError * error)) completion {
    NSDictionary *params = @{ @"screen_name" : screenName};
    [self GET:@"1.1/statuses/user_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void) mentionsTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/mentions_timeline.json?include_my_retweet=1" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void) tweet:(NSString*) text original:(Tweet*) tweet completion:(void (^) (Tweet *tweet, NSError *error)) completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"status" : text }];
    if (tweet != nil) {
        [params setValue:tweet.tweetId forKey:@"in_reply_to_status_id"];
    }
    [self POST:@"1.1/statuses/update.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void) retweet:(Tweet*) tweet completion:(void (^) (Tweet *tweet, NSError *error)) completion {
    [self POST:[NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweet.tweetId] parameters:@{@"include_my_retweet" : @"true"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void) unretweet:(NSString*) tweetId completion:(void (^) (Tweet *tweet, NSError *error)) completion {
    [self POST:[NSString stringWithFormat:@"1.1/statuses/destroy/%@.json", tweetId] parameters:@{@"include_my_retweet" : @"true"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void) favorite:(Tweet*) tweet completion:(void (^) (Tweet *tweet, NSError *error)) completion {
    [self POST:@"1.1/favorites/create.json" parameters:@{@"id" : tweet.tweetId, @"include_my_retweet" : @"true" } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void) unfavorite:(Tweet*) tweet completion:(void (^) (Tweet *tweet, NSError *error)) completion {
    [self POST:@"1.1/favorites/destroy.json" parameters:@{@"id" : tweet.tweetId, @"include_my_retweet" : @"true" } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

@end
