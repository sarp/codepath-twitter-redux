//
//  MainViewController.m
//  Twitter
//
//  Created by Sarp Centel on 2/26/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "MainViewController.h"
#import "TweetsViewController.h"
#import "MentionsViewController.h"
#import "ProfileViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIView *subviewContainer;
@property (assign, nonatomic) CGAffineTransform oldTransform;
@property (nonatomic, strong) LeftViewController *leftController;

@property (nonatomic, strong) UINavigationController *tweetsViewController;
@property (nonatomic, strong) UINavigationController *profileViewController;
@property (nonatomic, strong) UINavigationController *mentionsViewController;

@property (nonatomic, strong) UIViewController *currentController;

- (IBAction)onPanGesture:(UIPanGestureRecognizer *)sender;

@end

@implementation MainViewController

static NSInteger const kMaxScroll = 240;
static NSInteger const kMiddle = 120;
static NSInteger const kMinScroll = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.leftController = [[LeftViewController alloc] init];
    self.leftController.delegate = self;
    
    TweetsViewController *tweetsViewController = [[TweetsViewController alloc] init];
    UINavigationController* tweetsNVC = [[UINavigationController alloc] initWithRootViewController:tweetsViewController];
    self.tweetsViewController = tweetsNVC;
    
    MentionsViewController *mentionsViewController = [[MentionsViewController alloc] init];
    UINavigationController *mentionsNVC = [[UINavigationController alloc] initWithRootViewController:mentionsViewController];
    self.mentionsViewController = mentionsNVC;
    
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    profileViewController.user = [User currentUser];
    UINavigationController *profileNVC = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    self.profileViewController = profileNVC;
    

    [self displayContentController:self.leftController];
    [self displayContentController:self.tweetsViewController];
    
    self.oldTransform = CGAffineTransformIdentity;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onPanGesture:(UIPanGestureRecognizer *)sender {
    [self.currentController.view.layer removeAllAnimations];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"State began");
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint movement = [sender translationInView:self.subviewContainer];
        NSInteger newTransform = MIN(kMaxScroll, self.oldTransform.tx + movement.x);
        newTransform = MAX(kMinScroll, newTransform);
        CGAffineTransform transform = CGAffineTransformMakeTranslation(newTransform, 0);
        self.currentController.view.transform = transform;
        NSLog(@"State changed: %@", NSStringFromCGAffineTransform(transform));
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"State ended");
        //        self.oldTransform = self.rightController.view.transform;
        // todo animate left or right depending on position
        if (self.currentController.view.transform.tx >= kMiddle) {
            [self animateWithBlock:^{
                self.currentController.view.transform = CGAffineTransformMakeTranslation(kMaxScroll, 0);
            } completion:nil];
            // go right
        } else {
            // go left
            [self animateWithBlock:^{
                self.currentController.view.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
        // CGPoint center = self.view.center;
        // NSLog(@"Center: %@", NSStringFromCGPoint(center));
    }
}

- (void) animateWithBlock:(void (^)(void))animationBlock completion:(void (^)(void)) completionBlock {
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn animations:^{
        animationBlock();
    } completion:^(BOOL finished) {
        self.oldTransform = self.currentController.view.transform;
        NSLog(@"animation completed? %@", finished  ? @"YES" : @"NO");
        
        if (completionBlock != nil) {
            completionBlock();
        }
    }];
}

- (void) displayContentController: (UIViewController*) content;
{
    [self addChildViewController:content]; // 1
    content.view.frame = [self.subviewContainer frame]; // 2
    [self.view addSubview:content.view];
    [content didMoveToParentViewController:self]; // 3
    
    self.currentController = content;
}

- (void) cycleFromViewController: (UIViewController*) oldC
                toViewController: (UIViewController*) newC
{
    [oldC willMoveToParentViewController:nil]; // 1
    [self addChildViewController:newC];
    newC.view.frame = [self.subviewContainer frame]; // 2
    CGRect endFrame = [self.subviewContainer frame];
    [self transitionFromViewController: oldC toViewController: newC // 3
                              duration: 0.1 options:0
                            animations:^{
                                newC.view.frame = oldC.view.frame; // 4
                                oldC.view.frame = endFrame;
                            }
                            completion:^(BOOL finished) {
                                [oldC removeFromParentViewController]; // 5
                                [newC didMoveToParentViewController:self];
                                self.currentController = newC;
                            }];
}

- (void) didTapController:(LeftViewController*) controller withIndexPath:(NSIndexPath*) indexPath {
    NSLog(@"didTapController: %ld", indexPath.row);
    
    if (indexPath.row == 3) {
        [[User currentUser] logout];
        return;
    }
    
    [self animateWithBlock:^{
        self.currentController.view.transform = CGAffineTransformIdentity;
    } completion:^{
        UIViewController *nextController;
        if (indexPath.row == 0) {
            nextController = self.profileViewController;
        } else if (indexPath.row == 1) {
            nextController = self.tweetsViewController;
        } else if (indexPath.row == 2){
            nextController = self.mentionsViewController;
        }
        
        if (self.currentController != nextController) {
            [self cycleFromViewController:self.currentController toViewController:nextController];
        } else {
            NSLog(@"already viewing that");
        }
    }];
}
@end
