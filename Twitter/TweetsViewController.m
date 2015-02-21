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
//@property (strong, nonatomic) TweetCell *currentCell;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (IBAction)onLogout:(id)sender;
@end

@implementation TweetsViewController

- (void) didUpdateTweet:(Tweet *)tweet {
    [self refresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Table view initialization
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 150.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
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
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // Fetch data
    [self refresh];
}

#pragma mark - Table view methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    [cell setTweet:self.tweets[indexPath.row]];
    cell.delegate = self;
    
//    self.currentCell = cell;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetDetailsController *vc = [[TweetDetailsController alloc] initWithTweet:self.tweets[indexPath.row]];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) refresh {
    [[TwitterClient sharedInstance] homeTimelineWithParams:@{@"include_my_retweet" : @"true"} completion:^(NSArray *tweets, NSError *error) {
        if (error == nil) {
            NSLog(@"Data loaded");
            [self.refreshControl endRefreshing];
            self.tweets = tweets;
            [self.tableView reloadData];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }];
}

# pragma mark - TweetCell delegate methods
- (void) onTapReply:(TweetCell *)cell {
    [self onNewTweet:cell.currentTweet];
}

- (void) onTapFavorite:(TweetCell *)cell {
    NSLog(@"On favorite: %@", cell.currentTweet.text);
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
    // Dispose of any resources that can be recreated.
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
@end
