
#import "AudioControlsViewController.h"
#import "SweepGeneratorViewController.h"
#import "ToneGeneratorViewController.h"
#import "PlaylistViewController.h"
#import "ToneController.h"
#import "STSweep.h"
#import "MusicPlayerController.h"
#import "PinkNoiseController.h"
#import <AudioToolbox/AudioToolbox.h>


//FFT --------------------------------------------------
#import "AudioUnit/AudioUnit.h"
#import "CAXException.h"
//FFT --------------------------------------------------

@interface AudioControlsViewController()
- (void)beginObserving;
- (void)generateSweep;
- (void)setDeviceVolume:(float)newVolume;
@end


@implementation AudioControlsViewController

@synthesize playButton = _playButton;
@synthesize muteButton = _muteButton;
@synthesize volumeSlider = _volumeSlider;
@synthesize volumeView = _volumeView;
@synthesize currentType = _currentType;

//FFT --------------------------------------------------
// value, a, r, g, b
GLfloat colorLevels[] = {
    0., 1., 0., 0., 0., 
    .333, 1., .7, 0., 0., 
    .667, 1., 0., 0., 1., 
    1., 1., 0., 1., 1., 
};

@synthesize fftView;

@synthesize rioUnit;
@synthesize unitIsRunning;
@synthesize unitHasBeenCreated;
@synthesize displayMode;
@synthesize fftBufferManager;
@synthesize mute;
@synthesize inputProc;

//Forward declarationss
static OSStatus	PerformThru(
							void						*inRefCon, 
							AudioUnitRenderActionFlags 	*ioActionFlags, 
							const AudioTimeStamp 		*inTimeStamp, 
							UInt32 						inBusNumber, 
							UInt32 						inNumberFrames, 
							AudioBufferList 			*ioData);

void rioInterruptionListener(void *inClientData, UInt32 inInterruption);

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData);

CGPathRef CreateRoundedRectPath(CGRect RECT, CGFloat cornerRadius);
//FFT --------------------------------------------------


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


