//
//  TweetsViewController.m
//  Twitter
//
//  Created by Sarp Centel on 2/18/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "TweetsViewController.h"
#import "ComposeTweetController.h"
#import "TweetDetailsController.h"
#import "User.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "TwitterClient.h"

@interface TweetsViewController ()

// TODO: Implement retweet, favorite and reply

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) TweetCell *prototypeCell;


- (IBAction)onLogout:(id)sender;
@end

@implementation TweetsViewController

- (void) didUpdateTweet:(Tweet *)tweet {
    // TODO
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.prototypeCell.tweet = self.tweets[indexPath.row];
    [self.prototypeCell layoutSubviews];
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Table view initialization
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 160.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    // Infinite loading
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingView startAnimating];
    self.loadingView.center = tableFooterView.center;
    [tableFooterView addSubview:self.loadingView];
    self.tableView.tableFooterView = tableFooterView;
    
    // Initialize Navigation
    self.title = @"Home";
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    navBar.barTintColor = [UIColor colorWithRed:100.0f/255.0f green:166.0f/255.0f blue:233.0f/255.0f alpha:1.0f];
    navBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onNewTweet)];
    
    // Pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadPullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // Fetch data
    [self loadInitial];
}

#pragma mark - Table view methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    [cell setTweet:self.tweets[indexPath.row]];
    cell.delegate = self;
    
    NSInteger lastItemIndex = self.tweets.count - 1;
    if (lastItemIndex == indexPath.row) {
        // load more
        NSLog(@"Last item showing");
        [self loadMore];
    }
    return cell;
}

- (NSMutableArray*) calculateNewIndexes:(NSArray*) tweets withOffset:(NSInteger) previousOffset {
    NSMutableArray *newIndexes = [NSMutableArray arrayWithCapacity:tweets.count];
    for (NSInteger i = 0; i < tweets.count; i++) {
        [newIndexes addObject:[NSIndexPath indexPathForRow:(previousOffset + i) inSection:0]];
    }
    return newIndexes;
}

- (void) loadInitial {
    [[TwitterClient sharedInstance] homeTimelineWithParams:@{@"include_my_retweet" : @"true"} completion:^(NSArray *tweets, NSError *error) {
        self.tweets = tweets;
        [self.tableView reloadData];
    }];
}

- (void) loadPullToRefresh {
    if (self.tweets.count == 0) {
        [self loadInitial];
    } else {
        Tweet *firstTweet = [self.tweets firstObject];
        
        [[TwitterClient sharedInstance] homeTimelineWithParams:@{@"include_my_retweet" : @"true", @"since_id" : firstTweet.tweetId} completion:^(NSArray *tweets, NSError *error) {
            if (tweets.count > 0) {
                NSArray *newIndexes = [self calculateNewIndexes:tweets withOffset:0];
                self.tweets = [tweets arrayByAddingObjectsFromArray:self.tweets];
                [self.tableView insertRowsAtIndexPaths:newIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [self.refreshControl endRefreshing];
        }];
    }
}

- (void) loadMore {
    Tweet * lastTweet = [self.tweets lastObject];
    long long lastTweetId = [lastTweet.tweetId longLongValue];
    NSString *maxId = [NSString stringWithFormat:@"%lld", lastTweetId - 1];
    [[TwitterClient sharedInstance] homeTimelineWithParams:@{@"include_my_retweet" : @"true", @"max_id" : maxId} completion:^(NSArray *tweets, NSError *error) {
        if (tweets.count > 0) {
            NSArray *newIndexes = [self calculateNewIndexes:tweets withOffset:self.tweets.count];
            self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
            [CATransaction setDisableActions:YES];
            [self.tableView insertRowsAtIndexPaths:newIndexes withRowAnimation:UITableViewRowAnimationNone];
            [CATransaction setDisableActions:NO];
        } else {
            // reached end
            [self.loadingView stopAnimating];
        }
    }];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetDetailsController *vc = [[TweetDetailsController alloc] initWithTweet:self.tweets[indexPath.row]];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

# pragma mark - TweetCell delegate methods
- (void) onTapReply:(TweetCell *)cell {
    [self onNewTweet:cell.currentTweet];
}

- (int) findTweetIndex:(Tweet*) tweet {
    for (int i = 0; i < self.tweets.count; i++) {
        Tweet* current = self.tweets[i];
        if ([current.tweetId isEqualToString:tweet.tweetId]) {
            return i;
        }
    }
    return -1;
}

- (void) onTapFavorite:(TweetCell *)cell {
    if (cell.currentTweet.isFavorited) {
        [[TwitterClient sharedInstance] unfavorite:cell.currentTweet completion:^(Tweet *tweet, NSError *error) {
            int index = [self findTweetIndex:tweet];
            NSMutableArray *newtweets = [NSMutableArray arrayWithArray:self.tweets];
            newtweets[index] = tweet;
            self.tweets = newtweets;
            [self.tableView reloadData];
        }];
    } else {
        [[TwitterClient sharedInstance] favorite:cell.currentTweet completion:^(Tweet *tweet, NSError *error) {
            int index = [self findTweetIndex:tweet];
            NSMutableArray *newtweets = [NSMutableArray arrayWithArray:self.tweets];
            newtweets[index] = tweet;
            self.tweets = newtweets;
            [self.tableView reloadData];
        }];
    }
}

- (void) onTapRetweet:(TweetCell *)cell {
    NSLog(@"On retweet: %@", cell.currentTweet.text);
}

- (void) composeTweetController:(ComposeTweetController *)controller didPostTweet:(Tweet *)tweet {
    NSMutableArray *newTweets = [NSMutableArray arrayWithObject:tweet];
    self.tweets = [newTweets arrayByAddingObjectsFromArray:self.tweets];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) onNewTweet {
    [self onNewTweet:nil];
}

- (void) onNewTweet:(Tweet*) original {
    ComposeTweetController *vc = [[ComposeTweetController alloc] init];
    vc.delegate = self;
    vc.original = original;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (IBAction)onLogout:(id)sender {
    [[User currentUser] logout];
}

- (void) dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}
@end
