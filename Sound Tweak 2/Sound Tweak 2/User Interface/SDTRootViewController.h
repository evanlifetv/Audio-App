/*!
 * SDTRootViewController.h
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/8/13
 */

#ifndef SDTRootViewController_h
#define SDTRootViewController_h

#import "SDTViewController.h"
#import "TopViewController.h"
#import "SDTTabBarController.h"

@interface SDTRootViewController : SDTViewController

- (instancetype)initWithTopViewController:(TopViewController *)topViewController sectionViewController:(SDTTabBarController *)sectionViewController;

@property (nonatomic, weak, readonly) TopViewController *topViewController;
@property (nonatomic, weak, readonly) SDTTabBarController *sectionViewController;

- (UIViewController *)currentTabViewController;

@end

#endif