-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) ) {
        
    }
    return self;
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
    
    self.volumeView.showsRouteButton = NO;
    
    //FFT --------------------------------------------------
    displayMode = aurioTouchDisplayModeOscilloscopeFFT;
	
	// Initialize our remote i/o unit
	
	inputProc.inputProc = PerformThru;
	inputProc.inputProcRefCon = self;
    
	CFURLRef url = NULL;
	try {	
		// Initialize and configure the audio session
		XThrowIfError(AudioSessionInitialize(NULL, NULL, rioInterruptionListener, self), "couldn't initialize audio session");
        
		UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
		XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory), "couldn't set audio category");
		XThrowIfError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self), "couldn't set property listener");
        
		Float32 preferredBufferSize = .005;
		XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize), "couldn't set i/o buffer duration");
		
		UInt32 size = sizeof(hwSampleRate);
		XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &hwSampleRate), "couldn't get hw sample rate");
		
        //override the audio category to allow mixing (corrects issue with MPMusicPlayerController interrupting the recording for FFT)
        OSStatus propertySetError = 0;
        UInt32 allowMixing = true;
        
        propertySetError = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers,
                                                    sizeof (allowMixing),
                                                    &allowMixing);
        
		XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
        
		XThrowIfError(SetupRemoteIO(rioUnit, inputProc, thruFormat), "couldn't setup remote i/o unit");
		unitHasBeenCreated = true;
		
		dcFilter = new DCRejectionFilter[thruFormat.NumberChannels()];
        
		UInt32 maxFPS;
		size = sizeof(maxFPS);
		XThrowIfError(AudioUnitGetProperty(rioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFPS, &size), "couldn't get the remote I/O unit's max frames per slice");
		
		fftBufferManager = new FFTBufferManager(maxFPS);
		l_fftData = new int32_t[maxFPS/2];
		
		oscilLine = (GLfloat*)malloc(drawBufferLen * 2 * sizeof(GLfloat));
        
		XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
        
		size = sizeof(thruFormat);
		XThrowIfError(AudioUnitGetProperty(rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &thruFormat, &size), "couldn't get the remote I/O unit's output client format");
		
		unitIsRunning = 1;
	}
	catch (CAXException &e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		unitIsRunning = 0;
		if (dcFilter) delete[] dcFilter;
		if (url) CFRelease(url);
	}
	catch (...) {
		fprintf(stderr, "An unknown error occurred\n");
		unitIsRunning = 0;
		if (dcFilter) delete[] dcFilter;
		if (url) CFRelease(url);
	}
	
	// Set ourself as the delegate for the EAGLView so that we get drawing and touch events
	fftView.delegate = self;
	
	// Enable multi touch so we can handle pinch and zoom in the oscilloscope
	fftView.multipleTouchEnabled = YES;
	
	// Set up our overlay view that pops up when we are pinching/zooming the oscilloscope
	UIImage *img_ui = nil;
	{
		// Draw the rounded rect for the bg path using this convenience function
		CGPathRef bgPath = CreateRoundedRectPath(CGRectMake(0, 0, 110, 234), 15.);
		
		CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
		// Create the bitmap context into which we will draw
		CGContextRef cxt = CGBitmapContextCreate(NULL, 110, 234, 8, 4*110, cs, kCGImageAlphaPremultipliedFirst);
		CGContextSetFillColorSpace(cxt, cs);
		CGFloat fillClr[] = {0., 0., 0., 0.7};
		CGContextSetFillColor(cxt, fillClr);
		// Add the rounded rect to the context...
		CGContextAddPath(cxt, bgPath);
		// ... and fill it.
		CGContextFillPath(cxt);
		
		// Make a CGImage out of the context
		CGImageRef img_cg = CGBitmapContextCreateImage(cxt);
		// Make a UIImage out of the CGImage
		img_ui = [UIImage imageWithCGImage:img_cg];
		
		// Clean up
		CGImageRelease(img_cg);
		CGColorSpaceRelease(cs);
		CGContextRelease(cxt);
		CGPathRelease(bgPath);
	}
	
	// Create the image view to hold the background rounded rect which we just drew
	sampleSizeOverlay = [[UIImageView alloc] initWithImage:img_ui];
	sampleSizeOverlay.frame = CGRectMake(190, 124, 110, 234);
	
	// Create the text view which shows the size of our oscilloscope window as we pinch/zoom
	sampleSizeText = [[UILabel alloc] initWithFrame:CGRectMake(-62, 0, 234, 234)];
	sampleSizeText.textAlignment = UITextAlignmentCenter;
	sampleSizeText.textColor = [UIColor whiteColor];
	sampleSizeText.text = @"0000 ms";
	sampleSizeText.font = [UIFont boldSystemFontOfSize:36.];
	// Rotate the text view since we want the text to draw top to bottom (when the device is oriented vertically)
	sampleSizeText.transform = CGAffineTransformMakeRotation(M_PI_2);
	sampleSizeText.backgroundColor = [UIColor clearColor];
	
	// Add the text view as a subview of the overlay BG
	[sampleSizeOverlay addSubview:sampleSizeText];
	// Text view was retained by the above line, so we can release it now
	[sampleSizeText release];
	
	// We don't add sampleSizeOverlay to our main view yet. We just hang on to it for now, and add it when we
	// need to display it, i.e. when a user starts a pinch/zoom.
	
	// Set up the view to refresh at 20 hz
	[fftView setAnimationInterval:1./20.];
	[fftView startAnimation];
    //FFT --------------------------------------------------
    
	[self beginObserving];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    //FFT --------------------------------------------------
    //start animation now that we're in the foreground
    fftView.applicationResignedActive = NO;
	[fftView startAnimation];
	AudioSessionSetActive(true);
    //FFT --------------------------------------------------
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    //FFT --------------------------------------------------
    //stop animation before going into background
    fftView.applicationResignedActive = YES;
    [fftView stopAnimation];
    //FFT --------------------------------------------------
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
	[_volumeView release];
	
    //FFT --------------------------------------------------
    delete[] dcFilter;
	delete fftBufferManager;
	
	[fftView release];
	
	free(oscilLine);
    //FFT --------------------------------------------------
    
    [super dealloc];
}


- (void)startFFT
{
    fftView.applicationResignedActive = NO;
    [fftView startAnimation];
    XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active");
    XThrowIfError(AudioOutputUnitStart(self.rioUnit), "couldn't start unit");
    
}


- (void)stopFFT
{
    fftView.applicationResignedActive = YES;
    [fftView stopAnimation];
    XThrowIfError(AudioOutputUnitStop(self.rioUnit), "couldn't stop unit");
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
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(controllerDidStop)
												 name: kPinkNoiseControllerDidStopNotification
											   object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(playerStateDidChange)
                                                 name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object: nil];
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
    switch (_currentType) {
        case kSTTabTypeSweep:
            _playButton.selected = !_playButton.selected;
            if ([[ToneController sharedInstance] isSweeping]) {
                [[ToneController sharedInstance] pauseSweep];
            } else {
                if ([ToneController sharedInstance].hasPausedSweep) {
                    [[ToneController sharedInstance] resumePausedSweep];
                } else {
                    [self generateSweep];
                }
            }
            break;
            
        case kSTTabTypeTone:
            _playButton.selected = !_playButton.selected;
            [[ToneController sharedInstance] togglePlay];
            break;
            
        case kSTTabTypePlaylist:
            if ([[MusicPlayerController sharedInstance] selectedSong]) {
                //this prevents switching the play/pause button to pause state if no song is selected
                _playButton.selected = !_playButton.selected;
            }
            [[MusicPlayerController sharedInstance] togglePlay];
            break;
        
        case kSTTabTypePinkNoise:
            _playButton.selected = !_playButton.selected;
            [[PinkNoiseController sharedInstance] togglePlay];
            break;
            
        default:
            break;
    }
}


