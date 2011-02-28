//
//  PinkNoiseController.m
//  SoundTweak
//
//  Created by Bryan Montz on 2/12/11.
//  Copyright 2011 Evan Hamilton. All rights reserved.
//

#import "PinkNoiseController.h"
#import <AudioToolbox/AudioToolbox.h>

static PinkNoiseController * __sharedInstance;

NSString * const kPinkNoiseControllerDidStopNotification = @"kPinkNoiseControllerDidStopNotification";

@interface PinkNoiseController()
- (void)initRandomEnv:(long)numRows;
- (OSStatus) processAudioBufferList:(AudioBufferList *)bufferList;
- (unsigned long) randomNumber;
@end


@implementation PinkNoiseController


+ (void) initialize
{
    if (!__sharedInstance)
        __sharedInstance = [[self alloc] init];
}


+ (PinkNoiseController *) sharedInstance
{
    return __sharedInstance;
}


- (id) init
{
    if ( !(self = [super init]) )
        return nil;
    
    [self initRandomEnv:5];
    
    return self;
}


OSStatus RenderPinkNoise(
                    void *inRefCon, 
                    AudioUnitRenderActionFlags 	*ioActionFlags, 
                    const AudioTimeStamp 		*inTimeStamp, 
                    UInt32 						inBusNumber, 
                    UInt32 						inNumberFrames, 
                    AudioBufferList 			*bufferList)
{
	[[PinkNoiseController sharedInstance] processAudioBufferList: bufferList];
    
	return noErr;
}


void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	[[PinkNoiseController sharedInstance] stop];
}


- (void)initRandomEnv:(long)numRows
{
    int    index;
    long    pmax;
    
    _pinkIndex = 0;
    _pinkIndexMask = (1 << numRows) - 1;
    
    // Calculate max possible signed random value. extra 1 for white noise always added
    pmax = (numRows + 1) * (1 << (kPinkRandomBits-1));
    _pinkScalar = 1.0 / pmax;
    
    // Initialize rows
    for( index = 0; index < numRows; index++ )
        _pinkRows[index] = 0;
    _pinkRunningSum = 0;
}


- (unsigned long) randomNumber
{
    return arc4random() % ULLONG_MAX;
}


- (OSStatus) processAudioBufferList:(AudioBufferList *)bufferList
{
    float     *bufferLeft = (float*)(bufferList->mBuffers[0].mData);
    float     *bufferRight = (float*)(bufferList->mBuffers[1].mData);
    
    UInt32     bufferSize = bufferList->mBuffers[0].mDataByteSize;
    UInt32     numChannels = bufferList->mBuffers[0].mNumberChannels;
    UInt32     bufferSamples = bufferSize / 4;
    UInt32     bufferFrames = bufferSamples / numChannels;
    UInt32     channel;
    float      sample;
    UInt32     sampleIndex;
    
    // Pink Noise
    for( sampleIndex = 0; sampleIndex < bufferFrames; sampleIndex++ )
    {
        long    newRandom;
        long    sum;
        
        // Increment and mask index
        _pinkIndex = (_pinkIndex + 1) & _pinkIndexMask;
        
        // If index is zero, don't update any random values
        if( _pinkIndex )
        {
            int        numZeros = 0;
            int        n = _pinkIndex;
            
            // Determine how many trailing zeros in pinkIndex
            // this will hang if n == 0 so test first
            while( (n & 1) == 0 )
            {
                n = n >> 1;
                numZeros++;
            }
            
            // Replace the indexed rows random value
            // Subtract and add back to pinkRunningSum instead of adding all 
            // the random values together. only one changes each time
            _pinkRunningSum -= _pinkRows[numZeros];
            newRandom = ((long)[self randomNumber]) >> kPinkRandomShift;
            _pinkRunningSum += newRandom;
            _pinkRows[numZeros] = newRandom;
        }
        
        // Add extra white noise value
        newRandom = ((long)[self randomNumber]) >> kPinkRandomShift;
        sum = _pinkRunningSum + newRandom;
        
        // Scale to range of -1.0 to 0.999 and factor in volume
        sample = _pinkScalar * sum * 0.25; //_volume;
				
        // Write to all channels
        for( channel = 0; channel < numChannels; channel++ )
            *bufferLeft++ = *bufferRight++ = sample;
    }
    
    return noErr;
}


- (void)createToneUnit
{
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
	input.inputProc = RenderPinkNoise;
	input.inputProcRefCon = self;
	err = AudioUnitSetProperty(_toneUnit, 
                               kAudioUnitProperty_SetRenderCallback, 
                               kAudioUnitScope_Input,
                               0, 
                               &input, 
                               sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %ld", err);
	
	// Set the format to 32 bit, stereo, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
    
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = 44100.;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =	kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;	
	streamFormat.mBytesPerFrame = four_bytes_per_float;		
	streamFormat.mChannelsPerFrame = 2;	
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
	if (_toneUnit)
	{
		AudioOutputUnitStop(_toneUnit);
		AudioUnitUninitialize(_toneUnit);
		AudioComponentInstanceDispose(_toneUnit);
		_toneUnit = nil;
	}
	else
	{
		[self createToneUnit];
		
		// Stop changing parameters on the unit
		OSErr err = AudioUnitInitialize(_toneUnit);
		NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
		
		// Start playback
		err = AudioOutputUnitStart(_toneUnit);
		NSAssert1(err == noErr, @"Error starting unit: %ld", err);
	}
}



-(void)stop
{
	if (_toneUnit)
	{
		[self togglePlay];
		[[NSNotificationCenter defaultCenter] postNotificationName: kPinkNoiseControllerDidStopNotification
															object: self];
	}
}


@end
