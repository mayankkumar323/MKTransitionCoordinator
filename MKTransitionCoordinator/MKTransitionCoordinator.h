//
//  MKTransitionCoordinator.h
//  LazyTableViewCells
//
//  Created by Mayank Home on 3/13/14.
//  Copyright (c) 2014 Mayank Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MKTransitionCoordinatorDelegate <NSObject>
@required
- (UIViewController*) toViewControllerForInteractivePushFromPoint:(CGPoint)locationInWindow;
@end

@interface MKTransitionCoordinator : UIPercentDrivenInteractiveTransition

@property (nonatomic, readonly) UIViewController *parentViewController;
@property (nonatomic, weak) id<MKTransitionCoordinatorDelegate> delegate;

- (id)initWithParentViewController:(UIViewController *)viewController;

@end
