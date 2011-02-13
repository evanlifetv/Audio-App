//
//  PinkNoiseController.h
//  SoundTweak
//
//  Created by Bryan Montz on 2/12/11.
//  Copyright 2011 Evan Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>

#define kPinkMaxRandomRows		32
#define kPinkRandomBits			30
#define kPinkRandomShift		((sizeof(long)*8)-kPinkRandomBits)

@interface PinkNoiseController : NSObject {
    AudioComponentInstance  _toneUnit;
    
	long                    _pinkRows[kPinkMaxRandomRows];
	long                    _pinkRunningSum;	// Used to optimize summing of generators
	int                     _pinkIndex;			// Incremented each sample
	int                     _pinkIndexMask;		// Index wrapped by &ing with this mask
	float                   _pinkScalar;		// Used to scale within range of -1.0 to 1.0
}

+ (PinkNoiseController *) sharedInstance;
-(void) togglePlay;
-(void) stop;

@end

extern NSString * const kPinkNoiseControllerDidStopNotification;