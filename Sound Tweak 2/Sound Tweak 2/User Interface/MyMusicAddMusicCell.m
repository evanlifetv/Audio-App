/*!
 *  MyMusicAddMusicCell.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/9/13
 */

#import "MyMusicAddMusicCell.h"

@implementation MyMusicAddMusicCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = [UIColor selectedSoundTweakPurple];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self removeConstraints:self.constraints];
    [super updateConstraints];
    
    CGFloat height = CGRectGetHeight(self.contentView.frame);
    
    NSDictionary *metrics = @{
                              @"height": @(height - 10)
                              };
    NSDictionary *views = @{
                            @"addLabel": self.addItemLabel,
                            @"addView": self.addView
                            };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[addView(==height)]-12-[addLabel]-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[addView(==height)]" options:0 metrics:metrics views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addItemLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.addView setNeedsDisplay];
}

- (UILabel *)addItemLabel {
    if (!_addItemLabel) {
        UILabel *l = [[UILabel alloc] init];
        l.translatesAutoresizingMaskIntoConstraints = NO;
        l.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        l.textColor = [UIColor soundTweakPurple];
        
        _addItemLabel = l;
        [self.contentView addSubview:l];
    }
    return _addItemLabel;
}
- (MyMusicAddMusicCellAddView *)addView {
    if (!_addView) {
        MyMusicAddMusicCellAddView *v = [[MyMusicAddMusicCellAddView alloc] init];
        v.translatesAutoresizingMaskIntoConstraints = NO;
        v.backgroundColor = [UIColor clearColor];
        
        _addView = v;
        [self.contentView addSubview:v];
    }
    return _addView;
}

@end

@implementation MyMusicAddMusicCellAddView

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    [self.tintColor setStroke];
    
    CGFloat padding = 12.0;
    
    UIBezierPath *verticalPath = [UIBezierPath bezierPath];
    [verticalPath moveToPoint:CGPointMake(CGRectGetMidX(self.bounds), padding)];
    [verticalPath addLineToPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - padding)];
    [verticalPath closePath];
    verticalPath.lineWidth = 1.0;
    [verticalPath stroke];
    
    UIBezierPath *horizontalPath = [UIBezierPath bezierPath];
    [horizontalPath moveToPoint:CGPointMake(padding, CGRectGetMidY(self.bounds))];
    [horizontalPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - padding, CGRectGetMidY(self.bounds))];
    [horizontalPath closePath];
    horizontalPath.lineWidth = 1.0;
    [horizontalPath stroke];
}

@end