- (IBAction)muteButtonPressed
{
	_muteButton.selected = !_muteButton.selected;
	
	if (_muteButton.selected) {
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
	
	if (_currentType == kSTTabTypePinkNoise) {
		[[PinkNoiseController sharedInstance] togglePlay];
	}
}


- (void)generateSweep
{
	SweepGeneratorViewController *vc = [SweepGeneratorViewController sharedInstance];
	
	STSweep* sweep = [STSweep sweepWithStartFrequency:[vc startFrequency]
									 currentFrequency:[vc startFrequency]
										 endFrequency:[vc endFrequency]
											 duration:[vc duration]
										 shouldRepeat:vc.repeatButton.selected];
	
	[[ToneController sharedInstance] performSelectorInBackground: @selector(playSweep:)
													  withObject: sweep];

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


- (void)playerStateDidChange
{
    switch ([[[MusicPlayerController sharedInstance] musicPlayer] playbackState]) {
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
            self.playButton.selected = NO;
            break;
            
        default:
            break;
    }
}


//FFT --------------------------------------------------
#pragma mark -
#pragma mark FFT functions

CGPathRef CreateRoundedRectPath(CGRect RECT, CGFloat cornerRadius)
{
	CGMutablePathRef		path;
	path = CGPathCreateMutable();
	
	double		maxRad = MAX(CGRectGetHeight(RECT) / 2., CGRectGetWidth(RECT) / 2.);
	
	if (cornerRadius > maxRad) cornerRadius = maxRad;
	
	CGPoint		bl, tl, tr, br;
	
	bl = tl = tr = br = RECT.origin;
	tl.y += RECT.size.height;
	tr.y += RECT.size.height;
	tr.x += RECT.size.width;
	br.x += RECT.size.width;
	
	CGPathMoveToPoint(path, NULL, bl.x + cornerRadius, bl.y);
	CGPathAddArcToPoint(path, NULL, bl.x, bl.y, bl.x, bl.y + cornerRadius, cornerRadius);
	CGPathAddLineToPoint(path, NULL, tl.x, tl.y - cornerRadius);
	CGPathAddArcToPoint(path, NULL, tl.x, tl.y, tl.x + cornerRadius, tl.y, cornerRadius);
	CGPathAddLineToPoint(path, NULL, tr.x - cornerRadius, tr.y);
	CGPathAddArcToPoint(path, NULL, tr.x, tr.y, tr.x, tr.y - cornerRadius, cornerRadius);
	CGPathAddLineToPoint(path, NULL, br.x, br.y + cornerRadius);
	CGPathAddArcToPoint(path, NULL, br.x, br.y, br.x - cornerRadius, br.y, cornerRadius);
	
	CGPathCloseSubpath(path);
	
	CGPathRef				ret;
	ret = CGPathCreateCopy(path);
	CGPathRelease(path);
	return ret;
}

void cycleOscilloscopeLines()
{
	// Cycle the lines in our draw buffer so that they age and fade. The oldest line is discarded.
	int drawBuffer_i;
	for (drawBuffer_i=(kNumDrawBuffers - 2); drawBuffer_i>=0; drawBuffer_i--)
		memmove(drawBuffers[drawBuffer_i + 1], drawBuffers[drawBuffer_i], drawBufferLen);
}

#pragma mark -Audio Session Interruption Listener

void rioInterruptionListener(void *inClientData, UInt32 inInterruption)
{
	printf("Session interrupted! --- %s ---", inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");
	
	AudioControlsViewController *THIS = (AudioControlsViewController*)inClientData;
	
	if (inInterruption == kAudioSessionEndInterruption) {
		// make sure we are again the active session
		XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active");
		XThrowIfError(AudioOutputUnitStart(THIS->rioUnit), "couldn't start unit");
	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
		XThrowIfError(AudioOutputUnitStop(THIS->rioUnit), "couldn't stop unit");
    }
}

#pragma mark -Audio Session Property Listener

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
	AudioControlsViewController *THIS = (AudioControlsViewController*)inClientData;
    
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		try {
            UInt32 isAudioInputAvailable; 
            UInt32 size = sizeof(isAudioInputAvailable);
            XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &isAudioInputAvailable), "couldn't get AudioSession AudioInputAvailable property value");
            
            if(THIS->unitIsRunning && !isAudioInputAvailable)
            {
                XThrowIfError(AudioOutputUnitStop(THIS->rioUnit), "couldn't stop unit");
                THIS->unitIsRunning = false;
            }
            
            else if(!THIS->unitIsRunning && isAudioInputAvailable)
            {
                XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
                
                if (!THIS->unitHasBeenCreated)	// the rio unit is being created for the first time
                {
                    XThrowIfError(SetupRemoteIO(THIS->rioUnit, THIS->inputProc, THIS->thruFormat), "couldn't setup remote i/o unit");
                    THIS->unitHasBeenCreated = true;
                    
                    THIS->dcFilter = new DCRejectionFilter[THIS->thruFormat.NumberChannels()];
                    
                    UInt32 maxFPS;
                    size = sizeof(maxFPS);
                    XThrowIfError(AudioUnitGetProperty(THIS->rioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFPS, &size), "couldn't get the remote I/O unit's max frames per slice");
                    
                    THIS->fftBufferManager = new FFTBufferManager(maxFPS);
                    THIS->l_fftData = new int32_t[maxFPS/2];
                    
                    THIS->oscilLine = (GLfloat*)malloc(drawBufferLen * 2 * sizeof(GLfloat));
                }
                
                XThrowIfError(AudioOutputUnitStart(THIS->rioUnit), "couldn't start unit");
                THIS->unitIsRunning = true;
            }
            
			// we need to rescale the sonogram view's color thresholds for different input
			CFStringRef newRoute;
			size = sizeof(CFStringRef);
			XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute), "couldn't get new audio route");
			if (newRoute)
			{	
				CFShow(newRoute);
				if (CFStringCompare(newRoute, CFSTR("Headset"), NULL) == kCFCompareEqualTo) // headset plugged in
				{
					colorLevels[0] = .3;				
					colorLevels[5] = .5;
				}
				else if (CFStringCompare(newRoute, CFSTR("Receiver"), NULL) == kCFCompareEqualTo) // headset plugged in
				{
					colorLevels[0] = 0;
					colorLevels[5] = .333;
					colorLevels[10] = .667;
					colorLevels[15] = 1.0;
					
				}			
				else
				{
					colorLevels[0] = 0;
					colorLevels[5] = .333;
					colorLevels[10] = .667;
					colorLevels[15] = 1.0;
					
				}
			}
		} catch (CAXException e) {
			char buf[256];
			fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		}
		
	}
}

