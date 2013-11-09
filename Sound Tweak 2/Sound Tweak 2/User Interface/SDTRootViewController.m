/*!
 *  SDTRootViewController.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/8/13
 */

#import "SDTRootViewController.h"

@interface SDTRootViewController ()

@property (nonatomic, weak) UIView *topContentView;
@property (nonatomic, weak) UIView *sectionContentView;
@property (nonatomic, weak) UIView *separatorView;

@end

@implementation SDTRootViewController

- (instancetype)initWithTopViewController:(TopViewController *)topViewController sectionViewController:(SDTTabBarController *)sectionViewController {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        [self setupTopViewController:topViewController];
        [self setupSectionViewController:sectionViewController];
    }
    return self;
}

#pragma mark -
#pragma mark - Style
+ (void)initialize {
    [[UITabBar appearanceWhenContainedIn:[self class], nil] setTintColor:[UIColor soundTweakPurple]];
}

#pragma mark -
#pragma mark - Helpers
- (UIViewController *)currentTabViewController {
    return [self.sectionViewController selectedViewController];
}

#pragma mark -
#pragma mark - Layout
- (void)updateViewConstraints {
    [self.view removeConstraints:self.view.constraints];
    [super updateViewConstraints];
    
    
    
    NSDictionary *metrics = @{
                              @"height": @([_topViewController preferredContentSize].height)
                              };
    NSDictionary *views = @{
                            @"tv": self.topContentView,
                            @"sv": self.sectionContentView,
                            @"sep": self.separatorView
                            };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tv]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sv]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sep]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tv(==height)][sep(==1)][sv]|" options:0 metrics:metrics views:views]];
}


#pragma mark -
#pragma mark - Setup
- (void)setupTopViewController:(TopViewController *)topViewController {
    _topViewController = topViewController;
    [self addChildViewController:topViewController];
    
    [self.topContentView addSubview:_topViewController.view];
    _topViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"v": _topViewController.view};
    [self.topContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:views]];
    [self.topContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:0 metrics:nil views:views]];
    
    [topViewController didMoveToParentViewController:self];
    [self.view setNeedsUpdateConstraints];
    
    _topViewController.rootViewController = self;
}
- (void)setupSectionViewController:(SDTTabBarController *)sectionToolbarController {
    _sectionViewController = sectionToolbarController;
    [self addChildViewController:sectionToolbarController];
    
    [self.sectionContentView addSubview:_sectionViewController.view];
    _sectionViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"v": _sectionViewController.view};
    [self.sectionContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:views]];
    [self.sectionContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:0 metrics:nil views:views]];
    
    [sectionToolbarController didMoveToParentViewController:self];
    [self.view setNeedsUpdateConstraints];
    
    _sectionViewController.rootViewController = self;
}

#pragma mark -
#pragma mark - Lazy Loaders
- (UIView *)topContentView {
    if (!_topContentView) {
        UIView *v = [[UIView alloc] init];
        v.translatesAutoresizingMaskIntoConstraints = NO;
        v.backgroundColor = [UIColor whiteColor];
        
        
        _topContentView = v;
        [self.view addSubview:v];
    }
    return _topContentView;
}
- (UIView *)sectionContentView {
    if (!_sectionContentView) {
        UIView *v = [[UIView alloc] init];
        v.translatesAutoresizingMaskIntoConstraints = NO;
        v.backgroundColor = [UIColor whiteColor];
        
        _sectionContentView = v;
        [self.view addSubview:v];
    }
    return _sectionContentView;
}
- (UIView *)separatorView {
    if (!_separatorView) {
        UIView *v = [[UIView alloc] init];
        v.translatesAutoresizingMaskIntoConstraints = NO;
        v.backgroundColor = [UIColor lightGrayColor];
        
        _separatorView = v;
        [self.view addSubview:v];
    }
    return _separatorView;
}

@end
