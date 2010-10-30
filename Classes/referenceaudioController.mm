/*
 

 
 */


#import "referenceaudioController.h"
#include "CALevelMeter.h"

// amount to skip on rewind or fast forward
#define SKIP_TIME 1.0			
// amount to play between skips
#define SKIP_INTERVAL .2

@implementation referenceaudioController

@synthesize fileName;
@synthesize playButton;
@synthesize ffwButton;
@synthesize rewButton;
@synthesize volumeSlider;
@synthesize progressBar;
@synthesize currentTime;
@synthesize duration;
@synthesize lvlMeter_in;

@synthesize updateTimer;
@synthesize player;

@synthesize soundFiles;
@synthesize soundFilesTableView;

@synthesize inBackground;


void RouteChangeListener(	void *                  inClientData,
							AudioSessionPropertyID	inID,
							UInt32                  inDataSize,
							const void *            inData);
															
-(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)p
{
	currentTime.text = [NSString stringWithFormat:@"%d:%02d", (int)p.currentTime / 60, (int)p.currentTime % 60, nil];
	progressBar.value = p.currentTime;
}

- (void)updateCurrentTime
{
	[self updateCurrentTimeForPlayer:self.player];
}

- (void)updateViewForPlayerState:(AVAudioPlayer *)p
{
	[self updateCurrentTimeForPlayer:p];

	if (updateTimer) 
		[updateTimer invalidate];
		
	if (p.playing)
	{
		[playButton setImage:((p.playing == YES) ? pauseBtnBG : playBtnBG) forState:UIControlStateNormal];
		[lvlMeter_in setPlayer:p];
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:p repeats:YES];
	}
	else
	{
		[playButton setImage:((p.playing == YES) ? pauseBtnBG : playBtnBG) forState:UIControlStateNormal];
		[lvlMeter_in setPlayer:nil];
		updateTimer = nil;
	}
	
}

- (void)updateViewForPlayerStateInBackground:(AVAudioPlayer *)p
{
	[self updateCurrentTimeForPlayer:p];
	
	if (p.playing)
	{
		[playButton setImage:((p.playing == YES) ? pauseBtnBG : playBtnBG) forState:UIControlStateNormal];
	}
	else
	{
		[playButton setImage:((p.playing == YES) ? pauseBtnBG : playBtnBG) forState:UIControlStateNormal];
	}	
}

-(void)updateViewForPlayerInfo:(AVAudioPlayer*)p
{
	duration.text = [NSString stringWithFormat:@"%d:%02d", (int)p.duration / 60, (int)p.duration % 60, nil];
	progressBar.maximumValue = p.duration;
	volumeSlider.value = p.volume;
}

- (void)rewind
{
	AVAudioPlayer *p = rewTimer.userInfo;
	p.currentTime-= SKIP_TIME;
	[self updateCurrentTimeForPlayer:p];
}

- (void)ffwd
{
	AVAudioPlayer *p = ffwTimer.userInfo;
	p.currentTime+= SKIP_TIME;	
	[self updateCurrentTimeForPlayer:p];
}

- (void)awakeFromNib
{
	self.soundFiles = [NSMutableArray arrayWithArray:[[NSBundle mainBundle] pathsForResourcesOfType:@"m4a" inDirectory:nil]];
	[self.soundFilesTableView reloadData];
	
	for (NSString *filepath in self.soundFiles) {
		NSLog(@"name is %@", [filepath lastPathComponent]);
	}
	
	
	// Make the array to store our AVAudioPlayer objects
	//soundFiles = [[NSMutableArray alloc] initWithCapacity:3];

	playBtnBG = [[UIImage imageNamed:@"play.png"] retain];
	pauseBtnBG = [[UIImage imageNamed:@"pause.png"] retain];

	[playButton setImage:playBtnBG forState:UIControlStateNormal];
	
	[self registerForBackgroundNotifications];
			
	updateTimer = nil;
	rewTimer = nil;
	ffwTimer = nil;
	
	duration.adjustsFontSizeToFitWidth = YES;
	currentTime.adjustsFontSizeToFitWidth = YES;
	progressBar.minimumValue = 0.0;	
	
	// Load the array with the sample file
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"57 Frequency Sweep - 20 Hz To 20 kHz Upwards" ofType:@"m4a"]];

	self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];	
	if (self.player)
	{
		fileName.text = [NSString stringWithFormat: @"%@ (%d ch.)", [[player.url relativePath] lastPathComponent], player.numberOfChannels, nil];
		[self updateViewForPlayerInfo:player];
		[self updateViewForPlayerState:player];
		player.numberOfLoops = 1;
		player.delegate = self;
	}
	
	OSStatus result = AudioSessionInitialize(NULL, NULL, NULL, NULL);
	if (result)
		NSLog(@"Error initializing audio session! %d", result);
	
	[[AVAudioSession sharedInstance] setDelegate: self];
	NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
	if (setCategoryError)
		NSLog(@"Error setting category! %d", setCategoryError);
	
	result = AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, RouteChangeListener, self);
	if (result) 
		NSLog(@"Could not add property listener! %d", result);
	
	[fileURL release];
}

-(void)pausePlaybackForPlayer:(AVAudioPlayer*)p
{
	[p pause];
	[self updateViewForPlayerState:p];
}

-(void)startPlaybackForPlayer:(AVAudioPlayer*)p
{
	if ([p play])
	{
		[self updateViewForPlayerState:p];
	}
	else
		NSLog(@"Could not play %@\n", p.url);
}

