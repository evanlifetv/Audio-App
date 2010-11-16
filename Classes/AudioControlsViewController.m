//
//  AudioControlsViewController.m
//  SoundTweak
//
//  Created by Bryan Montz on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import "AudioControlsViewController.h"
#import "SweepGeneratorViewController.h"
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


- (void)viewDidLoad {
    [super viewDidLoad];

	//Slider Images
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"sliderbackmax-small.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage *stetchRightTrack = [[UIImage imageNamed:@"sliderbackmin-small.png"]  stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	
	//Slider: Audio Title
	self.audioTitleSlider.backgroundColor = [UIColor clearColor];
	[self.audioTitleSlider setThumbImage: [UIImage imageNamed:@"slider.png"] forState:UIControlStateNormal];
	[self.audioTitleSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
	[self.audioTitleSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
	self.audioTitleSlider.minimumValue = 0.0;
	self.audioTitleSlider.maximumValue = 100.0;
	self.audioTitleSlider.continuous = YES;
	self.audioTitleSlider.value = 0.0;
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
	self.playButton.selected = !self.playButton.selected;
	
	if ([self.visibleViewController isKindOfClass:[SweepGeneratorViewController class]]) {
		[self performSelectorInBackground:@selector(generateSweep) withObject:nil];
		
	} else 
		if ([self.visibleViewController isKindOfClass:[ToneGeneratorViewController class]]) {
		[[ToneController sharedInstance] togglePlay];
	}
}

- (void)generateSweep
{
	SweepGeneratorViewController *vc = (SweepGeneratorViewController*)self.visibleViewController;
	[[ToneController sharedInstance] sweepFromFrequency:[vc frequencyFromStartSlider]
												toFrequency:[vc frequencyFromEndSlider]
											   withDuration:[vc durationFromTimeSlider]];
}

@end
