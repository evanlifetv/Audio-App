
#import "AudioControlsViewController.h"
#import "SweepGeneratorViewController.h"
#import "ToneGeneratorViewController.h"
#import "PlaylistViewController.h"
#import "ToneController.h"
#import "STSweep.h"
#import "MusicPlayerController.h"


@interface AudioControlsViewController()
- (void)generateSweep;
@end


@implementation AudioControlsViewController

@synthesize playButton = _playButton;
@synthesize volumeSlider = _volumeSlider;
@synthesize visibleViewController = _visibleViewController;
@synthesize audioTitleSlider = _audioTitleSlider;


+ (AudioControlsViewController*)sharedInstance
{
	static AudioControlsViewController *sharedInstance;
	@synchronized(self) {
		if (!sharedInstance) {
			sharedInstance = [[AudioControlsViewController alloc] initWithNibName:@"AudioControlsViewController" bundle:nil];
		}
	}
	return sharedInstance;
}


- (void)viewDidLoad {
    [super viewDidLoad];

	//Slider Images
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"sliderbackmax-small.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage *stetchRightTrack = [[UIImage imageNamed:@"sliderbackmin-small.png"]  stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	
	//Slider: Audio Title
	self.audioTitleSlider.backgroundColor = [UIColor clearColor];
	[self.audioTitleSlider setThumbImage: [UIImage imageNamed:@"slider.png"] forState:UIControlStateNormal];
	[self.audioTitleSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
	[self.audioTitleSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
	self.audioTitleSlider.minimumValue = 0.0;
	self.audioTitleSlider.maximumValue = 100.0;
	self.audioTitleSlider.continuous = YES;
	self.audioTitleSlider.value = 0.0;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationDidEnterBackground)
												 name:UIApplicationDidEnterBackgroundNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(controllerDidStop)
												 name:kToneControllerDidStop
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(musicPlayerControllerDidSelectNewSong)
												 name:kMusicPlayerControllerDidSelectNewSongNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(musicPlayerControllerDidStop)
												 name:kMusicPlayerControllerDidStopNotification
											   object:nil];
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    [super viewDidUnload];
    
	self.playButton = nil;
	self.volumeSlider = nil;
	self.audioTitleSlider = nil;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_playButton release], _playButton = nil;
	[_volumeSlider release], _volumeSlider = nil;
    [_visibleViewController release], _visibleViewController = nil;
	[_audioTitleSlider release], _audioTitleSlider = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Accessors

- (float)volume
{
	return self.volumeSlider.value;
}


#pragma mark -
#pragma mark Actions

- (IBAction)volumeSliderChanged
{
	[[MusicPlayerController sharedInstance] musicPlayer].volume = self.volumeSlider.value;
}


- (IBAction)playButtonPressed
{
	if ([self.visibleViewController isKindOfClass:[SweepGeneratorViewController class]]) {
		self.playButton.selected = !self.playButton.selected;
		if ([[ToneController sharedInstance] isSweeping]) {
			[[ToneController sharedInstance] pauseSweep];
		} else {
			if ([ToneController sharedInstance].hasPausedSweep) {
				[[ToneController sharedInstance] resumePausedSweep];
			} else {
				[self generateSweep];
			}
		}
		
	}
	else if ([self.visibleViewController isKindOfClass:[ToneGeneratorViewController class]]) {
		self.playButton.selected = !self.playButton.selected;
		[[ToneController sharedInstance] togglePlay];
		
	}
	else if ([self.visibleViewController isKindOfClass:[PlaylistViewController class]]) {
		if ([[MusicPlayerController sharedInstance] currentItem]) {
			//this prevents switching the play/pause button to pause state if no song is selected
			self.playButton.selected = !self.playButton.selected;
		}
		[[MusicPlayerController sharedInstance] togglePlay];
	}
}


- (void)generateSweep
{
	SweepGeneratorViewController *vc = (SweepGeneratorViewController*)self.visibleViewController;
	
	STSweep* sweep = [STSweep sweepWithStartFrequency:[vc startFrequency]
									 currentFrequency:[vc startFrequency]
										 endFrequency:[vc endFrequency]
											 duration:[vc duration]
										 shouldRepeat:[vc.repeatSwitch isOn]];
	
	[[ToneController sharedInstance] performSelectorInBackground:@selector(playSweep:)
													  withObject:sweep];

}


#pragma mark -
#pragma mark Notification responses

- (void)applicationDidEnterBackground
{
	self.playButton.selected = NO;
}


- (void)controllerDidStop
{
	self.playButton.selected = NO;
}


- (void)musicPlayerControllerDidSelectNewSong
{
	self.playButton.selected = NO;
}


- (void)musicPlayerControllerDidStop
{
	self.playButton.selected = NO;
}

@end
