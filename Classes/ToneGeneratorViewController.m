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
#import "NSString+Additions.h"
#import "STSmallSlider.h"

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


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//load the last frequency
	double lastFrequency = [[NSUserDefaults standardUserDefaults] doubleForKey:kLastToneFrequency];
	if (lastFrequency > MAX_FREQUENCY || lastFrequency < MIN_FREQUENCY) {
		lastFrequency = DEFAULT_FREQUENCY;
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
	//CGFloat frequencyInHz = aSlider.value * (MAX_FREQUENCY - MIN_FREQUENCY) + MIN_FREQUENCY;
	
	//log scale
	double power = log(MIN_FREQUENCY) + aSlider.value * (log(MAX_FREQUENCY) - log(MIN_FREQUENCY));
	double frequencyInHz = exp(power);
	
	[ToneController sharedInstance].frequency = frequencyInHz;
	self.frequencyLabel.text = [NSString stringForFrequency:frequencyInHz];
}


- (void)setDisplayedFrequency:(double)frequency
{
	//set the slider position
	//if linear
	//self.slider.value = (frequency - MIN_FREQUENCY) / (MAX_FREQUENCY - MIN_FREQUENCY);
	self.slider.value = (log(frequency) - log(MIN_FREQUENCY)) / (log(MAX_FREQUENCY) - log(MIN_FREQUENCY));
	
	//set the frequency label
	self.frequencyLabel.text = [NSString stringForFrequency:frequency];
}


- (double)frequencyFromSlider
{
	//if linear
	//return self.slider.value * (MAX_FREQUENCY - MIN_FREQUENCY) + MIN_FREQUENCY;
	double power = self.slider.value * (log(MAX_FREQUENCY) - log(MIN_FREQUENCY)) + log(MIN_FREQUENCY);
	return exp(power);
}

@end
