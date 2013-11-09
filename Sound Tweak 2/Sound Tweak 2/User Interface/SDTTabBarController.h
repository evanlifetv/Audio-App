/*!
 * SDTTabBarController.h
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/8/13
 */

#ifndef SDTTabBarController_h
#define SDTTabBarController_h

#import <UIKit/UIKit.h>

#import "SweepGeneratorViewController.h"
#import "PinkNoiseViewController.h"
#import "MyMusicViewController.h"
#import "ToneGeneratorViewController.h"

@class SDTRootViewController;

@interface SDTTabBarController : UITabBarController

@property (nonatomic, weak) SDTRootViewController *rootViewController;

- (void)pickViewControllerFromLastTab:(SDTStateSaverLastTab)lastTab;

@end

UIKIT_EXTERN NSString * const TabBarControllerDidChangeSelectedViewControllerNotification;

NS_INLINE SDTStateSaverLastTab LastTabForViewController(SDTViewController *viewController) {
    SDTStateSaverLastTab tab = SDTStateSaverLastTabUnknown;
    
    if ([viewController isKindOfClass:[SweepGeneratorViewController class]]) {
        tab = SDTStateSaverLastTabSweepGenerator;
    }
    if ([viewController isKindOfClass:[PinkNoiseViewController class]]) {
        tab = SDTStateSaverLastTabPinkNoise;
    }
    if ([viewController isKindOfClass:[ToneGeneratorViewController class]]) {
        tab = SDTStateSaverLastTabToneGenerator;
    }
    if ([viewController isKindOfClass:[MyMusicViewController class]]) {
        tab = SDTStateSaverLastTabMyMusic;
    }
    
    return tab;
}

#endif
