//
//  ToneController.m
//  SoundTweak
//
//  Created by Bryan Montz on 11/4/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//
// Adapted from a sample project by:
//  Created by Matt Gallagher on 2010/10/20.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "ToneController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AudioControlsViewController.h"
#import <AVFoundation/AVAudioSession.h>
#import "STSweep.h"

NSString * const kToneControllerWillStartPlayingSweep = @"kToneControllerWillStartPlayingSweep";
NSString * const kToneControllerDidFinishPlayingSweep = @"kToneControllerDidFinishPlayingSweep";
NSString * const kToneControllerDidInvalidatePausedSweep = @"kToneControllerDidInvalidatePausedSweep";
NSString * const kToneControllerDidStop = @"kToneControllerDidStop";

static ToneController *__sharedInstance = nil;

@interface ToneController()
+ (void)setupAudioSession;
@end


OSStatus RenderTone(
					void *inRefCon, 
					AudioUnitRenderActionFlags 	*ioActionFlags, 
					const AudioTimeStamp 		*inTimeStamp, 
					UInt32 						inBusNumber, 
					UInt32 						inNumberFrames, 
					AudioBufferList 			*ioData)
{
	
    ToneController *tC = [ToneController sharedInstance];
    
	double amplitude = (double)[[AudioControlsViewController sharedInstance] volume];
	double newTheta = [ToneController sharedInstance].theta;
	double theta_increment = 2.0 * M_PI * tC.frequency / tC.sampleRate;
	
	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++) 
	{
		buffer[frame] = sin(newTheta) * amplitude;
		
		newTheta += theta_increment;
		if (newTheta > 2.0 * M_PI)
		{
			newTheta -= 2.0 * M_PI;
		}
	}
	
	tC.theta = newTheta;
	return noErr;
}


@implementation ToneController

@synthesize frequency = _frequency;
@synthesize sampleRate = _sampleRate;
@synthesize theta = _theta;
@synthesize currentSweep = _currentSweep;
@synthesize sweeping = _sweeping;
@synthesize hasPausedSweep = _hasPausedSweep;


#pragma -
#pragma Singleton

+(void) initialize
{
    if (!__sharedInstance)
        __sharedInstance = [[self alloc] init];
}


+ (ToneController*)sharedInstance
{
	return __sharedInstance;
}


-(id) init
{
    if ( !(self = [super init]) )
        return nil;
    
    _frequency = 1000.;
    _sampleRate = 44100.;
    _theta = 0.;
    
    [[self class] setupAudioSession];
    
    return self;
}


+ (void)setupAudioSession
{
	NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback
										   error: &setCategoryError];
	
	if (setCategoryError) { /* handle the error condition */ }
	
	NSError *activationError = nil;
	[[AVAudioSession sharedInstance] setActive: YES
										 error: &activationError];
}


- (void)createToneUnit
{
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &_toneUnit);
	NSAssert1(_toneUnit, @"Error creating unit: %ld", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = self;
	err = AudioUnitSetProperty(_toneUnit, 
							   kAudioUnitProperty_SetRenderCallback, 
							   kAudioUnitScope_Input,
							   0, 
							   &input, 
							   sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %ld", err);
	
	// Set the format to 32-bit, single-channel, floating-point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = self.sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =	kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;	
	streamFormat.mBytesPerFrame = four_bytes_per_float;		
	streamFormat.mChannelsPerFrame = 1;	
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (_toneUnit,
								kAudioUnitProperty_StreamFormat,
								kAudioUnitScope_Input,
								0,
								&streamFormat,
								sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %ld", err);
}


- (void)togglePlay
{
	if (_toneUnit) {
		[self stop];
		
	} else {
		[self createToneUnit];
		
		// Stop changing parameters on the unit
		OSErr err = AudioUnitInitialize(_toneUnit);
		NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
		
		// Start playback
		err = AudioOutputUnitStart(_toneUnit);
		NSAssert1(err == noErr, @"Error starting unit: %ld", err);
	}
}


- (void)playSweep:(STSweep*)sweep
{
	//need an autorelease pool since this is running in the background
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.currentSweep = sweep;
	self.sweeping = YES;
	
	[self performSelectorOnMainThread:@selector(notifyObserversWillStartPlayingSweep) withObject:nil waitUntilDone:NO];
	
	[self togglePlay];
	
	NSTimeInterval sleepTime = ((double)sweep.duration / [sweep frequencySpan]);
	
	BOOL firstTimeThrough = YES;
	while (firstTimeThrough || sweep.shouldRepeat) {
		
		double startFrequency = 1;
		
		if (firstTimeThrough && sweep.startFrequency != sweep.currentFrequency) {
			//we are resuming a repeating sweep in the middle
			startFrequency = sweep.currentFrequency;
		} else {
			startFrequency = sweep.startFrequency;
		}
		
		if ([sweep isIncreasing]) {
			for (int i = startFrequency; i <= sweep.endFrequency; i++) {
				
				if (self.hasPausedSweep) {
					[pool release];
					return;
				}
				
				self.frequency = i;
				[NSThread sleepForTimeInterval:sleepTime];
			}
		} else {
			for (int i = startFrequency; i >= sweep.endFrequency; i--) {
				
				if (self.hasPausedSweep) {
					[pool release];
					return;
				}
				
				self.frequency = i;
				[NSThread sleepForTimeInterval:sleepTime];
			}
		}
		firstTimeThrough = NO;
	}
	
	[self stop];
	
	[self performSelectorOnMainThread:@selector(notifyObserversDidFinishPlayingSweep) withObject:nil waitUntilDone:NO];
	
	self.currentSweep = nil;
	self.sweeping = NO;
	
	[pool release];
}


- (void)notifyObserversWillStartPlayingSweep
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kToneControllerWillStartPlayingSweep object:nil];
}


- (void)notifyObserversDidFinishPlayingSweep
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kToneControllerDidFinishPlayingSweep object:nil];
}


- (void)notifyObserversDidStop
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kToneControllerDidStop object:nil];
}


- (void)pauseSweep
{
	//set the new sweep that will be resumable
	self.currentSweep = [STSweep sweepWithStartFrequency:self.currentSweep.startFrequency
										currentFrequency:self.frequency
											endFrequency:self.currentSweep.endFrequency
												duration:self.currentSweep.duration
											shouldRepeat:self.currentSweep.shouldRepeat];
	
	
	[self stop];
	
	[self notifyObserversDidFinishPlayingSweep];
	
	self.sweeping = NO;
	self.hasPausedSweep = YES;
}


- (void)resumePausedSweep
{
	self.hasPausedSweep = NO;
	self.sweeping = YES;
	
	[self performSelectorInBackground:@selector(playSweep:) withObject:self.currentSweep];
}


- (void)invalidatePausedSweep
{
	self.hasPausedSweep = NO;
	self.currentSweep = nil;
	self.sweeping = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kToneControllerDidInvalidatePausedSweep object:nil];
}


- (void)stop
{
	if (_toneUnit) {
		AudioOutputUnitStop(_toneUnit);
		AudioUnitUninitialize(_toneUnit);
		AudioComponentInstanceDispose(_toneUnit);
		_toneUnit = nil;
		
		[self performSelectorOnMainThread:@selector(notifyObserversDidStop) withObject:nil waitUntilDone:NO];
	}
	self.sweeping = NO;
}


@end
