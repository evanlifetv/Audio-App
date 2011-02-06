
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AudioControlsViewController : UIViewController {
	UIButton		*_playButton;
	UIButton		*_muteButton;
	UISlider		*_volumeSlider;
	id				_visibleViewController;
	MPVolumeView	*_volumeView;
}

@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *muteButton;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;
@property (nonatomic, retain) id visibleViewController;
@property (nonatomic, retain) IBOutlet MPVolumeView *volumeView;

//class methods
+ (AudioControlsViewController*)sharedInstance;

//instance methods
- (float)volume;
- (IBAction)volumeSliderChanged;
- (IBAction)playButtonPressed;
- (IBAction)muteButtonPressed;

@end