#pragma mark -RIO Render Callback

static OSStatus	PerformThru(
							void						*inRefCon, 
							AudioUnitRenderActionFlags 	*ioActionFlags, 
							const AudioTimeStamp 		*inTimeStamp, 
							UInt32 						inBusNumber, 
							UInt32 						inNumberFrames, 
							AudioBufferList 			*ioData)
{
	AudioControlsViewController *THIS = (AudioControlsViewController *)inRefCon;
    
	OSStatus err = AudioUnitRender(THIS->rioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
	if (err) { printf("PerformThru: error %d\n", (int)err); return err; }
	
	// Remove DC component
	for(UInt32 i = 0; i < ioData->mNumberBuffers; ++i)
		THIS->dcFilter[i].InplaceFilter((SInt32*)(ioData->mBuffers[i].mData), inNumberFrames, 1);
	
		// The draw buffer is used to hold a copy of the most recent PCM data to be drawn on the oscilloscope
    
    if (!(THIS->_firstPassComplete)) {
		if (drawBufferLen != drawBufferLen_alloced)
		{
			int drawBuffer_i;
			
			// Allocate our draw buffer if needed
			if (drawBufferLen_alloced == 0)
				for (drawBuffer_i=0; drawBuffer_i<kNumDrawBuffers; drawBuffer_i++)
					drawBuffers[drawBuffer_i] = NULL;
			
			// Fill the first element in the draw buffer with PCM data
			for (drawBuffer_i=0; drawBuffer_i<kNumDrawBuffers; drawBuffer_i++)
			{
				drawBuffers[drawBuffer_i] = (SInt8 *)realloc(drawBuffers[drawBuffer_i], drawBufferLen);
				bzero(drawBuffers[drawBuffer_i], drawBufferLen);
			}
			
			drawBufferLen_alloced = drawBufferLen;
		}
		
		int i;
		
		SInt8 *data_ptr = (SInt8 *)(ioData->mBuffers[0].mData);
		for (i=0; i<inNumberFrames; i++)
		{
			if ((i+drawBufferIdx) >= drawBufferLen)
			{
				cycleOscilloscopeLines();
				drawBufferIdx = -i;
			}
			drawBuffers[0][i + drawBufferIdx] = data_ptr[2];
			data_ptr += 4;
		}
		drawBufferIdx += inNumberFrames;
        THIS->_firstPassComplete = YES;
	}
    
    if (THIS->fftBufferManager == NULL) return noErr;
    
    if (THIS->fftBufferManager->NeedsNewAudioData())
    {
        THIS->fftBufferManager->GrabAudioData(ioData); 
    }
    
    //don't let recorded audio pass back through to the output
    SilenceData(ioData);
	
	return err;
}


- (void)setFFTData:(int32_t *)FFTDATA length:(NSUInteger)LENGTH
{
	if (LENGTH != fftLength)
	{
		fftLength = LENGTH;
		fftData = (SInt32 *)(realloc(fftData, LENGTH * sizeof(SInt32)));
	}
	memmove(fftData, FFTDATA, fftLength * sizeof(Float32));
	hasNewFFTData = YES;
}


- (void)createGLTexture:(GLuint *)texName fromCGImage:(CGImageRef)img
{
	GLubyte *spriteData = NULL;
	CGContextRef spriteContext;
	GLuint imgW, imgH, texW, texH;
	
	imgW = CGImageGetWidth(img);
	imgH = CGImageGetHeight(img);
	
	// Find smallest possible powers of 2 for our texture dimensions
	for (texW = 1; texW < imgW; texW *= 2) ;
	for (texH = 1; texH < imgH; texH *= 2) ;
	
	// Allocated memory needed for the bitmap context
	spriteData = (GLubyte *) calloc(texH, texW * 4);
	// Uses the bitmatp creation function provided by the Core Graphics framework. 
	spriteContext = CGBitmapContextCreate(spriteData, texW, texH, 8, texW * 4, CGImageGetColorSpace(img), kCGImageAlphaPremultipliedLast);
	
	// Translate and scale the context to draw the image upside-down (conflict in flipped-ness between GL textures and CG contexts)
	CGContextTranslateCTM(spriteContext, 0., texH);
	CGContextScaleCTM(spriteContext, 1., -1.);
	
	// After you create the context, you can draw the sprite image to the context.
	CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, imgW, imgH), img);
	// You don't need the context at this point, so you need to release it to avoid memory leaks.
	CGContextRelease(spriteContext);
	
	// Use OpenGL ES to generate a name for the texture.
	glGenTextures(1, texName);
	// Bind the texture name. 
	glBindTexture(GL_TEXTURE_2D, *texName);
	// Speidfy a 2D texture image, provideing the a pointer to the image data in memory
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texW, texH, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
	// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	// Enable use of the texture
	glEnable(GL_TEXTURE_2D);
	// Set a blending function to use
	glBlendFunc(GL_SRC_ALPHA,GL_ONE);
	//glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	// Enable blending
	glEnable(GL_BLEND);
	
	free(spriteData);
}


