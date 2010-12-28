
#import <Foundation/Foundation.h>


@interface STSweep : NSObject {

	double	_startFrequency;
	double  _currentFrequency;
	double	_endFrequency;
	int		_duration;
	BOOL	_shouldRepeat;
}

@property (nonatomic, readonly) double startFrequency;
@property (nonatomic, readonly) double currentFrequency;
@property (nonatomic, readonly) double endFrequency;
@property (nonatomic, readonly) int duration;
@property (nonatomic, readonly) BOOL shouldRepeat;

+ (STSweep*)sweepWithStartFrequency:(double)startFrequency
				   currentFrequency:(double)currentFrequency
					   endFrequency:(double)endFrequency
						   duration:(int)duration
					   shouldRepeat:(BOOL)shouldRepeat;

- (BOOL)isIncreasing;
- (double)frequencySpan;

@end
