#import "MYPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation MYPlayerView

+ (Class)layerClass {
	return [AVPlayerLayer class];
}

#pragma mark -

- (AVPlayer *)player {
	return ((AVPlayerLayer *)self.layer).player;
}

- (void)setPlayer:(AVPlayer *)player {
	((AVPlayerLayer *)self.layer).player = player;
}

@end