- (void)setupViewForOscilloscope
{
	//CGImageRef img;
	
	// Load our GL textures
	//!!!!!!!
    //PUT OUR BACKGROUND IMAGE HERE
	//img = [UIImage imageNamed:@"oscilloscope.png"].CGImage;
	//[self createGLTexture:&bgTexture fromCGImage:img];
	
	//img = [UIImage imageNamed:@"fft_off.png"].CGImage;
	//[self createGLTexture:&fftOffTexture fromCGImage:img];
	
	//img = [UIImage imageNamed:@"fft_on.png"].CGImage;
	//[self createGLTexture:&fftOnTexture fromCGImage:img];
	
	//img = [UIImage imageNamed:@"mute_off.png"].CGImage;
	//[self createGLTexture:&muteOffTexture fromCGImage:img];
	
	//img = [UIImage imageNamed:@"mute_on.png"].CGImage;
	//[self createGLTexture:&muteOnTexture fromCGImage:img];
    
	//img = [UIImage imageNamed:@"sonogram.png"].CGImage;
	//[self createGLTexture:&sonoTexture fromCGImage:img];
    
	initted_oscilloscope = YES;
}


- (void)clearTextures
{
	bzero(texBitBuffer, sizeof(UInt32) * 512);
	SpectrumLinkedTexture *curTex;
	
	for (curTex = firstTex; curTex; curTex = curTex->nextTex)
	{
		glBindTexture(GL_TEXTURE_2D, curTex->texName);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1, 512, 0, GL_RGBA, GL_UNSIGNED_BYTE, texBitBuffer);
	}
}

/*
- (void)setupViewForSpectrum
{
	glClearColor(0., 0., 0., 0.);
	
	spectrumRect = CGRectMake(10., 10., 460., 300.);
	
	// The bit buffer for the texture needs to be 512 pixels, because OpenGL textures are powers of 
	// two in either dimensions. Our texture is drawing a strip of 300 vertical pixels on the screen, 
	// so we need to step up to 512 (the nearest power of 2 greater than 300).
	texBitBuffer = (UInt32 *)(malloc(sizeof(UInt32) * 512));
	
	// Clears the view with black
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);	
	
	NSUInteger texCount = ceil(CGRectGetWidth(spectrumRect) / (CGFloat)SPECTRUM_BAR_WIDTH);
	GLuint *texNames;
	
	texNames = (GLuint *)(malloc(sizeof(GLuint) * texCount));
	glGenTextures(texCount, texNames);
	
	int i;
	SpectrumLinkedTexture *curTex = NULL;
	firstTex = (SpectrumLinkedTexture *)(calloc(1, sizeof(SpectrumLinkedTexture)));
	firstTex->texName = texNames[0];
	curTex = firstTex;
	
	bzero(texBitBuffer, sizeof(UInt32) * 512);
	
	glBindTexture(GL_TEXTURE_2D, curTex->texName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	
	for (i=1; i<texCount; i++)
	{
		curTex->nextTex = (SpectrumLinkedTexture *)(calloc(1, sizeof(SpectrumLinkedTexture)));
		curTex = curTex->nextTex;
		curTex->texName = texNames[i];
		
		glBindTexture(GL_TEXTURE_2D, curTex->texName);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	}
	
	// Enable use of the texture
	glEnable(GL_TEXTURE_2D);
	// Set a blending function to use
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	// Enable blending
	glEnable(GL_BLEND);
	
	initted_spectrum = YES;
	
	free(texNames);
	
}
*/


