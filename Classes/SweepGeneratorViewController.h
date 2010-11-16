//
//  SweepGeneratorViewController.h
//  SoundTweak
//
//  Created by Evan Hamilton on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

@class STSmallSlider;

#import <Foundation/Foundation.h>

@interface SweepGeneratorViewController : UIViewController {
	STSmallSlider	*_startFrequencySlider;
	STSmallSlider	*_endFrequencySlider;
	STSmallSlider	*_timeSlider;
	UILabel		*_startFrequencyTitleLabel;
	UILabel		*_startFrequencyLabel;
	UILabel		*_endFrequencyTitleLabel;
	UILabel		*_endFrequencyLabel;
	UILabel		*_timeTitleLabel;
	UILabel		*_timeLabel;
}

@property (nonatomic, retain) IBOutlet STSmallSlider *startFrequencySlider;
@property (nonatomic, retain) IBOutlet STSmallSlider *endFrequencySlider;
@property (nonatomic, retain) IBOutlet STSmallSlider *timeSlider;
@property (nonatomic, retain) IBOutlet UILabel *startFrequencyTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *startFrequencyLabel;
@property (nonatomic, retain) IBOutlet UILabel *endFrequencyTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *endFrequencyLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

- (IBAction)sliderChangedValue:(UISlider *)aSlider;
- (int)frequencyFromStartSlider;
- (int)frequencyFromEndSlider;
- (int)durationFromTimeSlider;

@end
