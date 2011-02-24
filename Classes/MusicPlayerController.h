//
//  MusicPlayerController.h
//  SoundTweak
//
//  Created by Bryan Montz on 1/16/11.
//  Copyright 2011 Evan Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import "MediaPlayer/MPMediaPlaylist.h"

@class STSong;

@interface MusicPlayerController : NSObject {

	MPMusicPlayerController *_musicPlayer;
    STSong                  *_selectedSong;
	MPMediaPlaylist			*_soundTweakPlaylist;
	
}

@property (nonatomic, readonly) MPMusicPlayerController *musicPlayer;
@property (nonatomic, retain) STSong *selectedSong;
@property (nonatomic, readonly) MPMediaPlaylist *soundTweakPlaylist;

+ (id)sharedInstance;

- (BOOL)deviceHasSoundTweakPlaylist;
- (void)selectSongAtIndex:(NSInteger)index;
- (STSong *) songAtIndex: (NSInteger) index;

- (void)togglePlay;
- (void)setVolume:(float)newVolume;

@end

extern NSString * const kMusicPlayerControllerDidSelectNewSongNotification;
extern NSString * const kMusicPlayerControllerDidBeginPlayingNotification;
extern NSString * const kMusicPlayerControllerDidStopNotification;
extern NSString * const kMusicPlayerControllerDidPauseNotification;