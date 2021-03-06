//
//  TweetsViewController.h
//  Twitter
//
//  Created by Sarp Centel on 2/18/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeTweetController.h"
#import "TweetCell.h"
#import "TweetDetailsController.h"

@interface TweetsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ComposeTweetControllerDelegate, TweetCellDelegate, TweetDetailsDelegate>

@end
