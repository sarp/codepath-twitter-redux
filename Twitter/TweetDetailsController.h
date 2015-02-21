//
//  TweetDetailsController.h
//  Twitter
//
//  Created by Sarp Centel on 2/18/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol TweetDetailsDelegate <NSObject>

- (void) didUpdateTweet:(Tweet*) tweet;

@end

@interface TweetDetailsController : UIViewController

@property (weak, nonatomic) id<TweetDetailsDelegate> delegate;
- (id) initWithTweet:(Tweet*) tweet;

@end
