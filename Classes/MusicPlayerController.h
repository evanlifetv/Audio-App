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

@interface MusicPlayerController : NSObject {

	MPMusicPlayerController *_musicPlayer;
	MPMediaItem				*_currentItem;
	MPMediaPlaylist			*_soundTweakPlaylist;
	
}

@property (nonatomic, readonly) MPMusicPlayerController *musicPlayer;
@property (nonatomic, readonly) MPMediaItem *currentItem;
@property (nonatomic, readonly) MPMediaPlaylist *soundTweakPlaylist;

+ (id)sharedInstance;

- (BOOL)deviceHasSoundTweakPlaylist;
- (void)selectSongAtIndex:(NSInteger)index;

-(NSString *) artistForSongAtIndex: (NSInteger) index;
-(NSString*) titleForSongAtIndex: (NSInteger) index;
-(UIImage*) artworkWithSize: (CGSize) imageSize forSongAtIndex: (NSInteger) index;

- (void)togglePlay;
- (void)setVolume:(float)newVolume;

@end

extern NSString * const kMusicPlayerControllerDidSelectNewSongNotification;
extern NSString * const kMusicPlayerControllerDidStopNotification;