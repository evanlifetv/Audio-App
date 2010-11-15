//
//  AudioControlsViewController.m
//  SoundTweak
//
//  Created by Bryan Montz on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import "AudioControlsViewController.h"
#import "ToneGeneratorViewController.h"
#import "ToneController.h"

@implementation AudioControlsViewController

@synthesize playButton = _playButton;
@synthesize visibleViewController = _visibleViewController;


+ (AudioControlsViewController*)sharedInstance
{
	static AudioControlsViewController *sharedInstance;
	@synchronized(self) {
		if (!sharedInstance) {
			sharedInstance = [[AudioControlsViewController alloc] initWithNibName:@"AudioControlsViewController" bundle:nil];
		}
	}
	return sharedInstance;
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
	
	[self uiSetup];
	
}

-(void)uiSetup{
	
	//Slider Images
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"sliderback.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:0.0];
	UIImage *stetchRightTrack = [[UIImage imageNamed:@"sliderback.png"]  stretchableImageWithLeftCapWidth:20.0 topCapHeight:0.0];
	
	
	//Slider: Audio Title
	AudioTitleSlider.backgroundColor = [UIColor clearColor];	
	[AudioTitleSlider setThumbImage: [UIImage imageNamed:@"slider.png"] forState:UIControlStateNormal];
	[AudioTitleSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
	[AudioTitleSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
	AudioTitleSlider.minimumValue = 0.0;
	AudioTitleSlider.maximumValue = 100.0;
	AudioTitleSlider.continuous = YES;
	AudioTitleSlider.value = 20.0;
	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
	self.playButton = nil;
}


- (void)dealloc {
	[_playButton release], _playButton = nil;
    [_visibleViewController release], _visibleViewController = nil;
	
    [super dealloc];
}


- (IBAction)playButtonPressed
{
	if ([self.visibleViewController isKindOfClass:[ToneGeneratorViewController class]]) {
		[[ToneController sharedInstance] togglePlay];
	}
}

@end