- (IBAction)playButtonPressed:(UIButton *)sender
{	
	if (player.playing == YES)
		[self pausePlaybackForPlayer: player];
	else
		[self startPlaybackForPlayer: player];
}

- (IBAction)rewButtonPressed:(UIButton *)sender
{
	if (rewTimer) [rewTimer invalidate];
	rewTimer = [NSTimer scheduledTimerWithTimeInterval:SKIP_INTERVAL target:self selector:@selector(rewind) userInfo:player repeats:YES];
}

- (IBAction)rewButtonReleased:(UIButton *)sender
{
	if (rewTimer) [rewTimer invalidate];
	rewTimer = nil;
}

- (IBAction)ffwButtonPressed:(UIButton *)sender
{
	if (ffwTimer) [ffwTimer invalidate];
	ffwTimer = [NSTimer scheduledTimerWithTimeInterval:SKIP_INTERVAL target:self selector:@selector(ffwd) userInfo:player repeats:YES];
}

- (IBAction)ffwButtonReleased:(UIButton *)sender
{
	if (ffwTimer) [ffwTimer invalidate];
	ffwTimer = nil;
}

- (IBAction)volumeSliderMoved:(UISlider *)sender
{
	player.volume = [sender value];
}

- (IBAction)progressSliderMoved:(UISlider *)sender
{
	player.currentTime = sender.value;
	[self updateCurrentTimeForPlayer:player];
}

- (void)dealloc
{
	[fileName release];
	[playButton release];
	[ffwButton release];
	[rewButton release];
	[volumeSlider release];
	[progressBar release];
	[currentTime release];
	[duration release];
	[lvlMeter_in release];
	
	[updateTimer release];
	[player release];
	
	[soundFiles release];
	[soundFilesTableView release], soundFilesTableView = nil;
	
	[playBtnBG release];
	[pauseBtnBG release];
	
	[super dealloc];
}

#pragma mark AudioSession handlers

void RouteChangeListener(	void *                  inClientData,
							AudioSessionPropertyID	inID,
							UInt32                  inDataSize,
							const void *            inData)
{
	referenceaudioController* This = (referenceaudioController*)inClientData;
	
	if (inID == kAudioSessionProperty_AudioRouteChange) {
		
		CFDictionaryRef routeDict = (CFDictionaryRef)inData;
		NSNumber* reasonValue = (NSNumber*)CFDictionaryGetValue(routeDict, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		
		int reason = [reasonValue intValue];

		if (reason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {

			[This pausePlaybackForPlayer:This.player];
		}
	}
}

#pragma mark AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag
{
	if (flag == NO)
		NSLog(@"Playback finished unsuccessfully");
		
	[p setCurrentTime:0.];
	[self updateViewForPlayerState:p];
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error); 
}

// we will only get these notifications if playback was interrupted
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)p
{
	NSLog(@"Interruption begin. Updating UI for new state");
	// the object has already been paused,	we just need to update UI
	if (inBackground)
	{
		[self updateViewForPlayerStateInBackground:p];
	}
	else
	{
		[self updateViewForPlayerState:p];
	}
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)p
{
	NSLog(@"Interruption ended. Resuming playback");
	[self startPlaybackForPlayer:p];
}

#pragma mark background notifications
- (void)registerForBackgroundNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(setInBackgroundFlag)
												 name:UIApplicationWillResignActiveNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(clearInBackgroundFlag)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}

- (void)setInBackgroundFlag
{
	inBackground = true;
}

- (void)clearInBackgroundFlag
{
	inBackground = false;
}

- (void)loadPlayerWithTrackWithFilePath:(NSString*)filePath
{
	// Load the array with the sample file
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: filePath];
	
	self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];	
	if (self.player)
	{
		fileName.text = [NSString stringWithFormat: @"%@ (%d ch.)", [[player.url relativePath] lastPathComponent], player.numberOfChannels, nil];
		[self updateViewForPlayerInfo:player];
		[self updateViewForPlayerState:player];
		player.numberOfLoops = 1;
		player.delegate = self;
	}
	
	OSStatus result = AudioSessionInitialize(NULL, NULL, NULL, NULL);
	if (result)
		NSLog(@"Error initializing audio session! %d", result);
	
	[[AVAudioSession sharedInstance] setDelegate: self];
	NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
	if (setCategoryError)
		NSLog(@"Error setting category! %d", setCategoryError);
	
	result = AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, RouteChangeListener, self);
	if (result) 
		NSLog(@"Could not add property listener! %d", result);
	
	[fileURL release];
}

#pragma mark -
#pragma mark TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; 
{
	if (!self.soundFiles) {
		return 0;
	}
	return 1;
}


- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	if (!self.soundFiles) {
		return 0;
	}
	return [self.soundFiles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.soundFiles || [self.soundFiles count] == 0) {
		return nil;
	}
	
	static NSString *cellID = @"soundFileCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	}
	
	NSString *filepath = (NSString*)[self.soundFiles objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [filepath lastPathComponent];
	
	return cell;
}


#pragma mark -
#pragma mark TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.player stop];  //stop current playback
	
	NSString *filepath = (NSString*)[self.soundFiles objectAtIndex:indexPath.row];
	self.fileName.text = [filepath lastPathComponent];
	
	[self loadPlayerWithTrackWithFilePath:filepath];
}

@end