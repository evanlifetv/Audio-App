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
#import "STTypes.h"


@interface ToneGeneratorViewController()
-(void) setFrequency: (double) frequency;
-(void) setDisplayedFrequency: (double) frequency;
-(double) frequencyFromSlider;
@end


@implementation ToneGeneratorViewController

@synthesize frequencyLabel = _frequencyLabel;
@synthesize slider = _slider;
@synthesize hotButton60 = _hotButton60;
@synthesize hotButton250 = _hotButton250;
@synthesize hotButton500 = _hotButton500;
@synthesize hotButton750 = _hotButton750;
@synthesize hotButton1000 = _hotButton1000;
@synthesize hotButton2500 = _hotButton2500;
@synthesize hotButton10k = _hotButton10k;
@synthesize hotButton18k = _hotButton18k;


#pragma mark -
#pragma mark Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.tabBarItem.image = [UIImage imageNamed:@"tone.png"];
        self.tabBarItem.title = @"Tone Generator";
    }
    return self;
}


#pragma mark -
#pragma mark Memory Management

- (void)viewDidUnload {
    [super viewDidUnload];
	
	self.frequencyLabel = nil;
	self.slider = nil;
    
    self.hotButton60 = nil;
    self.hotButton250 = nil;
    self.hotButton500 = nil;
    self.hotButton750 = nil;
    self.hotButton1000 = nil;
    self.hotButton2500 = nil;
    self.hotButton10k = nil;
    self.hotButton18k = nil;
}


- (void)dealloc {
    [_frequencyLabel release];
    [_slider release];
    
    [_hotButton60 release];
    [_hotButton250 release];
    [_hotButton500 release];
    [_hotButton750 release];
    [_hotButton1000 release];
    [_hotButton2500 release];
    [_hotButton10k release];
    [_hotButton18k release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//load the last frequency
	double lastFrequency = [[NSUserDefaults standardUserDefaults] doubleForKey:kLastToneFrequency];
	if (lastFrequency > MAX_FREQUENCY || lastFrequency < MIN_FREQUENCY) {
		lastFrequency = DEFAULT_FREQUENCY;
	}
    
    [self setFrequency: lastFrequency];
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[AudioControlsViewController sharedInstance].currentType = kSTTabTypeTone;
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSUserDefaults standardUserDefaults] setDouble:[self frequencyFromSlider] forKey:kLastToneFrequency];
	[[ToneController sharedInstance] stop];
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
	
	[self setFrequency: frequencyInHz];
}


-(IBAction) hotButtonPressed: (id) sender
{
    double freq = 0.;
    if (sender == _hotButton60) {
        freq = 60.;
    } else if (sender == _hotButton250) {
        freq = 250.;
    } else if (sender == _hotButton500) {
        freq = 500.;
    } else if (sender == _hotButton750) {
        freq = 750.;
    } else if (sender == _hotButton1000) {
        freq = 1000.;
    } else if (sender == _hotButton2500) {
        freq = 2500.;
    } else if (sender == _hotButton10k) {
        freq = 10000.;
    } else if (sender == _hotButton18k) {
        freq = 18000.;
    }
    
    [self setFrequency: freq];
}


-(void) setFrequency:(double)frequency
{
    [ToneController sharedInstance].frequency = frequency;
    [self setDisplayedFrequency: frequency];
}


-(void) setDisplayedFrequency: (double) frequency
{
	//set the slider position
	//if linear
	//self.slider.value = (frequency - MIN_FREQUENCY) / (MAX_FREQUENCY - MIN_FREQUENCY);
	self.slider.value = (log(frequency) - log(MIN_FREQUENCY)) / (log(MAX_FREQUENCY) - log(MIN_FREQUENCY));
	
	//set the frequency label
	self.frequencyLabel.text = [NSString stringForFrequency:frequency];
}


-(double) frequencyFromSlider
{
	//if linear
	//return self.slider.value * (MAX_FREQUENCY - MIN_FREQUENCY) + MIN_FREQUENCY;
	double power = self.slider.value * (log(MAX_FREQUENCY) - log(MIN_FREQUENCY)) + log(MIN_FREQUENCY);
	return exp(power);
}

@end
