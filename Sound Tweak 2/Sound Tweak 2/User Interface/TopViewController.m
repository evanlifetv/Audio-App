/*!
 *  TopViewController.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/8/13
 */

#import "TopViewController.h"
#import "SDTTabBarController.h"
#import "SDTRootViewController.h"

@implementation TopViewController

- (CGSize)preferredContentSize {
    // Width is ignored
    return CGSizeMake(0, 300);
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeSelectedViewController:) name:TabBarControllerDidChangeSelectedViewControllerNotification object:nil];
    }
    return self;
}

- (void)didChangeSelectedViewController:(NSNotification *)notif {
    
}

@end
