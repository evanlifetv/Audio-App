
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "STTypes.h"

//FFT --------------------------------------------------
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#include <libkern/OSAtomic.h>
#include <CoreFoundation/CFURL.h>

#import "EAGLView.h"
#import "FFTBufferManager.h"
#import "aurio_helper.h"
#import "CAStreamBasicDescription.h"

#define SPECTRUM_BAR_WIDTH 4

#ifndef CLAMP
#define CLAMP(min,x,max) (x < min ? min : (x > max ? max : x))
#endif

typedef enum aurioTouchDisplayMode {
	aurioTouchDisplayModeOscilloscopeWaveform, 
	aurioTouchDisplayModeOscilloscopeFFT
	//aurioTouchDisplayModeSpectrum 
} aurioTouchDisplayMode;

typedef struct SpectrumLinkedTexture {
	GLuint							texName; 
	struct SpectrumLinkedTexture	*nextTex;
} SpectrumLinkedTexture;

inline double linearInterp(double valA, double valB, double fract)
{
	return valA + ((valB - valA) * fract);
}
//FFT --------------------------------------------------

@interface AudioControlsViewController : UIViewController <EAGLViewDelegate> {
	UIButton		*_playButton;
	UIButton		*_muteButton;
	UISlider		*_volumeSlider;
	MPVolumeView	*_volumeView;
    
    STTabType       _currentType;
    BOOL            _firstPassComplete;
    
    //FFT --------------------------------------------------
    IBOutlet EAGLView*			fftView;
	
	UIImageView*				sampleSizeOverlay;
	UILabel*					sampleSizeText;
	
	SInt32*						fftData;
	NSUInteger					fftLength;
	BOOL						hasNewFFTData;
	
	AudioUnit					rioUnit;
	BOOL						unitIsRunning;
	BOOL						unitHasBeenCreated;
	
	BOOL						initted_oscilloscope, initted_spectrum;
	UInt32*						texBitBuffer;
	CGRect						spectrumRect;
	
	GLuint						bgTexture;
	//GLuint						muteOffTexture, muteOnTexture;
	//GLuint						fftOffTexture, fftOnTexture;
	//GLuint						sonoTexture;
	
	aurioTouchDisplayMode		displayMode;
	
	BOOL						mute;
	
	SpectrumLinkedTexture*		firstTex;
	FFTBufferManager*			fftBufferManager;
	DCRejectionFilter*			dcFilter;
	CAStreamBasicDescription	thruFormat;
	Float64						hwSampleRate;
	
	UIEvent*					pinchEvent;
	CGFloat						lastPinchDist;
	
	AURenderCallbackStruct		inputProc;
    
	SystemSoundID				buttonPressSound;
	
	int32_t*					l_fftData;
    
	GLfloat*					oscilLine;
	BOOL						resetOscilLine;
    //FFT --------------------------------------------------
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


//FFT --------------------------------------------------
@property (nonatomic, retain)	EAGLView*				fftView;

@property (assign)				aurioTouchDisplayMode	displayMode;
@property						FFTBufferManager*		fftBufferManager;

@property (nonatomic, assign)	AudioUnit				rioUnit;
@property (nonatomic, assign)	BOOL						unitIsRunning;
@property (nonatomic, assign)	BOOL						unitHasBeenCreated;
@property (nonatomic, assign)	BOOL					mute;
@property (nonatomic, assign)	AURenderCallbackStruct	inputProc;

- (void)startFFT;
- (void)stopFFT;
//FFT --------------------------------------------------

@end
