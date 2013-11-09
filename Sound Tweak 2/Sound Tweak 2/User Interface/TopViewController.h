/*!
 * TopViewController.h
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/8/13
 */

#ifndef TopViewController_h
#define TopViewController_h

#import "SDTViewController.h"

@class SDTRootViewController;

@interface TopViewController : SDTViewController

@property (nonatomic, weak) SDTRootViewController *rootViewController;

@end

#endif
