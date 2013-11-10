/*!
 *  AudioFileDetailsButton.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/9/13
 */

#import "AudioFileDetailsButton.h"

@implementation AudioFileDetailsButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [self.tintColor setStroke];
    
    CGFloat h,s,b,a;
    [self.tintColor getHue:&h saturation:&s brightness:&b alpha:&a];
    
    [[UIColor colorWithHue:h saturation:s brightness:1.0 alpha:0.8] setFill];
    
    CGFloat cornerRadii = CGRectGetHeight(self.bounds) / 2;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1.5, 1.5, 1.5, 1.5)) cornerRadius:cornerRadii];
    path.lineWidth = 1.0;
    [path stroke];
    [path fill];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(100, 40);
}

@end
