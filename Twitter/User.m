//
//  User.m
//  Twitter
//
//  Created by Sarp Centel on 2/17/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@interface User ()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation User

static User* _currentUser = nil;
NSString* const kCurrentUserKey = @"kCurrentUserKey";

- (id) initWithDictionary: (NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
        self.name = dictionary[@"name"];
        self.screenname = dictionary[@"screen_name"];
        self.profileImageUrl = [NSURL URLWithString:dictionary[@"profile_image_url"]];
        self.tagline = dictionary[@"description"];
        self.profileBackgroundImageUrl = [NSURL URLWithString:dictionary[@"profile_background_image_url"]];
        self.tweetCount = [dictionary[@"statuses_count"] stringValue];
        self.followingCount = [dictionary[@"friends_count"] stringValue];
        self.followerCount = [dictionary[@"followers_count"] stringValue];
        if (dictionary[@"profile_banner_url"] != nil) {
            self.bannerUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/mobile_retina", dictionary[@"profile_banner_url"]]];
        }
    }
    return self;
}

+ (User*) currentUser {
    if (_currentUser == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary:dictionary];
        }
    }
    return _currentUser;
}

+ (void) setCurrentUser:(User *)user {
    _currentUser = user;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (_currentUser != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:_currentUser.dictionary options:0 error:NULL];
        [defaults setObject:data forKey:kCurrentUserKey];
    } else {
        [defaults setObject:nil forKey:kCurrentUserKey];
    }
    [defaults synchronize];
}

- (void) logout {
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}

@end
