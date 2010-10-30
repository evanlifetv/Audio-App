//
//  referenceaudioAppDelegate.h
//  referenceaudio
//
//  Created by Evan Hamilton on 10/28/10.
//  Copyright 2010 Lifechurchtv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class referenceaudioViewController;

@interface referenceaudioAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    referenceaudioViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet referenceaudioViewController *viewController;

@end

