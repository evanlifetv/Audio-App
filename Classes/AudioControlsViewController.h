
#import <UIKit/UIKit.h>


@interface AudioControlsViewController : UIViewController {
	UIButton	*_playButton;
	UISlider	*_volumeSlider;
	id			_visibleViewController;
	UISlider	*_audioTitleSlider;
}

@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;
@property (nonatomic, retain) id visibleViewController;
@property (nonatomic, retain) IBOutlet UISlider *audioTitleSlider;

//class methods
+ (AudioControlsViewController*)sharedInstance;

//instance methods
- (float)volume;
- (IBAction)playButtonPressed;

@end
