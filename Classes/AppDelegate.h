//
//  AppDelegate.h
//  SoundTweak
//
//  Created by Evan Hamilton on 10/28/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

@class AudioControlsViewController;

#import <UIKit/UIKit.h>

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow					*_window;
	AudioControlsViewController	*_controlsViewController;
	UITabBarController			*_tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AudioControlsViewController *controlsViewController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end