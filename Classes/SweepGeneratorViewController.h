
@class STSmallSlider;

#import <Foundation/Foundation.h>

@interface SweepGeneratorViewController : UIViewController {
	
	STSmallSlider	*_startFrequencySlider;
	STSmallSlider	*_endFrequencySlider;
	STSmallSlider	*_durationSlider;
	UILabel			*_startFrequencyTitleLabel;
	UILabel			*_startFrequencyLabel;
	UILabel			*_endFrequencyTitleLabel;
	UILabel			*_endFrequencyLabel;
	UILabel			*_durationTitleLabel;
	UILabel			*_durationLabel;
	UISwitch		*_repeatSwitch;
}

@property (nonatomic, retain) IBOutlet STSmallSlider *startFrequencySlider;
@property (nonatomic, retain) IBOutlet STSmallSlider *endFrequencySlider;
@property (nonatomic, retain) IBOutlet STSmallSlider *durationSlider;
@property (nonatomic, retain) IBOutlet UILabel *startFrequencyTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *startFrequencyLabel;
@property (nonatomic, retain) IBOutlet UILabel *endFrequencyTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *endFrequencyLabel;
@property (nonatomic, retain) IBOutlet UILabel *durationTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *durationLabel;
@property (nonatomic, retain) IBOutlet UISwitch *repeatSwitch;

- (IBAction)sliderChangedValue:(UISlider *)aSlider;
- (IBAction)repeatSwitchChangedValue:(id)aSwitch;
- (double)startFrequency;
- (double)endFrequency;
- (int)duration;

@end
