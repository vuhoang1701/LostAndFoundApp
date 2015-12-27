//
//  WaveDisplay.m
//  MyBestFriend
//
//  Created by HYUBYN on 10/20/15.
//  Copyright © 2015 HYUBYN. All rights reserved.
//


#import "WaveDisplay.h"
#import "Listener.h"

@implementation WaveDisplay

@synthesize dataPoints;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    self.dataPoints = nil;
}

// Simulates drawing a waveform by drawing a series of alternating
// quadratic curves of varying heights. Also reverses the sign of
// each data point at every iteration to achieve the effect of
// waveform movement
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    static bool reverse = false;
    
    CGFloat scaleFactor = ((rect.size.height / 2) - 4.0) / kMaxVolumeSampleValue;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 3.0);
    long count = [self.dataPoints count];
    CGFloat dx = rect.size.width / count;
    CGFloat x = 0.0;
    CGFloat y = rect.size.height / 2;
    CGContextMoveToPoint(context, x, y);
    BOOL down = NO;
    
    for (NSNumber *point in self.dataPoints) {
        // Draw curve
        CGFloat raw = [point floatValue] * scaleFactor;
        CGFloat draw = (down ? -raw : raw);
        draw = (reverse ? -draw : draw);
        x += dx;
        CGContextAddQuadCurveToPoint(context, x + dx/2, y - draw * 2, x, y);
        
        down = !down;
    }
    reverse = !reverse;
    CGContextDrawPath(context, kCGPathStroke);//*/
}

@end
