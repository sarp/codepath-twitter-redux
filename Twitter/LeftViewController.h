//
//  LeftViewController.h
//  Twitter
//
//  Created by Sarp Centel on 2/26/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LeftViewController;

@protocol NavigationDelegate <NSObject>

- (void) didTapController:(LeftViewController*) controller withIndexPath:(NSIndexPath*) indexPath;

@end

@interface LeftViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) id<NavigationDelegate> delegate;

@end