- (void)drawOscilloscope
{
	// Clear the view
	glClear(GL_COLOR_BUFFER_BIT);
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	
	glColor4f(1., 1., 1., 1.);
	
	glPushMatrix();
	
	//glTranslatef(0., 480., 0.);
    glTranslatef(0., 0., 0.);
	//glRotatef(-90., 0., 0., 1.);
	glRotatef(0., 0., 0., 1.);
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	{
		// Draw our background oscilloscope screen
		const GLfloat vertices[] = {
			0., 0.,
			512., 0., 
			0.,  512.,
			512.,  512.,
		};
		const GLshort texCoords[] = {
			0, 0,
			1, 0,
			0, 1,
			1, 1,
		};
		
		
		glBindTexture(GL_TEXTURE_2D, bgTexture);
		
		glVertexPointer(2, GL_FLOAT, 0, vertices);
		glTexCoordPointer(2, GL_SHORT, 0, texCoords);
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
	
	{
		// Draw our buttons
		const GLfloat vertices[] = {
			0., 0.,
			112, 0., 
			0.,  64,
			112,  64,
		};
		const GLshort texCoords[] = {
			0, 0,
			1, 0,
			0, 1,
			1, 1,
		};
		
		glPushMatrix();
		
		glVertexPointer(2, GL_FLOAT, 0, vertices);
		glTexCoordPointer(2, GL_SHORT, 0, texCoords);
        
		glTranslatef(5, 0, 0);
		glBindTexture(GL_TEXTURE_2D, sonoTexture);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glTranslatef(99, 0, 0);
		glBindTexture(GL_TEXTURE_2D, mute ? muteOnTexture : muteOffTexture);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glTranslatef(99, 0, 0);
		glBindTexture(GL_TEXTURE_2D, (displayMode == aurioTouchDisplayModeOscilloscopeFFT) ? fftOnTexture : fftOffTexture);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		
		glPopMatrix();
		
	}
	
	
	
	if (displayMode == aurioTouchDisplayModeOscilloscopeFFT)
	{			
		if (fftBufferManager->HasNewAudioData())
		{
			if (fftBufferManager->ComputeFFT(l_fftData))
				[self setFFTData:l_fftData length:fftBufferManager->GetNumberFrames() / 2];
			else
				hasNewFFTData = NO;
		}
        
		if (hasNewFFTData)
		{
            
			int y, maxY;
			maxY = drawBufferLen;
			for (y=0; y<maxY; y++)
			{
				CGFloat yFract = (CGFloat)y / (CGFloat)(maxY - 1);
				CGFloat fftIdx = yFract * ((CGFloat)fftLength);
				
				double fftIdx_i, fftIdx_f;
				fftIdx_f = modf(fftIdx, &fftIdx_i);
				
				SInt8 fft_l, fft_r;
				CGFloat fft_l_fl, fft_r_fl;
				CGFloat interpVal;
				
				fft_l = (fftData[(int)fftIdx_i] & 0xFF000000) >> 24;
				fft_r = (fftData[(int)fftIdx_i + 1] & 0xFF000000) >> 24;
				fft_l_fl = (CGFloat)(fft_l + 80) / 64.;
				fft_r_fl = (CGFloat)(fft_r + 80) / 64.;
				interpVal = fft_l_fl * (1. - fftIdx_f) + fft_r_fl * fftIdx_f;
				
				interpVal = CLAMP(0., interpVal, 1.);
                
                //!!!!!!!!!!!!
				drawBuffers[0][y] = (interpVal * 120);
				
			}
			cycleOscilloscopeLines();
			
		}
		
	}
	
	
	
	GLfloat *oscilLine_ptr;
	GLfloat max = drawBufferLen;
	SInt8 *drawBuffer_ptr;
	
	// Alloc an array for our oscilloscope line vertices
	if (resetOscilLine) {
		oscilLine = (GLfloat*)realloc(oscilLine, drawBufferLen * 2 * sizeof(GLfloat));
		resetOscilLine = NO;
	}
	
	glPushMatrix();
	
    //!!!!!!!!!!!!
	// Translate to the left side and vertical center of the screen, and scale so that the screen coordinates
	// go from 0 to 1 along the X, and -1 to 1 along the Y
	//glTranslatef(17., 182., 0.);
	//glScalef(448., 116., 1.);
    
    glTranslatef(0., 73., 0.);
	glScalef(643., 70., 1.);
	
	// Set up some GL state for our oscilloscope lines
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_LINE_SMOOTH);
	glLineWidth(2.);
	
	int drawBuffer_i;
	// Draw a line for each stored line in our buffer (the lines are stored and fade over time)
	for (drawBuffer_i=0; drawBuffer_i<kNumDrawBuffers; drawBuffer_i++)
	{
		if (!drawBuffers[drawBuffer_i]) continue;
		
		oscilLine_ptr = oscilLine;
		drawBuffer_ptr = drawBuffers[drawBuffer_i];
		
		GLfloat i;
		// Fill our vertex array with points
		for (i=0.; i<max; i=i+1.)
		{
			*oscilLine_ptr++ = i/max;
			*oscilLine_ptr++ = (Float32)(*drawBuffer_ptr++) / 128.;
		}
		
		// If we're drawing the newest line, draw it in solid green. Otherwise, draw it in a faded green.
		if (drawBuffer_i == 0)
			glColor4f(89. / 255., 58. / 255., 141. / 255., 1.);
		else
			glColor4f(89. / 255., 58. / 255., 141. / 255., (.24 * (1. - ((GLfloat)drawBuffer_i / (GLfloat)kNumDrawBuffers))));
		
		// Set up vertex pointer,
		glVertexPointer(2, GL_FLOAT, 0, oscilLine);
		
		// and draw the line.
		glDrawArrays(GL_LINE_STRIP, 0, drawBufferLen);
		
	}
	
	glPopMatrix();
    
	glPopMatrix();
}


