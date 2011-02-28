//
//  PlaylistViewController.m
//  SoundTweak
//
//  Created by Bryan Montz on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import "PlaylistViewController.h"
#import "MusicPlayerController.h"
#import "AudioControlsViewController.h"
#import "StyleController.h"
#import "STSmallSlider.h"
#import "STSong.h"

@interface PlaylistViewController()
-(NSString *) displayStringForTimeInterval: (NSTimeInterval) interval;
-(void) startObservingMusicPlayer;
-(void) stopObservingMusicPlayer;
@end

@implementation PlaylistViewController

@synthesize tableView = _tableView;
@synthesize artistLabel = _artistLabel;
@synthesize songTitleLabel = _songTitleLabel;
@synthesize artworkView = _artworkView;
@synthesize scrubSlider = _scrubSlider;
@synthesize currentTimeLabel = _currentTimeLabel;
@synthesize remainingTimeLabel = _remainingTimeLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.tabBarItem.image = [UIImage imageNamed:@"playlist.png"];
        self.tabBarItem.title = @"Playlist";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didBecomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    /*
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didBeginPlaying)
                                                 name: kMusicPlayerControllerDidBeginPlayingNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didPause)
                                                 name: kMusicPlayerControllerDidPauseNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didStop)
                                                 name: kMusicPlayerControllerDidStopNotification
                                               object: nil];
    */
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(playerStateDidChange:)
                                                 name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object: nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    _artworkView.image = [UIImage imageNamed: @"noartwork.png"];  //load the "no artwork" image by default
    
	if ([[MusicPlayerController sharedInstance] deviceHasSoundTweakPlaylist]) {
		[self.tableView reloadData];
	} else {
		//user did not have a "SoundTweak" playlist
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[AudioControlsViewController sharedInstance].currentType = kSTTabTypePlaylist;
}


- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[[MusicPlayerController sharedInstance] stop];
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.tableView = nil;
    self.artistLabel = nil;
    self.songTitleLabel = nil;
    self.artworkView = nil;
    self.scrubSlider = nil;
    self.currentTimeLabel = nil;
    self.remainingTimeLabel = nil;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
	[_tableView release];
    [_artistLabel release];
    [_songTitleLabel release];
    [_artworkView release];
    [_scrubSlider release];
    [_currentTimeLabel release];
    [_remainingTimeLabel release];
    
    [_trackingTimer invalidate];
    [_trackingTimer release];
    
	[super dealloc];
}


#pragma mark -
#pragma mark Actions

-(void) playerStateDidChange: (NSNotification *) notification
{
    switch ([[[MusicPlayerController sharedInstance] musicPlayer] playbackState]) {
        case MPMusicPlaybackStatePaused:
            [self stopObservingMusicPlayer];
            break;
        case MPMusicPlaybackStateStopped:
            [[MusicPlayerController sharedInstance] musicPlayer].currentPlaybackTime = 0;
            _scrubSlider.value = 0;
            
            [self stopObservingMusicPlayer];
            break;
        
        case MPMusicPlaybackStatePlaying:
            [self startObservingMusicPlayer];
            break;
            
        default:
            break;
    }
}


//slider events
-(IBAction) scrubSliderChanged
{
    NSTimeInterval currentPosition = _scrubSlider.value;
    
    STSong *song = [[MusicPlayerController sharedInstance] selectedSong];
    
    NSTimeInterval remainingTime = song.duration - currentPosition;
    
    _currentTimeLabel.text = [self displayStringForTimeInterval: currentPosition];
    _remainingTimeLabel.text = [self displayStringForTimeInterval: remainingTime];
    
    [[[MusicPlayerController sharedInstance] musicPlayer] setCurrentPlaybackTime: currentPosition];
}


-(void) startObservingMusicPlayer
{
    if (!_trackingTimer) {
        _trackingTimer = [[NSTimer timerWithTimeInterval: 0.25
                                                  target: self
                                                selector: @selector(timerFired:)
                                                userInfo: nil
                                                 repeats: YES] retain];
        
        [[NSRunLoop currentRunLoop] addTimer:_trackingTimer forMode:NSDefaultRunLoopMode];
    }
}


-(void) stopObservingMusicPlayer
{
    [_trackingTimer invalidate];
    [_trackingTimer release];
    _trackingTimer = nil;
}


-(void) timerFired: (NSTimer *) timer
{
    //update the labels
    STSong *song = [[MusicPlayerController sharedInstance] selectedSong];
    NSTimeInterval currentPosition = [[[MusicPlayerController sharedInstance] musicPlayer] currentPlaybackTime];
    
    NSTimeInterval remainingTime = song.duration - floor(currentPosition);
    
    _currentTimeLabel.text = [self displayStringForTimeInterval: currentPosition];
    _remainingTimeLabel.text = [self displayStringForTimeInterval: remainingTime];
    
    if (!_scrubSlider.touchInside) {
        //don't want to programmatically change the position of the slider while the user has their finger on it
        _scrubSlider.value = currentPosition;
    }
}


#pragma mark -
#pragma mark UITableViewDatasource and UITableViewDelegate

- (void)didBecomeActive
{
    //app came back from being inactive, so check if user sync'ed a SoundTweak playlist
    if ([[MusicPlayerController sharedInstance] deviceHasSoundTweakPlaylist]) {
		[self.tableView reloadData];
	} else {
		//user did not have a "SoundTweak" playlist
	}
}


#pragma mark -
#pragma mark UITableViewDatasource and UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return ([[MusicPlayerController sharedInstance] deviceHasSoundTweakPlaylist]) ? 1 : 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[[MusicPlayerController sharedInstance] soundTweakPlaylist] items] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellID];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellID] autorelease];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        UIView *purpleBackView = [[[UIView alloc] initWithFrame: cell.frame] autorelease];
        [purpleBackView setBackgroundColor: [StyleController soundTweakPurpleColor]];
        cell.selectedBackgroundView = purpleBackView;
    }
	
	cell.textLabel.text = [[MusicPlayerController sharedInstance] songAtIndex:indexPath.row].title;
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[MusicPlayerController sharedInstance] selectSongAtIndex:indexPath.row];
    
    STSong *song = [[MusicPlayerController sharedInstance] selectedSong];
    
    _songTitleLabel.text = song.title;
    _artistLabel.text = song.artist;
    
    NSTimeInterval totalTime = song.duration;
    _currentTimeLabel.text = [self displayStringForTimeInterval: 0.];
    _remainingTimeLabel.text = [self displayStringForTimeInterval: totalTime];
    
    _artworkView.image = [song artworkImageWithSize:_artworkView.bounds.size];
    
    [_scrubSlider setValue: 0. animated: NO];
    _scrubSlider.minimumValue = 0.;
    _scrubSlider.maximumValue = totalTime;
}


#pragma mark -
#pragma mark Internal

-(NSString *) displayStringForTimeInterval: (NSTimeInterval) interval
{
    if (interval < 0)
        return @"0:00";
    
    int mins = floor(interval / 60.);
    int secs = (int)floor(interval) % 60;
    return [NSString stringWithFormat:@"%i:%02i", mins, secs];
}

@end
