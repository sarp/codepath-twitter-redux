//
//  TweetCell.h
//  Twitter
//
//  Created by Sarp Centel on 2/18/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TweetCell;

@protocol TweetCellDelegate <NSObject>

- (void) onTapFavorite: (TweetCell*) cell;
- (void) onTapReply: (TweetCell*) cell;
- (void) onTapRetweet: (TweetCell*) cell;
- (void) onTapPhoto: (TweetCell*) cell forUser:(User*) user;

@end

@interface TweetCell : UITableViewCell

@property (strong, nonatomic) Tweet* currentTweet;
@property (nonatomic, weak) id<TweetCellDelegate> delegate;
- (void) setTweet: (Tweet*) tweet;
@end