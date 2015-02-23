//
//  TweetDetailsController.m
//  Twitter
//
//  Created by Sarp Centel on 2/18/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "TweetDetailsController.h"
#import "UIImageView+AFNetworking.h"
#import "TwitterClient.h"
#import "ComposeTweetController.h"

@interface TweetDetailsController ()

@property (weak, nonatomic) IBOutlet UIImageView *retweetedImage;
@property (weak, nonatomic) IBOutlet UILabel *retweetedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;
@property (weak, nonatomic) IBOutlet UILabel *tweetDateText;
@property (weak, nonatomic) IBOutlet UILabel *retweetCount;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCount;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPadding;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIView *statsSeperator;

- (IBAction)onFavorite:(id)sender;
- (IBAction)onRetweet:(id)sender;
- (IBAction)onReply:(id)sender;

@property (nonatomic, strong) Tweet* tweet;
@property (nonatomic, strong) Tweet* retweetTweet;

- (void) updatePadding:(BOOL) isPortrait;

@end


@implementation TweetDetailsController

- (id) initWithTweet:(Tweet*) tweet {
    self = [super init];
    if (self) {
        self.tweet = tweet;
    }
    return self;
}

- (void) updateTweetViews {
    BOOL isRetweet = [self.tweet isRetweet];
    Tweet *displayedTweet = isRetweet ? self.tweet.retweetedTweet : self.tweet;
    
    if (isRetweet) {
        self.retweetedLabel.hidden = NO;
        self.retweetedLabel.text = [NSString stringWithFormat:@"%@ retweeted", self.tweet.user.name];
    } else {
        self.retweetedLabel.hidden = YES;
        self.retweetedImage.hidden = YES;
    }
    
    [self.retweetButton setSelected:displayedTweet.isRetweeted];
    [self.favoriteButton setSelected:displayedTweet.isFavorited];
    
    self.topPadding.constant = isRetweet ? 74.0 : 50.0;
    
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    [self.profileImage setImageWithURL:displayedTweet.user.profileImageUrl];
    
    self.profileName.text = displayedTweet.user.name;
    self.screenName.text = [NSString stringWithFormat:@"@%@", displayedTweet.user.screenname];
    self.tweetText.text = displayedTweet.text;

    self.retweetCount.text = displayedTweet.retweetCount;
    self.favoriteCount.text = displayedTweet.favoriteCount;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setDateFormat:@"M/d/yy, h:m a"];
    self.tweetDateText.text = [formatter stringFromDate:displayedTweet.createdAt];
    
    BOOL isPortrait =([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait);
    [self updatePadding:isPortrait];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    self.title = @"Tweet";
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    navBar.barTintColor = [UIColor colorWithRed:100.0f/255.0f green:166.0f/255.0f blue:233.0f/255.0f alpha:1.0f];
    navBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(onReply:)];
    
    [self updateTweetViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) onError:(NSError*) error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)onFavorite:(id)sender {
    if (self.tweet.isFavorited) {
        // unfavorite
        [[TwitterClient sharedInstance] unfavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if (error == nil) {
                self.tweet = tweet;
                [self updateTweetViews];
                [self.delegate didUpdateTweet:self.tweet];
            } else {
                [self onError:error];
            }
        }];
    } else {
        // favorite
        [[TwitterClient sharedInstance] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if (error == nil) {
                self.tweet = tweet;
                [self updateTweetViews];
                [self.delegate didUpdateTweet:self.tweet];
            } else {
                [self onError:error];
            }
        }];
    }
}

- (IBAction)onRetweet:(id)sender {
    Tweet *targetTweet = [self.tweet isRetweet] ? self.tweet.retweetedTweet : self.tweet;
    if (targetTweet.isRetweeted) {
        [[TwitterClient sharedInstance] unretweet:targetTweet.currentUserRetweetId completion:^(Tweet *tweet, NSError *error) {
            if (error == nil) {
                targetTweet.isRetweeted = NO;
                targetTweet.retweetCount = [NSString stringWithFormat:@"%ld", targetTweet.retweetCount.integerValue-1];
                [self updateTweetViews];
                [self.delegate didUpdateTweet:targetTweet];
            } else {
                [self onError:error];
            }
        }];
    } else {
        [[TwitterClient sharedInstance] retweet:targetTweet completion:^(Tweet *tweet, NSError *error) {
            if (error == nil) {
                targetTweet.currentUserRetweetId = tweet.tweetId;
                targetTweet.isRetweeted = YES;
                targetTweet.retweetCount = tweet.retweetCount;
                [self updateTweetViews];
                [self.delegate didUpdateTweet:targetTweet];
            } else {
                [self onError:error];
            }
        }];
    }
}

- (IBAction)onReply:(id)sender {
    ComposeTweetController *vc = [[ComposeTweetController alloc] init];
    vc.original = self.tweet;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void) updatePadding:(BOOL) isPortrait {
    if (isPortrait) {
        if (self.tweet.retweetedTweet != nil) {
            self.topPadding.constant = 74;
        } else {
            self.topPadding.constant = 50;
        }
    } else {
        if (self.tweet.retweetedTweet != nil) {
            self.topPadding.constant = 44;
        } else {
            self.topPadding.constant = 20;
        }
    }
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    [self updatePadding:(device.orientation == UIDeviceOrientationPortrait)];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end