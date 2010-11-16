//
//  SweepGeneratorViewController.m
//  SoundTweak
//
//  Created by Evan Hamilton on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import "SweepGeneratorViewController.h"
#import "AudioControlsViewController.h"
#import "NSString+Additions.h"
#import "STSmallSlider.h"

#define minTime 1
#define maxTime 30

@implementation SweepGeneratorViewController

@synthesize startFrequencySlider = _startFrequencySlider;
@synthesize endFrequencySlider = _endFrequencySlider;
@synthesize timeSlider = _timeSlider;
@synthesize startFrequencyTitleLabel = _startFrequencyTitleLabel;
@synthesize startFrequencyLabel = _startFrequencyLabel;
@synthesize endFrequencyTitleLabel = _endFrequencyTitleLabel;
@synthesize endFrequencyLabel = _endFrequencyLabel;
@synthesize timeTitleLabel = _timeTitleLabel;
@synthesize timeLabel = _timeLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.tabBarItem.image = [UIImage imageNamed:@"sweep.png"];
        self.tabBarItem.title = @"Frequency Sweep";
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[AudioControlsViewController sharedInstance].visibleViewController = self;
	
}


- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.startFrequencySlider = nil;
    self.endFrequencySlider = nil;
    self.timeSlider = nil;
	self.startFrequencyTitleLabel = nil;
    self.startFrequencyLabel = nil;
    self.endFrequencyTitleLabel = nil;
    self.endFrequencyLabel = nil;
    self.timeTitleLabel = nil;
    self.timeLabel = nil;
}


- (void)dealloc
{
	[_startFrequencySlider release], _startFrequencySlider = nil;
    [_endFrequencySlider release], _endFrequencySlider = nil;
    [_timeSlider release], _timeSlider = nil;
	[_startFrequencyTitleLabel release], _startFrequencyTitleLabel = nil;
    [_startFrequencyLabel release], _startFrequencyLabel = nil;
    [_endFrequencyTitleLabel release], _endFrequencyTitleLabel = nil;
    [_endFrequencyLabel release], _endFrequencyLabel = nil;
    [_timeTitleLabel release], _timeTitleLabel = nil;
    [_timeLabel release], _timeLabel = nil;
	
	[super dealloc];
}


- (IBAction)sliderChangedValue:(STSmallSlider *)aSlider
{
	if (aSlider == self.startFrequencySlider) {
		double power = log(minFrequency) + aSlider.value * (log(maxFrequency) - log(minFrequency));
		double frequencyInHz = exp(power);
		self.startFrequencyLabel.text = [NSString stringForFrequency:frequencyInHz];
		
	} else if (aSlider == self.endFrequencySlider) {
		double power = log(minFrequency) + aSlider.value * (log(maxFrequency) - log(minFrequency));
		double frequencyInHz = exp(power);
		self.endFrequencyLabel.text = [NSString stringForFrequency:frequencyInHz];
		
	} else {
		//must be the time slider
		NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
		[formatter setRoundingIncrement:[NSNumber numberWithInt:1]];
		self.timeLabel.text = [formatter stringFromNumber:[NSNumber numberWithDouble:minTime + aSlider.value * (maxTime - minTime)]];
	}

}


- (int)frequencyFromStartSlider
{
	//if linear
	//return self.slider.value * (maxFrequency - minFrequency) + minFrequency;
	double power = self.startFrequencySlider.value * (log(maxFrequency) - log(minFrequency)) + log(minFrequency);
	return (int)exp(power);
}

- (int)frequencyFromEndSlider
{
	//if linear
	//return self.slider.value * (maxFrequency - minFrequency) + minFrequency;
	double power = self.endFrequencySlider.value * (log(maxFrequency) - log(minFrequency)) + log(minFrequency);
	return (int)exp(power);
}

- (int)durationFromTimeSlider
{
	return ceil(minTime + self.timeSlider.value * (maxTime - minTime));
}

@end
