
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "STTypes.h"

@interface AudioControlsViewController : UIViewController {
	UIButton		*_playButton;
	UIButton		*_muteButton;
	UISlider		*_volumeSlider;
	MPVolumeView	*_volumeView;
    
    STTabType       _currentType;
}

@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *muteButton;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;
@property (nonatomic, retain) IBOutlet MPVolumeView *volumeView;

@property (nonatomic, assign) STTabType currentType;

+ (AudioControlsViewController*)sharedInstance;

- (float)volume;
- (IBAction)volumeSliderChanged;
- (IBAction)playButtonPressed;
- (IBAction)muteButtonPressed;

@end
