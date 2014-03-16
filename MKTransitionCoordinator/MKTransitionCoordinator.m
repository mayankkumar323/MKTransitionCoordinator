//
//  MKTransitionCoordinator.m
//  LazyTableViewCells
//
//  Created by Mayank Home on 3/13/14.
//  Copyright (c) 2014 Mayank Kumar. All rights reserved.
//

#import "MKTransitionCoordinator.h"

@interface MKTransitionCoordinator ()
    <UIViewControllerAnimatedTransitioning,
    UIViewControllerInteractiveTransitioning,
    UINavigationControllerDelegate>
@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@end

@implementation MKTransitionCoordinator

#pragma mark - Public Methods
-(id)initWithParentViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        _parentViewController = viewController;
        _parentViewController.navigationController.delegate = self;
        
        //Add Gesture Recognizer
        UIScreenEdgePanGestureRecognizer *gestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPanPush:)];
        gestureRecognizer.edges = UIRectEdgeRight;
        [_parentViewController.view addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

-(void)userDidPanPush:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[UIApplication sharedApplication].keyWindow];
    CGPoint velocity = [recognizer velocityInView:[UIApplication sharedApplication].keyWindow];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.interactive = YES;
        
        if (location.x > CGRectGetMidX(recognizer.view.bounds)) {
            if (!self.delegate) {
                abort(); //Delegate needs to be set
            }
            UIViewController *viewController = [self.delegate toViewControllerForInteractivePushFromPoint:location];
            UIScreenEdgePanGestureRecognizer *gestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPanPop:)];
            gestureRecognizer.edges = UIRectEdgeLeft;
            [viewController.view addGestureRecognizer:gestureRecognizer];
            
            [self.parentViewController.navigationController pushViewController:viewController animated:YES];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat ratio = 1.f - location.x / CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds);
        [self updateInteractiveTransition:ratio];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (velocity.x < 0) {
            [self finishInteractiveTransition];
        } else {
            [self cancelInteractiveTransition];
        }
    }
}

-(void)userDidPanPop:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[UIApplication sharedApplication].keyWindow];
    CGPoint velocity = [recognizer velocityInView:[UIApplication sharedApplication].keyWindow];
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.interactive = YES;
        if (location.x < CGRectGetMidX(recognizer.view.bounds)) {
            [self.parentViewController.navigationController popViewControllerAnimated:YES];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat ratio = location.x / CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds);
        [self updateInteractiveTransition:ratio];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (velocity.x > 0) {
            [self finishInteractiveTransition];
        } else {
            [self cancelInteractiveTransition];
        }
    }
}

#pragma mark - UINavigationControllerDelegate Methods
- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    if (self.interactive) {
        return self;
    }
    return nil;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPop) {
        self.presenting = NO;
    } else {
        self.presenting = YES;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning Methods
- (void)animationEnded:(BOOL)transitionCompleted {
    // Reset to our default state
    self.interactive = NO;
    self.transitionContext = nil;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Used only in non-interactive transitions
    return 0.33f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.interactive) {
        // nop as per documentation
    } else {
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        CGRect endFrame = [[transitionContext containerView] bounds];

        if (self.isPresenting) {
            [transitionContext.containerView addSubview:fromViewController.view];
            [transitionContext.containerView addSubview:toViewController.view];
        } else {
            [transitionContext.containerView addSubview:toViewController.view];
            [transitionContext.containerView addSubview:fromViewController.view];
        }
        
        CGRect startFrame = endFrame;
        startFrame.origin.x = (self.isPresenting) ? startFrame.origin.x + CGRectGetWidth([[transitionContext containerView] bounds]) : startFrame.origin.x - CGRectGetWidth([[transitionContext containerView] bounds]);
        
        toViewController.view.frame = startFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.frame = endFrame;
            if (self.presenting) {
                fromViewController.view.frame = CGRectOffset(endFrame, -CGRectGetWidth([[transitionContext containerView] bounds]), 0);
            } else {
                fromViewController.view.frame = CGRectOffset(endFrame, CGRectGetWidth([[transitionContext containerView] bounds]), 0);
            }
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

#pragma mark - UIViewControllerInteractiveTransitioning Methods
-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect fromViewFrame = [transitionContext containerView].bounds;
    CGFloat widthOffsetModifier = (self.isPresenting) ? 1 : -1;
    CGRect toViewFrame = CGRectOffset([transitionContext containerView].bounds, widthOffsetModifier * CGRectGetWidth([self.transitionContext containerView].bounds), 0);
    
    [transitionContext.containerView addSubview:fromViewController.view];
    [transitionContext.containerView addSubview:toViewController.view];
    
    fromViewController.view.frame = fromViewFrame;
    toViewController.view.frame = toViewFrame;
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods
- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [super updateInteractiveTransition:percentComplete];
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGFloat widthOffsetModifier = (self.isPresenting) ? 1 : -1;
    CGRect fromViewFrame = CGRectOffset([transitionContext containerView].bounds, -CGRectGetWidth([[transitionContext containerView] bounds]) * (percentComplete*widthOffsetModifier), 0);
    CGRect toViewFrame = fromViewFrame;
    toViewFrame.origin.x += (widthOffsetModifier*toViewFrame.size.width);
    
    fromViewController.view.frame = fromViewFrame;
    toViewController.view.frame = toViewFrame;
}

- (void)finishInteractiveTransition {
    [super finishInteractiveTransition];
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGFloat widthOffsetModifier = (self.isPresenting) ? 1 : -1;
    CGRect endFrame = CGRectOffset([transitionContext containerView].bounds, -CGRectGetWidth([transitionContext containerView].bounds)*(widthOffsetModifier), 0);
    [UIView animateWithDuration:0.5f animations:^{
        fromViewController.view.frame = endFrame;
        toViewController.view.frame = [transitionContext containerView].bounds;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

- (void)cancelInteractiveTransition {
    [super cancelInteractiveTransition];
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect fromViewFrame = [transitionContext containerView].bounds;
    CGFloat widthOffsetModifier = (self.isPresenting) ? 1 : -1;
    CGRect toViewFrame = CGRectOffset([transitionContext containerView].bounds, CGRectGetWidth([transitionContext containerView].bounds)*(widthOffsetModifier), 0);
    
    [UIView animateWithDuration:0.5f animations:^{
        fromViewController.view.frame = fromViewFrame;
        toViewController.view.frame = toViewFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:NO];
    }];
}

@end
