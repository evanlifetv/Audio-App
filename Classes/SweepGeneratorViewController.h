//
//  SweepGeneratorViewController.h
//  SoundTweak
//
//  Created by Evan Hamilton on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SweepGeneratorViewController : UIViewController {
	UISlider *_startFrequencySlider;
	UISlider *_endFrequencySlider;
	UISlider *_timeSlider;
	
	UILabel *_startFrequencyTitleLabel;
	UILabel *_startFrequencyLabel;
	UILabel *_endFrequencyTitleLabel;
	UILabel *_endFrequencyLabel;
	UILabel *_timeTitleLabel;
	UILabel *_timeLabel;
}

@property (nonatomic, retain) IBOutlet UISlider *startFrequencySlider;
@property (nonatomic, retain) IBOutlet UISlider *endFrequencySlider;
@property (nonatomic, retain) IBOutlet UISlider *timeSlider;

@property (nonatomic, retain) IBOutlet UILabel *startFrequencyTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *startFrequencyLabel;
@property (nonatomic, retain) IBOutlet UILabel *endFrequencyTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *endFrequencyLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

- (IBAction)sliderChangedValue:(UISlider *)aSlider;

@end
