//
//  STSong.m
//  SoundTweak
//
//  Created by Bryan Montz on 2/23/11.
//  Copyright 2011 Evan Hamilton. All rights reserved.
//

#import "STSong.h"

@implementation STSong

@synthesize artist = _artist;
@synthesize title = _title;
@synthesize duration = _duration;
@synthesize sourceMediaItem = _sourceMediaItem;


-(id) initWithMediaItem: (MPMediaItem *) item
{
    if ( (self = [super init]) ) {
        _artist = [[item valueForProperty: MPMediaItemPropertyArtist] copy];
        _title = [[item valueForProperty: MPMediaItemPropertyTitle] copy];
        _duration = [[item valueForProperty: MPMediaItemPropertyPlaybackDuration] doubleValue];
        _artwork = [[item valueForProperty: MPMediaItemPropertyArtwork] retain];
        _sourceMediaItem = [item retain];
    }
    return self;
}


+(STSong *) songWithMediaItem: (MPMediaItem *) item
{
    return [[[self alloc] initWithMediaItem: item] autorelease];
}


-(UIImage *) artworkImageWithSize: (CGSize) size
{
    UIImage *artworkImage = nil;
    if (_artwork)
        artworkImage = [_artwork imageWithSize: size];
    else
        artworkImage = [UIImage imageNamed: @"noartwork.png"];
    
    return artworkImage;
}


-(void) dealloc
{
    [_artist release];
    [_title release];
    [_artwork release];
    [_sourceMediaItem release];
    
    [super dealloc];
}


@end
