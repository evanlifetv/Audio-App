/*!
 *  AudioFileDisplayView.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/9/13
 */

#import "AudioFileDisplayView.h"

#import "AudioFileDetailsButton.h"

@interface AudioFileDisplayView ()

@property (nonatomic, readonly) BOOL interfaceShowing;

@property (nonatomic, weak) UIImageView *artworkView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *artistLabel;

@property (nonatomic, weak) UISlider *progressSlider;
@property (nonatomic, weak) UILabel *progressPlayedLabel;
@property (nonatomic, weak) UILabel *progressTotalLabel;

@property (nonatomic, weak) AudioFileDetailsButton *playButton;
@property (nonatomic, weak) AudioFileDetailsButton *deleteButton;

@end

@implementation AudioFileDisplayView

- (void)setAudioFile:(AudioFile *)audioFile {
    _audioFile = audioFile;
    
    self.titleLabel.text = audioFile.title;
    self.artistLabel.text = audioFile.artist;
    self.artworkView.image = [[SDTAudioManager sharedManager] imageForAudioFile:audioFile];
    self.progressPlayedLabel.text = @"-:--";
    self.progressTotalLabel.text = @"-:--";
}

- (void)showInterfaceCompletion:(void (^)(void))completion {
    _interfaceShowing = YES;
    [self updateConstraints];
    
    [UIView animateWithDuration:0.9 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:10 options:0 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}
- (void)hideInterfaceCompletion:(void(^)(void))completion {
    _interfaceShowing = NO;
    [self updateConstraints];
    
    [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:10 options:0 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

#pragma mark -
#pragma mark - Lazy Loaders
- (UIImageView *)artworkView {
    if (!_artworkView) {
        UIImageView *i = [[UIImageView alloc] init];
        i.translatesAutoresizingMaskIntoConstraints = NO;
        
        _artworkView = i;
        [self addSubview:i];
    }
    return _artworkView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *l = [[UILabel alloc] init];
        l.translatesAutoresizingMaskIntoConstraints = NO;
        l.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        l.textColor = [UIColor soundTweakDarkPurple];
        
        _titleLabel = l;
        [self addSubview:l];
    }
    return _titleLabel;
}
- (UILabel *)artistLabel {
    if (!_artistLabel) {
        UILabel *l = [[UILabel alloc] init];
        l.translatesAutoresizingMaskIntoConstraints = NO;
        l.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        l.textColor = [UIColor soundTweakDarkPurple];
        
        _artistLabel = l;
        [self addSubview:l];
    }
    return _artistLabel;
}
- (AudioFileDetailsButton *)playButton {
    if (!_playButton) {
        AudioFileDetailsButton *b = [[AudioFileDetailsButton alloc] init];
        b.translatesAutoresizingMaskIntoConstraints = NO;
        [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [b setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];
        
        [b addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _playButton = b;
        [self addSubview:b];
    }
    return _playButton;
}
- (AudioFileDetailsButton *)deleteButton {
    if (!_deleteButton) {
        AudioFileDetailsButton *b = [[AudioFileDetailsButton alloc] init];
        b.translatesAutoresizingMaskIntoConstraints = NO;
        [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [b setTitle:NSLocalizedString(@"Remove", nil) forState:UIControlStateNormal];
        
        b.tintColor = [UIColor deleteColorRed];
        
        [b addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _deleteButton = b;
        [self addSubview:b];
    }
    return _deleteButton;
}
- (UISlider *)progressSlider {
    if (!_progressSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.translatesAutoresizingMaskIntoConstraints = NO;
        slider.tintColor = [UIColor soundTweakDarkPurple];
        slider.maximumTrackTintColor = [UIColor soundTweakHairLinePurple];
        
        _progressSlider = slider;
        [self addSubview:slider];
    }
    return _progressSlider;
}
- (UILabel *)progressPlayedLabel {
    if (!_progressPlayedLabel) {
        UILabel *l = [[UILabel alloc] init];
        l.translatesAutoresizingMaskIntoConstraints = NO;
        l.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        l.textColor = [UIColor soundTweakPurple];
        
        _progressPlayedLabel = l;
        [self addSubview:l];
    }
    return _progressPlayedLabel;
}
- (UILabel *)progressTotalLabel {
    if (!_progressTotalLabel) {
        UILabel *l = [[UILabel alloc] init];
        l.translatesAutoresizingMaskIntoConstraints = NO;
        l.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        l.textColor = [UIColor soundTweakPurple];
        l.textAlignment = NSTextAlignmentRight;
        
        _progressTotalLabel = l;
        [self addSubview:l];
    }
    return _progressTotalLabel;
}

#pragma mark -
#pragma mark - Button Actions
- (void)deleteButtonAction:(id)sender {
    [self.delegate audioFileDisplayView:self shouldRemoveAudioFile:self.audioFile];
}
- (void)playButtonAction:(id)sender {
    [self.delegate audioFileDisplayView:self shouldPlayAudioFile:self.audioFile];
}

#pragma mark -
#pragma mark - Layout
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}
- (void)updateConstraints {
    [self removeConstraints:self.constraints];
    [super updateConstraints];
    
    [self _setFirmConstraints];
    
    if (_interfaceShowing) {
        [self _showingConstraints];
    } else {
        [self _hiddenConstraints];
    }
}
- (NSDictionary *)metrics {
    CGFloat padding = 10;
    return @{
             @"bottomOffset": @(self.bottomOffset + padding),
             @"padding": @(padding),
             @"artworkSize": ([[UIDevice currentDevice] isPad]) ? @160 : @100
             };
}
- (NSDictionary *)views {
    return @{
             @"artworkView": self.artworkView,
             @"titleLabel": self.titleLabel,
             @"artistLabel": self.artistLabel,
             @"playButton": self.playButton,
             @"deleteButton": self.deleteButton,
             @"progressSlider": self.progressSlider,
             @"progressPlayedLabel": self.progressPlayedLabel,
             @"progressTotalLabel": self.progressTotalLabel
             };
}
- (void)_setFirmConstraints {
    NSDictionary *metrics = [self metrics];
    NSDictionary *views = [self views];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[artworkView(==artworkSize)]" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[titleLabel]" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleLabel]-padding-[artistLabel]" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[playButton]-padding-[deleteButton(==playButton)]-padding-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[progressSlider]-padding-|" options:0 metrics:metrics views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressPlayedLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.progressSlider
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:6.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressPlayedLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.progressSlider
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressTotalLabel
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.progressSlider
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:-6.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressTotalLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.progressSlider
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
}
- (void)_hiddenConstraints {
    NSDictionary *metrics = [self metrics];
    NSDictionary *views = [self views];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.artworkView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[artworkView(==artworkSize)]" options:0 metrics:metrics views:views]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.artistLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:80.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:80.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressSlider
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
}
- (void)_showingConstraints {
    NSDictionary *metrics = [self metrics];
    NSDictionary *views = [self views];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[artworkView(==artworkSize)]-[titleLabel]-padding-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[artworkView]-[artistLabel]-padding-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[deleteButton]-bottomOffset-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[playButton]-bottomOffset-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[artworkView]-padding-[progressSlider]" options:0 metrics:metrics views:views]];
}

@end
