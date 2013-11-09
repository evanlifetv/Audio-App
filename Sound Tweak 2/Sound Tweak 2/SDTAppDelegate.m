//
//  SDTAppDelegate.m
//  Sound Tweak 2
//
//  Created by Skylar Schipper on 11/8/13.
//  Copyright (c) 2013 OpenSky, LLC. All rights reserved.
//

#import "SDTAppDelegate.h"

// View Controllers
#import "SDTRootViewController.h"
#import "SDTTabBarController.h"
#import "UIDevice+SDTDevice.h"

@implementation SDTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [OSDCoreDataManager setManagedObjectModelName:@"SoundTweak"];
    
    [self setupMainInterface];
    return YES;
}

- (void)setupMainInterface {
    if (!_window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.backgroundColor = [UIColor whiteColor];
    }
    
    SDTTabBarController *tabBar = [[SDTTabBarController alloc] initWithNibName:nil bundle:nil];
    tabBar.viewControllers = [self viewControllersForTabBarController:tabBar];
    
    TopViewController *top = [[TopViewController alloc] initWithNibName:@"TopViewController" bundle:nil];
    
    SDTRootViewController *root = [[SDTRootViewController alloc] initWithTopViewController:top sectionViewController:tabBar];
    [tabBar pickViewControllerFromLastTab:[[SDTStateSaver sharedState] lastTab]];
    
    self.window.rootViewController = root;
    
    if (![self.window isKeyWindow]) {
        [self.window makeKeyAndVisible];
    }
}

- (NSArray *)viewControllersForTabBarController:(SDTTabBarController *)controller {
    return @[
             [[SweepGeneratorViewController alloc] initWithNibName:@"SweepGeneratorViewController" bundle:nil],
             [[ToneGeneratorViewController alloc] initWithNibName:@"ToneGeneratorViewController" bundle:nil],
             [[PinkNoiseViewController alloc] initWithNibName:@"PinkNoiseViewController" bundle:nil],
             [[MyMusicViewController alloc] initWithNibName:@"MyMusicViewController" bundle:nil]
             ];
}

@end
