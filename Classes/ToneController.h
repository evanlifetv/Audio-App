
@class STSweep;

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>

@interface ToneController : NSObject {
	AudioComponentInstance _toneUnit;
	
	double		_frequency;
	double		_sampleRate;
	double		_theta;
	
	STSweep*	_currentSweep;
	BOOL		_sweeping;
	BOOL		_hasPausedSweep;
}

@property (nonatomic) double frequency;
@property (nonatomic) double sampleRate;
@property (nonatomic) double theta;

//sweep
@property (nonatomic, retain) STSweep* currentSweep;
@property (nonatomic, getter=isSweeping) BOOL sweeping;
@property (nonatomic) BOOL hasPausedSweep;


//class methods
+ (ToneController*)sharedInstance;

//instance methods
- (void)togglePlay;
- (void)playSweep:(STSweep *)sweep;
- (void)pauseSweep;
- (void)resumePausedSweep;
- (void)invalidatePausedSweep;
- (void)stop;

@end

extern NSString * const kToneControllerWillStartPlayingSweep;
extern NSString * const kToneControllerDidFinishPlayingSweep;
extern NSString * const kToneControllerDidInvalidatePausedSweep;
extern NSString * const kToneControllerDidStop;
