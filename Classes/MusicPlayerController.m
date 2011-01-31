//
//  MusicPlayerController.m
//  SoundTweak
//
//  Created by Bryan Montz on 1/16/11.
//  Copyright 2011 Evan Hamilton. All rights reserved.
//

#import "MusicPlayerController.h"
#import "MediaPlayer/MPMediaQuery.h"
#import "MediaPlayer/MPMediaPlaylist.h"

#define kSoundTweakPlaylistName @"SoundTweak"

NSString * const kMusicPlayerControllerDidSelectNewSongNotification = @"kMusicPlayerControllerDidSelectNewSongNotification";
NSString * const kMusicPlayerControllerDidStopNotification = @"kMusicPlayerControllerDidStopNotification";

static MusicPlayerController *__sharedInstance = nil;

@interface MusicPlayerController()
- (void)setCurrentItem:(MPMediaItem*)item;
@end


@implementation MusicPlayerController

@synthesize musicPlayer = _musicPlayer;
@synthesize currentItem = _currentItem;
@synthesize soundTweakPlaylist = _soundTweakPlaylist;


+ (void)initialize
{
    if (!__sharedInstance)
        __sharedInstance = [[self alloc] init];
}


+ (id)sharedInstance
{
	//Already set by +initialize.
    return __sharedInstance;
}


- (id)init
{
	if (self = [super init]) {
		_musicPlayer = [[MPMusicPlayerController applicationMusicPlayer] retain];
		
		//initialize the playlist data
		MPMediaQuery *query = [MPMediaQuery playlistsQuery];
		MPMediaPropertyPredicate *soundTweakPlaylistPredicate = [MPMediaPropertyPredicate predicateWithValue:kSoundTweakPlaylistName
																								 forProperty:MPMediaPlaylistPropertyName];
		[query addFilterPredicate:soundTweakPlaylistPredicate];
		
		NSArray *returnedPlaylists = [query collections];
		if (returnedPlaylists && [returnedPlaylists count] > 0) {
			_soundTweakPlaylist = [[returnedPlaylists objectAtIndex:0] retain];
		}
	}
	return self;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	[_musicPlayer release];
	[_currentItem release];
	[_soundTweakPlaylist release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Public methods

- (BOOL)deviceHasSoundTweakPlaylist
{
	return (_soundTweakPlaylist != nil);
}


- (void)selectSongAtIndex:(NSInteger)index
{
	NSArray *songs = [self.soundTweakPlaylist items];
	MPMediaItem *songItem = [songs objectAtIndex:index];
	[self setCurrentItem:songItem];
}


- (NSString*)titleForSongAtIndex:(NSInteger)index
{
	MPMediaItem *song = [[self.soundTweakPlaylist items] objectAtIndex:index];
	
	return [song valueForProperty:MPMediaItemPropertyTitle];
}


- (void)togglePlay
{
	if (self.currentItem) {
		switch (self.musicPlayer.playbackState) {
			case MPMusicPlaybackStatePlaying:
				[self.musicPlayer pause];
				break;
				
			default:
				[self.musicPlayer play];
				break;
		}
	}
	else {
		//no song is selected
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
														 message:@"Please select a song to play"
														delegate:nil
											   cancelButtonTitle:@"OK"
											   otherButtonTitles:nil] autorelease];
		[alert show];
	}

}


- (void)stop
{
	if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
		[self.musicPlayer stop];
		[[NSNotificationCenter defaultCenter] postNotificationName:kMusicPlayerControllerDidStopNotification object:self];
	}
}


- (void)setVolume:(float)newVolume
{
	[self musicPlayer].volume = newVolume;
}


#pragma mark -
#pragma mark Private methods

- (void)setCurrentItem:(MPMediaItem*)item
{
	if (_currentItem != item) {
		[self.musicPlayer stop];
		
		//either this is the first selection or the user changed the song selection
		[_currentItem release];
		_currentItem = [item retain];
		[self.musicPlayer setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject:item]]];
	
		[[NSNotificationCenter defaultCenter] postNotificationName:kMusicPlayerControllerDidSelectNewSongNotification object:self];
	}
}


@end
