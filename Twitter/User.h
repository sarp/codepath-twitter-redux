//
//  User.h
//  Twitter
//
//  Created by Sarp Centel on 2/17/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const UserDidLoginNotification;
extern NSString * const UserDidLogoutNotification;

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenname;
@property (nonatomic, strong) NSURL *profileImageUrl;
@property (nonatomic, strong) NSURL *profileBackgroundImageUrl;
@property (nonatomic, strong) NSURL *bannerUrl;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) NSString *followerCount;
@property (nonatomic, strong) NSString *followingCount;
@property (nonatomic, strong) NSString *tweetCount;

- (id) initWithDictionary: (NSDictionary *)dictionary;

+ (User *) currentUser;
+ (void) setCurrentUser:(User *) user;

- (void) logout;

@end
