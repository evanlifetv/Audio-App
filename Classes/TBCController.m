//
//  TBCController.m
//  SoundTweak
//
//  Created by Bryan Montz on 2/5/11.
//  Copyright 2011 Evan Hamilton. All rights reserved.
//

#import "TBCController.h"
#import "AppDelegate.h"

static TBCController *__sharedInstance = nil;

@implementation TBCController

@synthesize tbc = _tbc;

#pragma mark -
#pragma mark Singleton

+ (void)initialize
{
    if (!__sharedInstance)
        __sharedInstance = [[self alloc] init];
}

+ (id)sharedTBCController
{
    //Already set by +initialize.
    return __sharedInstance;
}


#pragma mark -
#pragma mark Public Methods

- (void) setToFullSize
{
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	delegate.tabBarController.view.frame = CGRectMake(0,
												 0,
												 kIPadFullWidth,
												 kIPadFullHeight);
}


- (void) setToHalfSize
{
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	CGFloat controlsViewHeight = [delegate.controlsViewController view].frame.size.height;
	delegate.tabBarController.view.frame = CGRectMake(0,
												  kStatusBarHeight + controlsViewHeight - 1.,
												  kIPadFullWidth,
												  kIPadFullHeight - kStatusBarHeight - controlsViewHeight);
}


#pragma mark -
#pragma mark Memory management

- (void) dealloc
{
	[_tbc dealloc];
	
	[super dealloc];
}

@end
