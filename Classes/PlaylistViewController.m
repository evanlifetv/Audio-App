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


@implementation PlaylistViewController

@synthesize tableView = _tableView;
@synthesize artistLabel = _artistLabel;
@synthesize songTitleLabel = _songTitleLabel;
@synthesize artworkView = _artworkView;

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
	
	if ([[MusicPlayerController sharedInstance] deviceHasSoundTweakPlaylist]) {
		[self.tableView reloadData];
	} else {
		//user did not have a "SoundTweak" playlist
	}
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    _artworkView.image = [UIImage imageNamed: @"noartwork.png"];
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
}


- (void)dealloc
{
	[_tableView release];
    [_artistLabel release];
    [_songTitleLabel release];
    [_artworkView release];
    
	[super dealloc];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        UIView *purpleBackView = [[[UIView alloc] initWithFrame: cell.frame] autorelease];
        [purpleBackView setBackgroundColor: [StyleController soundTweakPurpleColor]];
        cell.selectedBackgroundView = purpleBackView;
    }
	
	cell.textLabel.text = [[MusicPlayerController sharedInstance] titleForSongAtIndex:indexPath.row];
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[MusicPlayerController sharedInstance] selectSongAtIndex:indexPath.row];
    
    _songTitleLabel.text = [[MusicPlayerController sharedInstance] titleForSongAtIndex: indexPath.row];
    _artistLabel.text = [[MusicPlayerController sharedInstance] artistForSongAtIndex: indexPath.row];
    _artworkView.image = [[MusicPlayerController sharedInstance] artworkWithSize:_artworkView.bounds.size forSongAtIndex:indexPath.row];
}


@end
