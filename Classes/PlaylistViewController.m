//
//  PlaylistViewController.m
//  referenceaudio
//
//  Created by Evan Hamilton on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import "PlaylistViewController.h"


@implementation PlaylistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.tabBarItem.image = [UIImage imageNamed:@"play.png"];
        self.tabBarItem.title = @"Playlist";
    }
    return self;
}

@end
