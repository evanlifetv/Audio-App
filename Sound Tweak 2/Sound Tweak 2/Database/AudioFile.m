//
//  AudioFile.m
//  Sound Tweak 2
//
//  Created by Skylar Schipper on 11/8/13.
//  Copyright (c) 2013 OpenSky, LLC. All rights reserved.
//

#import "AudioFile.h"
#import "SDTAudioManager.h"

@implementation AudioFile

@dynamic title;
@dynamic persistentID;
@dynamic albumTitle;
@dynamic artist;
@dynamic artworkName;
@dynamic assetName;
@dynamic playbackDuration;

- (void)prepareForDeletion {
    [super prepareForDeletion];
    [[SDTAudioManager sharedManager] willDeleteAudioFile:self];
}

@end
