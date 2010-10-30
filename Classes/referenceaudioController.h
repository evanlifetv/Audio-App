/*
 
 
 */


#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@class CALevelMeter;

@interface referenceaudioController : NSObject <UIPickerViewDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource> {

	IBOutlet UILabel					*fileName;
	IBOutlet UIButton					*playButton;
	IBOutlet UIButton					*ffwButton;
	IBOutlet UIButton					*rewButton;
	IBOutlet UISlider					*volumeSlider;
	IBOutlet UISlider					*progressBar;
	IBOutlet UILabel					*currentTime;
	IBOutlet UILabel					*duration;
	IBOutlet CALevelMeter				*lvlMeter_in;
	
	AVAudioPlayer						*player;
	UIImage								*playBtnBG;
	UIImage								*pauseBtnBG;
	NSTimer								*updateTimer;
	NSTimer								*rewTimer;
	NSTimer								*ffwTimer;
	
	NSMutableArray						*soundFiles;
	UITableView							*soundFilesTableView;
	
	BOOL								inBackground;
}

- (IBAction)playButtonPressed:(UIButton*)sender;
- (IBAction)rewButtonPressed:(UIButton*)sender;
- (IBAction)rewButtonReleased:(UIButton*)sender;
- (IBAction)ffwButtonPressed:(UIButton*)sender;
- (IBAction)ffwButtonReleased:(UIButton*)sender;
- (IBAction)volumeSliderMoved:(UISlider*)sender;
- (IBAction)progressSliderMoved:(UISlider*)sender;

- (void)registerForBackgroundNotifications;
- (void)loadPlayerWithTrackWithFilePath:(NSString*)filePath;

@property (nonatomic, retain)	UILabel			*fileName;
@property (nonatomic, retain)	UIButton		*playButton;
@property (nonatomic, retain)	UIButton		*ffwButton;
@property (nonatomic, retain)	UIButton		*rewButton;
@property (nonatomic, retain)	UISlider		*volumeSlider;
@property (nonatomic, retain)	UISlider		*progressBar;
@property (nonatomic, retain)	UILabel			*currentTime;
@property (nonatomic, retain)	UILabel			*duration;
@property (retain)				CALevelMeter	*lvlMeter_in;

@property (nonatomic, retain)	NSTimer			*updateTimer;
@property (nonatomic, assign)	AVAudioPlayer	*player;

@property (nonatomic, retain)	NSMutableArray	*soundFiles;
@property (nonatomic, retain) IBOutlet UITableView *soundFilesTableView;


@property (nonatomic, assign)	BOOL			inBackground;
@end