//
//  ComposeTweetController.h
//  Twitter
//
//  Created by Sarp Centel on 2/18/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class ComposeTweetController;

@protocol ComposeTweetControllerDelegate <NSObject>

- (void) composeTweetController:(ComposeTweetController*) controller didPostTweet:(Tweet*) tweet;

@end

@interface ComposeTweetController : UIViewController<UITextViewDelegate>

@property (strong, nonatomic) Tweet* original;
@property (nonatomic, weak) id<ComposeTweetControllerDelegate> delegate;
@end
