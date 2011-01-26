
#import "AppDelegate.h"
#import "AudioControlsViewController.h"
#import "ToneGeneratorViewController.h"
#import "PinkNoiseViewController.h"
#import "SweepGeneratorViewController.h"
#import "SupportViewController.h"
#import "PlaylistViewController.h"


@interface AppDelegate()
- (void)saveState;
- (void)restoreState;
@end


@implementation AppDelegate

@synthesize window = _window;
@synthesize controlsViewController = _controlsViewController;
@synthesize tabBarController = _tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	self.window.backgroundColor = [UIColor blackColor];
	
	UIImageView *img = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab-bar-background.png"]] autorelease];
    [self.tabBarController.tabBar insertSubview:img atIndex:0];

	//initialize the audio controls view (top half of the screen)
	self.controlsViewController = [AudioControlsViewController sharedInstance];
	self.controlsViewController.view.frame = CGRectMake(0, kStatusBarHeight, kIPadFullWidth, kControlsViewHeight);
	
	//initialize each view controller that will be a tab in the tab bar controller
	SweepGeneratorViewController *sweep = [[[SweepGeneratorViewController alloc] initWithNibName:@"SweepGeneratorViewController" bundle:nil] autorelease];
	ToneGeneratorViewController *tone = [[[ToneGeneratorViewController alloc] initWithNibName:@"ToneGeneratorViewController" bundle:nil] autorelease];
	PinkNoiseViewController *pink = [[[PinkNoiseViewController alloc] initWithNibName:@"PinkNoiseViewController" bundle:nil] autorelease];
    PlaylistViewController *playlist = [[[PlaylistViewController alloc] initWithNibName:@"PlaylistViewController" bundle:nil] autorelease];
	SupportViewController *support = [[[SupportViewController alloc] initWithNibName:@"SupportViewController" bundle:nil] autorelease];
	
	//set the tab bar controller's view to the bottom half of the screen
	self.tabBarController.view.frame = CGRectMake(0, kStatusBarHeight + kControlsViewHeight - 1., kIPadFullWidth, kIPadFullHeight - kStatusBarHeight - kControlsViewHeight);
	
	//create an array out of the view controllers and give them to the tab bar controller
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:sweep, tone, pink, playlist, support, nil];
	
	//add the audio controls view (top half)
	[self.window addSubview:self.controlsViewController.view];
	//add the tab bar controllers view (bottom half)
    [self.window addSubview:self.tabBarController.view];
	
	[self restoreState];
	
    [self.window makeKeyAndVisible];

	return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[self saveState];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	[self saveState];
}


- (void)saveState
{
	[[NSUserDefaults standardUserDefaults] setInteger:self.tabBarController.selectedIndex forKey:kLastSelectedTabIndex];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)restoreState
{
	self.tabBarController.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kLastSelectedTabIndex];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[_window release], _window = nil;
	[_controlsViewController release], _controlsViewController = nil;
    [_tabBarController release], _tabBarController = nil;
    
    [super dealloc];
}


@end