- (void)cycleSpectrum
{
	SpectrumLinkedTexture *newFirst;
	newFirst = (SpectrumLinkedTexture *)calloc(1, sizeof(SpectrumLinkedTexture));
	newFirst->nextTex = firstTex;
	firstTex = newFirst;
	
	SpectrumLinkedTexture *thisTex = firstTex;
	do {
		if (!(thisTex->nextTex->nextTex))
		{
			firstTex->texName = thisTex->nextTex->texName;
			free(thisTex->nextTex);
			thisTex->nextTex = NULL;
		} 
		thisTex = thisTex->nextTex;
	} while (thisTex);
}


- (void)renderFFTToTex
{
	[self cycleSpectrum];
	
	UInt32 *texBitBuffer_ptr = texBitBuffer;
	
	static int numLevels = sizeof(colorLevels) / sizeof(GLfloat) / 5;
	
	int y, maxY;
	maxY = CGRectGetHeight(spectrumRect);
	for (y=0; y<maxY; y++)
	{
		CGFloat yFract = (CGFloat)y / (CGFloat)(maxY - 1);
		CGFloat fftIdx = yFract * ((CGFloat)fftLength-1);
        
		double fftIdx_i, fftIdx_f;
		fftIdx_f = modf(fftIdx, &fftIdx_i);
		
		SInt8 fft_l, fft_r;
		CGFloat fft_l_fl, fft_r_fl;
		CGFloat interpVal;
		
		fft_l = (fftData[(int)fftIdx_i] & 0xFF000000) >> 24;
		fft_r = (fftData[(int)fftIdx_i + 1] & 0xFF000000) >> 24;
		fft_l_fl = (CGFloat)(fft_l + 80) / 64.;
		fft_r_fl = (CGFloat)(fft_r + 80) / 64.;
		interpVal = fft_l_fl * (1. - fftIdx_f) + fft_r_fl * fftIdx_f;
		
		interpVal = sqrt(CLAMP(0., interpVal, 1.));
        
		UInt32 newPx = 0xFF000000;
		
		int level_i;
		const GLfloat *thisLevel = colorLevels;
		const GLfloat *nextLevel = colorLevels + 5;
		for (level_i=0; level_i<(numLevels-1); level_i++)
		{
			if ( (*thisLevel <= interpVal) && (*nextLevel >= interpVal) )
			{
				double fract = (interpVal - *thisLevel) / (*nextLevel - *thisLevel);
				newPx = 
				((UInt8)(255. * linearInterp(thisLevel[1], nextLevel[1], fract)) << 24)
				|
				((UInt8)(255. * linearInterp(thisLevel[2], nextLevel[2], fract)) << 16)
				|
				((UInt8)(255. * linearInterp(thisLevel[3], nextLevel[3], fract)) << 8)
				|
				(UInt8)(255. * linearInterp(thisLevel[4], nextLevel[4], fract))
				;
				break;
			}
			
			thisLevel+=5;
			nextLevel+=5;
		}
		
		*texBitBuffer_ptr++ = newPx;
	}
	
	glBindTexture(GL_TEXTURE_2D, firstTex->texName);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1, 512, 0, GL_RGBA, GL_UNSIGNED_BYTE, texBitBuffer);
	
	hasNewFFTData = NO;
}


/*
- (void)drawSpectrum
{
	// Clear the view
	glClear(GL_COLOR_BUFFER_BIT);
	
	if (fftBufferManager->HasNewAudioData())
	{
		if (fftBufferManager->ComputeFFT(l_fftData))
		{
			[self setFFTData:l_fftData length:fftBufferManager->GetNumberFrames() / 2];
		}
		else
			hasNewFFTData = NO;
	}
	
	if (hasNewFFTData) [self renderFFTToTex];
	
	glClear(GL_COLOR_BUFFER_BIT);
	
	glEnable(GL_TEXTURE);
	glEnable(GL_TEXTURE_2D);
	
	glPushMatrix();
	glTranslatef(0., 480., 0.);
	glRotatef(-90., 0., 0., 1.);
    //glRotatef(90., 0., 0., 1.);
	glTranslatef(spectrumRect.origin.x + spectrumRect.size.width, spectrumRect.origin.y, 0.);
	
	GLfloat quadCoords[] = {
		0., 0., 
		SPECTRUM_BAR_WIDTH, 0., 
		0., 512., 
		SPECTRUM_BAR_WIDTH, 512., 
	};
	
	GLshort texCoords[] = {
		0, 0, 
		1, 0, 
		0, 1,
		1, 1, 
	};
	
	glVertexPointer(2, GL_FLOAT, 0, quadCoords);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_SHORT, 0, texCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);	
	
	glColor4f(1., 1., 1., 1.);
	
	SpectrumLinkedTexture *thisTex;
	glPushMatrix();
	for (thisTex = firstTex; thisTex; thisTex = thisTex->nextTex)
	{
		glTranslatef(-(SPECTRUM_BAR_WIDTH), 0., 0.);
		glBindTexture(GL_TEXTURE_2D, thisTex->texName);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
	glPopMatrix();
	glPopMatrix();
	
	glFlush();
	
}
*/

