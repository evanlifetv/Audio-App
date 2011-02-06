
#import "AudioControlsViewController.h"
#import "SweepGeneratorViewController.h"
#import "ToneGeneratorViewController.h"
#import "PlaylistViewController.h"
#import "ToneController.h"
#import "STSweep.h"
#import "MusicPlayerController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface AudioControlsViewController()
- (void)beginObserving;
- (void)generateSweep;
- (void)setDeviceVolume:(float)newVolume;
@end


@implementation AudioControlsViewController

@synthesize playButton = _playButton;
@synthesize muteButton = _muteButton;
@synthesize volumeSlider = _volumeSlider;
@synthesize visibleViewController = _visibleViewController;
@synthesize volumeView = _volumeView;


//callback function for when user changes volume via device hardware buttons
void deviceVolumeDidChange (void                      *inUserData,
							AudioSessionPropertyID    inID,
							UInt32                    inDataSize,
							const void                *inData)
{
	AudioControlsViewController *vc = (AudioControlsViewController*)inUserData;
	
	float newGain = *(float *)inData;
		
	if (newGain > 0.) {
		vc.muteButton.selected = NO;
	}
}


+ (AudioControlsViewController*)sharedInstance
{
	static AudioControlsViewController *sharedInstance;
	@synchronized(self) {
		if (!sharedInstance) {
			sharedInstance = [[AudioControlsViewController alloc] init];
		}
	}
	return sharedInstance;
}


- (void)viewDidLoad {
    [super viewDidLoad];

	//Slider Images
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"sliderbackmax-small.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage *stetchRightTrack = [[UIImage imageNamed:@"sliderbackmin-small.png"]  stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	
	UISlider *slider = nil;
	for (UIView *aView in self.volumeView.subviews) {
		if ([aView isKindOfClass:[UISlider class]]) {
			slider = (UISlider*)aView;
			
			//skin the built-in UISlider how we want it
			slider.backgroundColor = [UIColor clearColor];	
			[slider setThumbImage: [UIImage imageNamed:@"sliderthumb-small.png"] forState:UIControlStateNormal];
			[slider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
			[slider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
			[slider addTarget:self action:@selector(volumeSliderChanged) forControlEvents:UIControlEventValueChanged];
			self.volumeSlider = slider;
			
			break;
		}
	}
		
	[self beginObserving];
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    [super viewDidUnload];
    
	self.playButton = nil;
	self.muteButton = nil;
	self.volumeSlider = nil;
	self.volumeView = nil;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_playButton release];
	[_muteButton release];
	[_volumeSlider release];
    [_visibleViewController release];
	[_volumeView release];
	
    [super dealloc];
}


- (void)beginObserving
{
	AudioSessionAddPropertyListener (kAudioSessionProperty_CurrentHardwareOutputVolume,
									 deviceVolumeDidChange,
									 self);
	
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
#pragma mark Accessors

- (float)volume
{
	return self.volumeSlider.value;
}


#pragma mark -
#pragma mark Actions

- (IBAction)volumeSliderChanged
{
	if (self.volumeSlider.value > 0.) {
		self.muteButton.selected = NO;
	}
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


- (IBAction)muteButtonPressed
{
	self.muteButton.selected = !self.muteButton.selected;
	
	if (self.muteButton.selected) {
		//user wants to mute
		
		//remember the volume before muting
		UInt32 dataSize = sizeof(float);
		float currentVolume = 0.0;
		
		AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareOutputVolume,
								&dataSize,
								&currentVolume);
				
		[[NSUserDefaults standardUserDefaults] setFloat:currentVolume forKey:kLastVolumeValue];
		
		[self setDeviceVolume:0.];
		[self.volumeSlider setValue:0.];
		[[MusicPlayerController sharedInstance] setVolume:0.];
	}
	else {
		//user wants to un-mute
		float resumeVolume = [[NSUserDefaults standardUserDefaults] floatForKey:kLastVolumeValue];
		
		[self setDeviceVolume:resumeVolume];
		[self.volumeSlider setValue:resumeVolume];
		[[MusicPlayerController sharedInstance] setVolume:resumeVolume];
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


- (void)setDeviceVolume:(float)newVolume
{
	AudioSessionSetProperty(kAudioSessionProperty_CurrentHardwareOutputVolume,
							sizeof(newVolume),
							&newVolume);
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
