
#import "STSweep.h"


@interface STSweep()
- (STSweep*)initWithStartFrequency:(double)startFrequency
				  currentFrequency:(double)currentFrequency
					  endFrequency:(double)endFrequency
						  duration:(int)duration
					  shouldRepeat:(BOOL)shouldRepeat;
@end


@implementation STSweep

@synthesize startFrequency = _startFrequency;
@synthesize currentFrequency = _currentFrequency;
@synthesize endFrequency = _endFrequency;
@synthesize duration = _duration;
@synthesize shouldRepeat = _shouldRepeat;


+ (STSweep*)sweepWithStartFrequency:(double)startFrequency
				   currentFrequency:(double)currentFrequency
					   endFrequency:(double)endFrequency
						   duration:(int)duration
					   shouldRepeat:(BOOL)shouldRepeat
{
	STSweep* sweep = [[[[self class] alloc] initWithStartFrequency:startFrequency
												  currentFrequency:currentFrequency
													  endFrequency:endFrequency
														  duration:duration
													  shouldRepeat:shouldRepeat] autorelease];
	return sweep;
}


- (STSweep*)initWithStartFrequency:(double)startFrequency
				  currentFrequency:(double)currentFrequency
					  endFrequency:(double)endFrequency
						  duration:(int)duration
					  shouldRepeat:(BOOL)shouldRepeat
{
	_startFrequency = startFrequency;
	_currentFrequency = currentFrequency;
	_endFrequency = endFrequency;
	_duration = duration;
	_shouldRepeat = shouldRepeat;
	
	return self;
}


- (BOOL)isIncreasing
{
	return (self.startFrequency < self.endFrequency);
}


- (double)frequencySpan
{
	return abs(self.startFrequency - self.endFrequency);
}

@end
