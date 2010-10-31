//
//  AppDelegate.m
//  referenceaudio
//
//  Created by Evan Hamilton on 10/28/10.
//  Copyright 2010 Lifechurchtv. All rights reserved.
//

#import "AppDelegate.h"
#import "AudioControlsViewController.h"
#import "referenceaudioViewController.h"
#import "ToneGeneratorViewController.h"

@implementation referenceaudioAppDelegate

@synthesize window = _window;
@synthesize controlsViewController = _controlsViewController;
@synthesize tabBarController = _tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	self.window.backgroundColor = [UIColor blackColor];
	
	self.controlsViewController = [[[AudioControlsViewController alloc] initWithNibName:@"AudioControlsViewController" bundle:nil] autorelease];
	self.controlsViewController.view.frame = CGRectMake(0, 20, 768, 510);
	
	
    referenceaudioViewController *vc1 = [[[referenceaudioViewController alloc] initWithNibName:@"referenceaudioViewController" bundle:nil] autorelease];
	ToneGeneratorViewController *vc2 = [[[ToneGeneratorViewController alloc] initWithNibName:@"ToneGeneratorViewController" bundle:nil] autorelease];
	
	self.tabBarController.view.frame = CGRectMake(0, 530, 768, 494);
	
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:vc1, vc2, nil];
	
	[self.window addSubview:self.controlsViewController.view];
    [self.window addSubview:self.tabBarController.view];
    [self.window makeKeyAndVisible];

	return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[_window release], _window = nil;
	[_controlsViewController release], _controlsViewController = nil;
    [_tabBarController release], _tabBarController = nil;
    
    [super dealloc];
}


@end
