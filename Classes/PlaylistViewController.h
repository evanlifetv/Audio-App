//
//  PlaylistViewController.h
//  SoundTweak
//
//  Created by Bryan Montz on 10/31/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STSmallSlider;

@interface PlaylistViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

	UITableView				*_tableView;
    
    UILabel                 *_artistLabel;
    UILabel                 *_songTitleLabel;
    UIImageView             *_artworkView;
    
    STSmallSlider           *_scrubSlider;
    UILabel                 *_currentTimeLabel;
    UILabel                 *_remainingTimeLabel;
    NSTimer                 *_trackingTimer;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UILabel *artistLabel;
@property (nonatomic, retain) IBOutlet UILabel *songTitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *artworkView;
@property (nonatomic, retain) IBOutlet STSmallSlider *scrubSlider;
@property (nonatomic, retain) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *remainingTimeLabel;

-(IBAction) scrubSliderChanged;

@end
