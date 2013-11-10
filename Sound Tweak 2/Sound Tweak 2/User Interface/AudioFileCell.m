/*!
 *  AudioFileCell.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/9/13
 */

#import "AudioFileCell.h"

@interface AudioFileCell ()

@property (nonatomic, weak) UIView *separator;

@end

@implementation AudioFileCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.artistLabel.text = nil;
    self.titleLabel.text = nil;
    self.albumArtwork.image = nil;
}

- (void)setAudioFile:(AudioFile *)audioFile {
    _audioFile = audioFile;
    
    self.artistLabel.text = audioFile.artist;
    self.titleLabel.text = audioFile.title;
    self.albumArtwork.image = nil;
    if (_audioFile) {
        [[SDTAudioManager sharedManager] asyncronousImageForAudioFile:audioFile completion:^(UIImage *image, NSNumber *audioFilePersistentID) {
            if (_audioFile && [_audioFile.persistentID isEqual:audioFilePersistentID]) {
                self.albumArtwork.image = image;
            }
        }];
    }
    
    self.separator.backgroundColor = [UIColor soundTweakHairLinePurple];
}


#pragma mark -
#pragma mark - Lazy Loaders
- (UILabel *)artistLabel {
    if (!_artistLabel) {
        UILabel *l = [[UILabel alloc] init];
        l.translatesAutoresizingMaskIntoConstraints = NO;
        l.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        l.textColor = [UIColor soundTweakLightPurple];
        
        _artistLabel = l;
        [self.contentView addSubview:l];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[t][l]-5-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"l": l,@"t": self.titleLabel}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[image]-[l]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"l": l,@"image": self.albumArtwork}]];
    }
    return _artistLabel;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *l = [[UILabel alloc] init];
        l.translatesAutoresizingMaskIntoConstraints = NO;
        l.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        l.textColor = [UIColor soundTweakPurple];
        
        _titleLabel = l;
        [self.contentView addSubview:l];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[l]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(l)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[image]-[l]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"l": l,@"image": self.albumArtwork}]];
    }
    return _titleLabel;
}
- (UIImageView *)albumArtwork {
    if (!_albumArtwork) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _albumArtwork = imageView;
        [self.contentView addSubview:imageView];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(imageView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(imageView)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:imageView
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0
                                                          constant:0.0]];
    }
    return _albumArtwork;
}
- (UIView *)separator {
    if (!_separator) {
        UIView *s = [[UIView alloc] init];
        s.translatesAutoresizingMaskIntoConstraints = NO;
        s.backgroundColor = [UIColor soundTweakHairLinePurple];
        
        _separator = s;
        [self.contentView insertSubview:s atIndex:0];
        
        CGFloat height = ([[UIScreen mainScreen] scale] >= 2.0) ? 0.5 : 1.0;
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[a]-[s]|" options:0 metrics:nil views:@{@"s": s,@"a":self.albumArtwork}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[s(==height)]|" options:0 metrics:@{@"height": @(height)} views:NSDictionaryOfVariableBindings(s)]];
        
    }
    return _separator;
}


@end
