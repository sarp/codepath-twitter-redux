//
//  TweetDetailsController.m
//  Twitter
//
//  Created by Sarp Centel on 2/18/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "TweetDetailsController.h"
#import "UIImageView+AFNetworking.h"

// TODO: Control to retweet, favorite, reply

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
@end

@implementation TweetDetailsController

- (id) initWithTweet:(Tweet*) tweet {
    self = [super init];
    if (self) {
        self.tweet = tweet;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Tweet";
    // Do any additional setup after loading the view from its nib.
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    navBar.barTintColor = [UIColor colorWithRed:100.0f/255.0f green:166.0f/255.0f blue:233.0f/255.0f alpha:1.0f];
    navBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(onReply:)];
    
    BOOL isRetweet = self.tweet.retweetedTweet != nil;
    Tweet *displayedTweet = isRetweet ? self.tweet.retweetedTweet : self.tweet;
    
    if (isRetweet) {
        self.retweetedLabel.hidden = NO;
        self.retweetedLabel.text = [NSString stringWithFormat:@"%@ retweeted", self.tweet.user.name];
    } else {
        self.retweetedLabel.hidden = YES;
        self.retweetedImage.hidden = YES;
    }
    self.topPadding.constant = isRetweet ? 74.0 : 44.0;
    
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    [self.profileImage setImageWithURL:self.tweet.user.profileImageUrl];
    
    self.profileName.text = displayedTweet.user.name;
    self.screenName.text = displayedTweet.user.screenname;
    self.tweetText.text = displayedTweet.text;

    BOOL hasZeroRetweets = [displayedTweet.retweetCount isEqualToString:@"0"];
    BOOL hasZeroFavorites = [displayedTweet.favoriteCount isEqualToString:@"0"];
    
    if (hasZeroRetweets && hasZeroFavorites) {
        self.retweetCount.hidden = YES;
        self.retweetCountLabel.hidden = YES;
        self.favoriteCountLabel.hidden = YES;
        self.favoriteCount.hidden = YES;
        self.statsSeperator.hidden = YES;
    } else if (hasZeroFavorites) {
        self.favoriteCount.hidden = YES;
        self.favoriteCountLabel.hidden = YES;
    } else if (hasZeroRetweets) {
        self.retweetCountLabel.hidden = YES;
        self.retweetCount.hidden = YES;
    }
    
    self.retweetCount.text = displayedTweet.retweetCount;
    self.favoriteCount.text = displayedTweet.favoriteCount;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M/d/yy, h:m a"];
    self.tweetDateText.text = [formatter stringFromDate:displayedTweet.createdAt];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)onFavorite:(id)sender {
        NSLog(@"onFavorite");
}

- (IBAction)onRetweet:(id)sender {
    NSLog(@"onRetweet");
}

- (IBAction)onReply:(id)sender {
        NSLog(@"onReply");
}
@end