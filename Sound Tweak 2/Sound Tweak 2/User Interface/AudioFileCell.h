/*!
 * AudioFileCell.h
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/9/13
 */

#ifndef AudioFileCell_h
#define AudioFileCell_h

#import <UIKit/UIKit.h>
#import "SDTAudioManager.h"

@interface AudioFileCell : UICollectionViewCell

@property (nonatomic, weak) AudioFile *audioFile;

@property (nonatomic, weak) UIImageView *albumArtwork;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *artistLabel;

@end

#endif
