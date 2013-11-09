/*!
 * MyMusicViewController.h
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/8/13
 */

#ifndef MyMusicViewController_h
#define MyMusicViewController_h

@import MediaPlayer;
@import AVFoundation;

#import "SDTViewController.h"

@interface MyMusicViewController : SDTViewController <MPMediaPickerControllerDelegate>

- (IBAction)pickMediaButtonAction:(id)sender;

@end

#endif
