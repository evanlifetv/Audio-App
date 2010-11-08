//
//  ToneGeneratorViewController.m
//  SoundTweak
//
//  Created by Bryan Montz on 10/30/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import "ToneGeneratorViewController.h"
#import "AudioControlsViewController.h"
#import "ToneController.h"

#define maxFrequency 20000
#define minFrequency 20
#define defaultFrequency 1000

@interface ToneGeneratorViewController()
- (void)setDisplayedFrequency:(double)frequency;
- (double)frequencyFromSlider;
@end


@implementation ToneGeneratorViewController

@synthesize frequencyLabel = _frequencyLabel;
@synthesize slider = _slider;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.tabBarItem.image = [UIImage imageNamed:@"tone.png"];
        self.tabBarItem.title = @"Tone Generator";
    }
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overridden to allow any orientation.
    return YES;
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//load the last frequency
	double lastFrequency = [[NSUserDefaults standardUserDefaults] doubleForKey:kLastToneFrequency];
	if (lastFrequency > maxFrequency || lastFrequency < minFrequency) {
		lastFrequency = defaultFrequency;
	}
	[ToneController sharedInstance].frequency = lastFrequency;
	[self setDisplayedFrequency:lastFrequency];
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[AudioControlsViewController sharedInstance].visibleViewController = self;

}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	
	[[NSUserDefaults standardUserDefaults] setDouble:[self frequencyFromSlider] forKey:kLastToneFrequency];
}


#pragma mark -
#pragma mark Memory Management

- (void)viewDidUnload {
    [super viewDidUnload];
	
	self.frequencyLabel = nil;
	self.slider = nil;
}


- (void)dealloc {
    [_frequencyLabel release], _frequencyLabel = nil;
    [_slider release], _slider = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark Actions

- (IBAction)sliderChangedValue:(UISlider *)aSlider
{
	//if linear
	//CGFloat frequencyInHz = aSlider.value * (maxFrequency - minFrequency) + minFrequency;
	
	//log scale
	double power = log(minFrequency) + aSlider.value * (log(maxFrequency) - log(minFrequency));
	double frequencyInHz = exp(power);
	
	NSString *labelText = nil;
	if (frequencyInHz >= 1000) {
		labelText = [NSString stringWithFormat:@"%.3f kHz", frequencyInHz / 1000.0];
	} else {
		labelText = [NSString stringWithFormat:@"%.0f Hz", frequencyInHz];
	}

	[ToneController sharedInstance].frequency = frequencyInHz;
	self.frequencyLabel.text = labelText;
}


- (void)setDisplayedFrequency:(double)frequency
{
	//set the slider position
	//if linear
	//self.slider.value = (frequency - minFrequency) / (maxFrequency - minFrequency);
	self.slider.value = (log(frequency) - log(minFrequency)) / (log(maxFrequency) - log(minFrequency));
	
	//set the frequency label
	NSString *labelText = nil;
	if (frequency >= 1000) {
		labelText = [NSString stringWithFormat:@"%.3f kHz", frequency / 1000.0];
	} else {
		labelText = [NSString stringWithFormat:@"%.0f Hz", frequency];
	}
	
	self.frequencyLabel.text = labelText;
}


- (double)frequencyFromSlider
{
	//if linear
	//return self.slider.value * (maxFrequency - minFrequency) + minFrequency;
	double power = self.slider.value * (log(maxFrequency) - log(minFrequency)) + log(minFrequency);
	return exp(power);
}

@end
