/*!
 *  SDTTabBarController.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/8/13
 */

#import "SDTTabBarController.h"

static void *SDTTabBarControllerChangeViewControllerContext = &SDTTabBarControllerChangeViewControllerContext;

static NSTimeInterval const SDTTabBarControllerAnimationDuration = 0.2;

@interface SDTTabBarControllerAnimationHandler : NSObject <UITabBarControllerDelegate>

@end

@interface SDTTabBarControllerAnimationRight : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak) UITabBarController *controller;

@end
@interface SDTTabBarControllerAnimationLeft : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak) UITabBarController *controller;

@end

@interface SDTTabBarController ()

@property (nonatomic, strong, readonly) SDTTabBarControllerAnimationHandler *animationHandler;

@end



@implementation SDTTabBarController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _animationHandler = [[SDTTabBarControllerAnimationHandler alloc] init];
        self.delegate = _animationHandler;
        
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedViewController)) options:0 context:SDTTabBarControllerChangeViewControllerContext];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedViewController)) context:SDTTabBarControllerChangeViewControllerContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == SDTTabBarControllerChangeViewControllerContext) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TabBarControllerDidChangeSelectedViewControllerNotification object:self];
        SDTStateSaverLastTab tab = LastTabForViewController((SDTViewController *)[self selectedViewController]);
        [[SDTStateSaver sharedState] setLastTab:tab];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)pickViewControllerFromLastTab:(SDTStateSaverLastTab)lastTab {
    if (lastTab == SDTStateSaverLastTabUnknown) {
        return;
    }
    for (SDTViewController *viewController in self.viewControllers) {
        if (lastTab == LastTabForViewController(viewController)) {
            [self setSelectedViewController:viewController];
            return;
        }
    }
}

@end


@implementation SDTTabBarControllerAnimationHandler

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    NSArray *viewControllers = tabBarController.viewControllers;
    
    NSUInteger toIndex = [viewControllers indexOfObject:toVC];
    NSUInteger fromIndex = [viewControllers indexOfObject:fromVC];
    
    if (!tabBarController.view.window) {
        return nil;
    }
    
    if (toIndex == fromIndex) {
        return nil;
    }
    
    if (toIndex > fromIndex) {
        SDTTabBarControllerAnimationRight *r = [[SDTTabBarControllerAnimationRight alloc] init];
        r.controller = tabBarController;
        return r;
    } else {
        SDTTabBarControllerAnimationLeft *r = [[SDTTabBarControllerAnimationLeft alloc] init];
        r.controller = tabBarController;
        return r;
    }
    
    return nil;
}

@end

@implementation SDTTabBarControllerAnimationLeft

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return SDTTabBarControllerAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [container addSubview:fromViewController.view];
    [container addSubview:toViewController.view];
    
    fromViewController.view.frame = container.bounds;
    CGRect offsetRect = container.bounds;
    offsetRect.origin.x = -CGRectGetWidth(container.frame);
    toViewController.view.frame = offsetRect;
    
    CGRect fromFinal = container.bounds;
    fromFinal.origin.x = CGRectGetWidth(fromFinal);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.frame = fromFinal;
        toViewController.view.frame = container.bounds;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end

@implementation SDTTabBarControllerAnimationRight

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return SDTTabBarControllerAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [container addSubview:fromViewController.view];
    [container addSubview:toViewController.view];
    
    fromViewController.view.frame = container.bounds;
    CGRect offsetRect = container.bounds;
    offsetRect.origin.x = CGRectGetWidth(container.frame);
    toViewController.view.frame = offsetRect;
    
    CGRect fromFinal = container.bounds;
    fromFinal.origin.x = -CGRectGetWidth(fromFinal);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.frame = fromFinal;
        toViewController.view.frame = container.bounds;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end

NSString * const TabBarControllerDidChangeSelectedViewControllerNotification = @"TabBarControllerDidChangeSelectedViewControllerNotification";
