//
//  TweetCell.m
//  Twitter
//
//  Created by Sarp Centel on 2/18/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+DateTools.h"

@interface TweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *retweetedImage;
@property (weak, nonatomic) IBOutlet UILabel *retweetedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *replyImage;
@property (weak, nonatomic) IBOutlet UIImageView *retweetImage;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPadding;

@end

@implementation TweetCell

// TODO: Correct tweet text wrapping

- (void) setTweet:(Tweet*) tweet {
    self.currentTweet = tweet;
    Tweet *displayTweet = tweet.retweetedTweet;
    if (displayTweet == nil) {
        self.retweetedLabel.hidden = YES;
        self.retweetedImage.hidden = YES;
        self.topPadding.constant = -15;
        displayTweet = tweet;
    } else {
        self.topPadding.constant = 8;
        self.retweetedLabel.hidden = NO;
        self.retweetedImage.hidden = NO;
        self.retweetedLabel.text = [NSString stringWithFormat:@"%@ retweeted", tweet.user.name];
    }

    [self setFavoritedStatus:displayTweet];
    [self setRetweetedStatus:displayTweet];
    [self.profileImage setImageWithURL:displayTweet.user.profileImageUrl];
    self.fullNameLabel.text = displayTweet.user.name;
    self.handleLabel.text = [NSString stringWithFormat:@"@%@", displayTweet.user.screenname];
    self.tweetLabel.text = displayTweet.text;
    self.dateLabel.text = displayTweet.createdAt.shortTimeAgoSinceNow;
}

- (void) setFavoritedStatus: (Tweet*) tweet {
    if (tweet.isFavorited) {
        self.favoriteImage.image =  [UIImage imageNamed:@"favorite_on.png"];
    } else {
        self.favoriteImage.image =  [UIImage imageNamed:@"favorite.png"] ;
    }
}

- (void) setRetweetedStatus: (Tweet*) tweet {
    if (tweet.isRetweeted) {
        self.retweetImage.image =  [UIImage imageNamed:@"retweet_on.png"];
    } else {
        self.retweetImage.image =  [UIImage imageNamed:@"retweet.png"] ;
    }
}

- (void)awakeFromNib {
    self.tweetLabel.preferredMaxLayoutWidth = self.tweetLabel.frame.size.width;
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    
    UITapGestureRecognizer *replyRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapReply)];
    [self.replyImage addGestureRecognizer:replyRecognizer];
    
    UITapGestureRecognizer *retweetRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapRetweet)];
    [self.retweetImage addGestureRecognizer:retweetRecognizer];
    
    UITapGestureRecognizer *favoriteRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapFavorite)];
    [self.favoriteImage addGestureRecognizer:favoriteRecognizer];

    // Initialization code
}

- (void) onTapReply {
    [self.delegate onTapReply:self];
}

- (void) onTapFavorite {
    [self.delegate onTapFavorite:self];
}

- (void) onTapRetweet {
    [self.delegate onTapRetweet:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
