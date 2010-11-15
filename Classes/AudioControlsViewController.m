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
@synthesize volumeSlider = _volumeSlider;
@synthesize visibleViewController = _visibleViewController;
@synthesize audioTitleSlider = _audioTitleSlider;


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


- (void)viewDidLoad {
    [super viewDidLoad];

	//Slider Images
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"sliderback.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:0.0];
	UIImage *stetchRightTrack = [[UIImage imageNamed:@"sliderback.png"]  stretchableImageWithLeftCapWidth:20.0 topCapHeight:0.0];
	
	//Slider: Audio Title
	self.audioTitleSlider.backgroundColor = [UIColor clearColor];	
	[self.audioTitleSlider setThumbImage: [UIImage imageNamed:@"slider.png"] forState:UIControlStateNormal];
	[self.audioTitleSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
	[self.audioTitleSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
	self.audioTitleSlider.minimumValue = 0.0;
	self.audioTitleSlider.maximumValue = 100.0;
	self.audioTitleSlider.continuous = YES;
	self.audioTitleSlider.value = 20.0;
}


- (float)volume
{
	return self.volumeSlider.value;
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
	self.playButton = nil;
	self.volumeSlider = nil;
	self.audioTitleSlider = nil;
}


- (void)dealloc {
	[_playButton release], _playButton = nil;
	[_volumeSlider release], _volumeSlider = nil;
    [_visibleViewController release], _visibleViewController = nil;
	[_audioTitleSlider release], _audioTitleSlider = nil;
    [super dealloc];
}


- (IBAction)playButtonPressed
{
	if ([self.visibleViewController isKindOfClass:[ToneGeneratorViewController class]]) {
		[[ToneController sharedInstance] togglePlay];
	}
}

@end
