//
//  TBCController.h
//  SoundTweak
//
//  Created by Bryan Montz on 2/5/11.
//  Copyright 2011 Evan Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TBCController : NSObject {

	UITabBarController *_tbc;
}

@property (nonatomic, retain) UITabBarController *tbc;

+ (id)sharedTBCController;

- (void) setToFullSize;
- (void) setToHalfSize;

@end
