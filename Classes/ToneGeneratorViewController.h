//
//  ToneGeneratorViewController.h
//  SoundTweak
//
//  Created by Bryan Montz on 10/30/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//
@class STSmallSlider;
#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>

@interface ToneGeneratorViewController : UIViewController {
	UILabel *_frequencyLabel;
	STSmallSlider *_slider;
	AudioComponentInstance toneUnit;
}

@property (nonatomic, retain) IBOutlet UILabel *frequencyLabel;
@property (nonatomic, retain) IBOutlet STSmallSlider *slider;

- (IBAction)sliderChangedValue:(UISlider *)aSlider;

@end
