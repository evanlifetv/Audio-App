//
//  ToneController.h
//  SoundTweak
//
//  Created by Bryan Montz on 11/4/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>

@interface ToneController : NSObject {
	AudioComponentInstance toneUnit;
	
	double frequency;
	double sampleRate;
	double theta;
}

@property (nonatomic) double frequency;
@property (nonatomic) double sampleRate;
@property (nonatomic) double theta;

//class methods
+ (ToneController*)sharedInstance;

//instance methods
- (void)togglePlay;

@end
