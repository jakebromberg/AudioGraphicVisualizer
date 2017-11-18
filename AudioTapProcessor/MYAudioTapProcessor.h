#import <Foundation/Foundation.h>

@class AVAudioMix;
@class AVAssetTrack;

@protocol MYAudioTabProcessorDelegate;

@interface MYAudioTapProcessor : NSObject

// Designated initializer.
- (id)initWithAudioAssetTrack:(AVAssetTrack *)audioAssetTrack;

// Properties
@property (readonly, nonatomic) AVAssetTrack *audioAssetTrack;
@property (readonly, nonatomic) AVAudioMix *audioMix;
@property (weak, nonatomic) id <MYAudioTabProcessorDelegate> delegate;
@property (nonatomic, getter = isBandpassFilterEnabled) BOOL enableBandpassFilter;
@property (nonatomic) float centerFrequency; // [0 .. 1]
@property (nonatomic) float bandwidth; // [0 .. 1]

@end

#pragma mark - Protocols

@protocol MYAudioTabProcessorDelegate <NSObject>

// Add comment…
- (void)audioTabProcessor:(MYAudioTapProcessor *)audioTabProcessor hasNewLeftChannelValue:(float)leftChannelValue rightChannelValue:(float)rightChannelValue;

@end
