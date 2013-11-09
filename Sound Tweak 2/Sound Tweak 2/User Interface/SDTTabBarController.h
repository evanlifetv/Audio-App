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

@class SDTRootViewController;

@interface SDTTabBarController : UITabBarController

@property (nonatomic, weak) SDTRootViewController *rootViewController;

@end

UIKIT_EXTERN NSString * const TabBarControllerDidChangeSelectedViewControllerNotification;

#endif
