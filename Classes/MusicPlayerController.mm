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
#import "STSong.h"
#import <AudioToolbox/AudioToolbox.h>

//notifications
NSString * const kMusicPlayerControllerDidSelectNewSongNotification = @"kMusicPlayerControllerDidSelectNewSongNotification";
NSString * const kMusicPlayerControllerDidBeginPlayingNotification = @"kMusicPlayerControllerDidBeginPlayingNotification";
NSString * const kMusicPlayerControllerDidStopNotification = @"kMusicPlayerControllerDidStopNotification";
NSString * const kMusicPlayerControllerDidPauseNotification = @"kMusicPlayerControllerDidPauseNotification";
NSString * const kMusicPlayerControllerDidRefreshPlaylistNotification = @"kMusicPlayerControllerDidRefreshPlaylistNotification";

static MusicPlayerController *__sharedInstance = nil;

@interface MusicPlayerController()
- (void) refreshPlaylist;
@end


@implementation MusicPlayerController

@synthesize musicPlayer = _musicPlayer;
@synthesize selectedSong = _selectedSong;
@synthesize soundTweakPlaylist = _soundTweakPlaylist;


+ (void)initialize
{
    if (!__sharedInstance)
        __sharedInstance = [[self alloc] init];
}


+ (id)sharedInstance
{
    return __sharedInstance;
}


- (id)init
{
	if ((self = [super init])) {
		_musicPlayer = [[MPMusicPlayerController applicationMusicPlayer] retain];
		[_musicPlayer beginGeneratingPlaybackNotifications];
        
		//initialize the playlist data
		[self refreshPlaylist];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didEnterBackground:)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];
	}
	return self;
}


- (void) refreshPlaylist
{
    [_soundTweakPlaylist release];
    _soundTweakPlaylist = nil;
    self.selectedSong = nil;
    
    AudioSessionSetActive(false);
    AudioSessionSetActive(true);
    
    NSArray *playlistNames = [NSArray arrayWithObjects: @"SoundTweak", @"soundtweak", @"Soundtweak", @"soundTweak", nil];
    
    NSArray *returnedPlaylists = nil;
    for (NSString *name in playlistNames) {
        
        MPMediaQuery *query = [MPMediaQuery playlistsQuery];
        MPMediaPropertyPredicate *playlistPredicate = [MPMediaPropertyPredicate predicateWithValue: name
                                                                                       forProperty: MPMediaPlaylistPropertyName];
        [query addFilterPredicate: playlistPredicate];
        
        returnedPlaylists = [query collections];
        if (returnedPlaylists && [returnedPlaylists count] > 0) {
            break;
        }
    }
    
    MPMediaPlaylist *newPlaylist = nil;
    if (returnedPlaylists && [returnedPlaylists count] > 0) {
        newPlaylist = [[returnedPlaylists objectAtIndex:0] retain];
    }
    
    if (newPlaylist) {
        if (newPlaylist != _soundTweakPlaylist) {
            _soundTweakPlaylist = [newPlaylist retain];
        }
        
        NSLog(@"Found 'SoundTweak' playlist, and it contains %u tracks.", _soundTweakPlaylist.items.count);
    }
    else {
        //user doesn't have a SoundTweak playlist
        NSLog(@"No 'SoundTweak' playlist was found.");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kMusicPlayerControllerDidRefreshPlaylistNotification object: nil];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
	[_musicPlayer release];
	[_selectedSong release];
	[_soundTweakPlaylist release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Public methods

- (BOOL)deviceHasSoundTweakPlaylist
{
	return (_soundTweakPlaylist != nil && [[_soundTweakPlaylist items] count] > 0);
}


- (void)selectSongAtIndex:(NSInteger)index
{
	NSArray *songs = [self.soundTweakPlaylist items];
	MPMediaItem *songItem = [songs objectAtIndex:index];
    
	[self setSelectedSong:[STSong songWithMediaItem: songItem]];
}


- (STSong *) songAtIndex: (NSInteger) index
{
    NSArray *songs = [self.soundTweakPlaylist items];
	MPMediaItem *songItem = [songs objectAtIndex:index];
    return [STSong songWithMediaItem: songItem];
}


- (void)togglePlay
{
	if (_selectedSong) {
		switch (self.musicPlayer.playbackState) {
			case MPMusicPlaybackStatePlaying:
				[self.musicPlayer pause];
                [[NSNotificationCenter defaultCenter] postNotificationName: kMusicPlayerControllerDidPauseNotification
                                                                    object:nil];
				break;
				
			default:
				[self.musicPlayer play];
                [[NSNotificationCenter defaultCenter] postNotificationName: kMusicPlayerControllerDidBeginPlayingNotification
                                                                    object: nil];
				break;
		}
	}
	else {
		//no song is selected
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle: nil
														 message: @"Please select a song to play"
														delegate: nil
											   cancelButtonTitle: @"OK"
											   otherButtonTitles: nil] autorelease];
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


- (void)pause
{
    if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
		[self.musicPlayer pause];
		[[NSNotificationCenter defaultCenter] postNotificationName:kMusicPlayerControllerDidStopNotification object:self];
	}
}


- (void)setVolume:(float)newVolume
{
	_musicPlayer.volume = newVolume;
}


#pragma mark -
#pragma mark Private methods

- (void)setSelectedSong:(STSong *) newSong
{
	if (newSong && _selectedSong != newSong) {
		[self stop];
		
		//either this is the first selection or the user changed the song selection
		[_selectedSong release];
		_selectedSong = [newSong retain];
		[self.musicPlayer setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject: newSong.sourceMediaItem]]];
	
		[[NSNotificationCenter defaultCenter] postNotificationName:kMusicPlayerControllerDidSelectNewSongNotification object:self];
	}
    else if (!newSong) {
        [_selectedSong release];
        _selectedSong = nil;
        [self.musicPlayer setQueueWithItemCollection: nil];
    }
}


-(void) didEnterBackground: (NSNotification *) notification
{
    [_soundTweakPlaylist release];
    _soundTweakPlaylist = nil;
    self.selectedSong = nil;
}

@end
