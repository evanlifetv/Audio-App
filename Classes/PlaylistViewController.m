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


@implementation PlaylistViewController

@synthesize tableView = _tableView;


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
}


- (void)dealloc
{
	[_tableView release];
	
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
	UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.textLabel.text = [[MusicPlayerController sharedInstance] titleForSongAtIndex:indexPath.row];
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[MusicPlayerController sharedInstance] selectSongAtIndex:indexPath.row];
}


@end