#pragma mark -
#pragma mark EAGLView delegate

- (void)drawView:(id)sender forTime:(NSTimeInterval)time
{
	//if ((displayMode == aurioTouchDisplayModeOscilloscopeWaveform) || (displayMode == aurioTouchDisplayModeOscilloscopeFFT))
	//{
		if (!initted_oscilloscope) [self setupViewForOscilloscope];
		[self drawOscilloscope];
	//} else if (displayMode == aurioTouchDisplayModeSpectrum) {
	//	if (!initted_spectrum) [self setupViewForSpectrum];
	//	[self drawSpectrum];
	//}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// If we're if waveform mode and not currently in a pinch event, and we've got two touches, start a pinch event
	if ((!pinchEvent) && ([[event allTouches] count] == 2) && (self.displayMode == aurioTouchDisplayModeOscilloscopeWaveform))
	{
		pinchEvent = event;
		NSArray *t = [[event allTouches] allObjects];
		lastPinchDist = fabs([[t objectAtIndex:0] locationInView:fftView].x - [[t objectAtIndex:1] locationInView:fftView].x);
		
		sampleSizeText.text = [NSString stringWithFormat:@"%i ms", drawBufferLen / (int)(hwSampleRate / 1000.)];
		[fftView addSubview:sampleSizeOverlay];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// If we are in a pinch event...
	if ((event == pinchEvent) && ([[event allTouches] count] == 2))
	{
		CGFloat thisPinchDist, pinchDiff;
		NSArray *t = [[event allTouches] allObjects];
		thisPinchDist = fabs([[t objectAtIndex:0] locationInView:fftView].x - [[t objectAtIndex:1] locationInView:fftView].x);
		
		// Find out how far we traveled since the last event
		pinchDiff = thisPinchDist - lastPinchDist;
		// Adjust our draw buffer length accordingly,
		drawBufferLen -= 12 * (int)pinchDiff;
		drawBufferLen = CLAMP(kMinDrawSamples, drawBufferLen, kMaxDrawSamples);
		resetOscilLine = YES;
		
		// and display the size of our oscilloscope window in our overlay view
		sampleSizeText.text = [NSString stringWithFormat:@"%i ms", drawBufferLen / (int)(hwSampleRate / 1000.)];
		
		lastPinchDist = thisPinchDist;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (event == pinchEvent)
	{
		// If our pinch/zoom has ended, nil out the pinchEvent and remove the overlay view
		[sampleSizeOverlay removeFromSuperview];
		pinchEvent = nil;
		return;
	}
    /*
	// any tap in sonogram view will exit back to the waveform
	if (self.displayMode == aurioTouchDisplayModeSpectrum)
	{
		AudioServicesPlaySystemSound(buttonPressSound);
		self.displayMode = aurioTouchDisplayModeOscilloscopeWaveform;
		return;
	}
	*/
    /*
	UITouch *touch = [touches anyObject];
	if (unitIsRunning)
	{
		if (CGRectContainsPoint(CGRectMake(0., 5., 52., 99.), [touch locationInView:fftView])) // The Sonogram button was touched
		{
			AudioServicesPlaySystemSound(buttonPressSound);
			if ((self.displayMode == aurioTouchDisplayModeOscilloscopeWaveform) || (self.displayMode == aurioTouchDisplayModeOscilloscopeFFT))
			{
				if (!initted_spectrum) [self setupViewForSpectrum];
				[self clearTextures];
				self.displayMode = aurioTouchDisplayModeSpectrum;
			}
		}
		else if (CGRectContainsPoint(CGRectMake(0., 104., 52., 99.), [touch locationInView:fftView])) // The Mute button was touched
		{
			AudioServicesPlaySystemSound(buttonPressSound);
			self.mute = !(self.mute);
			return;
		}
		else if (CGRectContainsPoint(CGRectMake(0., 203, 52., 99.), [touch locationInView:fftView])) // The FFT button was touched
		{
            //START HERE!!!!
			AudioServicesPlaySystemSound(buttonPressSound);
			self.displayMode = (self.displayMode == aurioTouchDisplayModeOscilloscopeWaveform) ?  aurioTouchDisplayModeOscilloscopeFFT :
            aurioTouchDisplayModeOscilloscopeWaveform;
			return;
		}
	}
     */
}
//FFT --------------------------------------------------

@end
