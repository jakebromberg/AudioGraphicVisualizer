#import "MYViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "MYAudioTapProcessor.h"
#import "MYPlayerView.h"
#import "MYVolumeUnitMeterView.h"
#import "MYSettingsViewController.h"

static void *MYViewControllerPlayerStatusObserverContext = &MYViewControllerPlayerStatusObserverContext;

static NSString *stringFromCMTime(CMTime time, NSString *sign);

@interface MYViewController () <MYAudioTabProcessorDelegate, MYSettingsViewControllerDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet MYPlayerView *playerView;
@property (weak, nonatomic) IBOutlet MYVolumeUnitMeterView *leftChannelVolumeUnitMeterView;
@property (weak, nonatomic) IBOutlet MYVolumeUnitMeterView *rightChannelVolumeUnitMeterView;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *currentTimeSlider;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsPopoverButton;

@property (readonly, strong, nonatomic) AVPlayer *player;
@property (readonly, strong, nonatomic) id playerTimeObserver;
@property (readonly, strong, nonatomic) id playerItemDidPlayToEndTimeObserver;
@property (readonly, strong, nonatomic) MYAudioTapProcessor *audioTapProcessor;

// IBActions
- (IBAction)togglePlayPause:(id)sender;
- (IBAction)seekToTime:(id)sender;
@end

@implementation MYViewController

#pragma mark - Properties

@synthesize player = _player;

- (AVPlayer *)player {
	if (!_player) {
        NSURL *url = [NSURL URLWithString:@"http://audio-mp3.ibiblio.org:8000/wxyc.mp3"];
        AVAsset *asset = [AVAsset assetWithURL:url];
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        
        _player = [AVPlayer playerWithPlayerItem:item];
	}
    
	return _player;
}

@synthesize audioTapProcessor = _audioTapProcessor;

- (MYAudioTapProcessor *)audioTapProcessor {
	if (!_audioTapProcessor) {
		AVAssetTrack *firstAudioAssetTrack = self.player.currentItem.tracks.firstObject.assetTrack;
        
		if (firstAudioAssetTrack) {
			_audioTapProcessor = [[MYAudioTapProcessor alloc] initWithAudioAssetTrack:firstAudioAssetTrack];
			_audioTapProcessor.delegate = self;
		}
	}
	return _audioTapProcessor;
}

@synthesize playerView;
@synthesize leftChannelVolumeUnitMeterView;
@synthesize rightChannelVolumeUnitMeterView;
@synthesize playPauseButton;
@synthesize elapsedTimeLabel;
@synthesize currentTimeSlider;
@synthesize remainingTimeLabel;
@synthesize settingsPopoverButton;

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Attach player to player view.
	self.playerView.player = self.player;
	
	// Disable play pause button and current time slider (until player is ready to play).
	self.playPauseButton.enabled = NO;
	self.currentTimeSlider.enabled = NO;
	
	// Disable settings popover button (until audio tap is created).
	self.settingsPopoverButton.enabled = NO;
	
	// Start observing player's status.
	[self.player addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:MYViewControllerPlayerStatusObserverContext];

    [self.player addObserver:self forKeyPath:@"rate" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:MYViewControllerPlayerStatusObserverContext];

    [self.player addObserver:self forKeyPath:@"currentItem.tracks" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:MYViewControllerPlayerStatusObserverContext];

	// Add player item did play to end time observer.
	_playerItemDidPlayToEndTimeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		if (note.object == self.player.currentItem) {
			// Update play pause button.
			[self.playPauseButton setImage:[UIImage imageNamed:@"PlayButton"] forState:UIControlStateNormal];
		}
	}];
}

- (void)viewDidUnload {
	// Remove player item did play to end time observer.
	[[NSNotificationCenter defaultCenter] removeObserver:_playerItemDidPlayToEndTimeObserver];
	_playerItemDidPlayToEndTimeObserver = nil;
	
	// Remove time observer for current time slider and label.
	[self.player removeTimeObserver:_playerTimeObserver];
	_playerTimeObserver = nil;
	
	// Stop observing player's status.
	[self.player removeObserver:self forKeyPath:@"status" context:MYViewControllerPlayerStatusObserverContext];
	
	// Dettach player from player view.
	self.playerView.player = nil;
	
	[self setPlayerView:nil];
    [self setLeftChannelVolumeUnitMeterView:nil];
    [self setRightChannelVolumeUnitMeterView:nil];
	[self setPlayPauseButton:nil];
	[self setElapsedTimeLabel:nil];
	[self setCurrentTimeSlider:nil];
	[self setRemainingTimeLabel:nil];
	[self setSettingsPopoverButton:nil];
	
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ShowSettingsSegue"]) {
		// Setup settings view controller before it is shown.
		MYSettingsViewController *settingsViewController = (MYSettingsViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
		settingsViewController.delegate = self;
		settingsViewController.enabledSwitchValue = self.audioTapProcessor.isBandpassFilterEnabled;
		settingsViewController.centerFrequencySliderValue = self.audioTapProcessor.centerFrequency;
		settingsViewController.bandwidthSliderValue = self.audioTapProcessor.bandwidth;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (MYViewControllerPlayerStatusObserverContext == context) {
		id newValue = change[NSKeyValueChangeNewKey];
		if (newValue && [newValue isKindOfClass:[NSNumber class]]) {
			if (AVPlayerStatusReadyToPlay == [newValue integerValue]) {
				CMTime duration = self.player.currentItem.duration;
				
				// Setup current time indicators.
				self.elapsedTimeLabel.text = stringFromCMTime(kCMTimeZero, nil);
				self.currentTimeSlider.value = 0.0f;
				self.remainingTimeLabel.text = stringFromCMTime(duration, @"-");
				
				// Add time observer for current time slider and label.
                __weak MYViewController *weakSelf = self; // keep retain cycle from occuring
				_playerTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
					// Update current time indicators.
					weakSelf.elapsedTimeLabel.text = stringFromCMTime(time, nil);
					weakSelf.currentTimeSlider.value = (float)(CMTimeGetSeconds(time) / CMTimeGetSeconds(duration));
					weakSelf.remainingTimeLabel.text = stringFromCMTime(CMTimeSubtract(duration, time), @"-");
				}];
				
				// Add audio mix with audio tap processor to current player item.
				AVAudioMix *audioMix = self.audioTapProcessor.audioMix;
				if (audioMix) {
					// Add audio mix with first audio track.
					self.player.currentItem.audioMix = audioMix;
					
					// Enable settings popover button.
					self.settingsPopoverButton.enabled = YES;
				}
				
				// Enable play pause button and current time slider.
				self.playPauseButton.enabled = YES;
				self.currentTimeSlider.enabled = YES;
			}
		}
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark - IBActions

- (IBAction)togglePlayPause:(id)sender {
	NSParameterAssert(self.player);
	
	if (self.player.rate == 0.0f) {
		// Play from beginning when playhead is at end.
		if (CMTIME_COMPARE_INLINE(self.player.currentItem.currentTime, >=, self.player.currentItem.duration)) {
			[self.player.currentItem seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
		}
		
		// Start playback.
		self.player.rate = 1.0f;
		
		// Update play pause button.
		[self.playPauseButton setImage:[UIImage imageNamed:@"PauseButton"] forState:UIControlStateNormal];
	}
	else {
		// Stop playback.
		self.player.rate = 0.0f;
		
		// Update play pause button.
		[self.playPauseButton setImage:[UIImage imageNamed:@"PlayButton"] forState:UIControlStateNormal];
	}
}

- (IBAction)seekToTime:(id)sender {
	NSParameterAssert(self.player);
	
	// Seek to corresponding time.
	[self.player seekToTime:(CMTimeMultiplyByFloat64(self.player.currentItem.duration, (Float64)[(UISlider *)sender value])) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - MYAudioTabProcessorDelegate

- (void)audioTabProcessor:(MYAudioTapProcessor *)audioTabProcessor hasNewLeftChannelValue:(float)leftChannelValue rightChannelValue:(float)rightChannelValue {
	// Update left and right channel volume unit meter.
	self.leftChannelVolumeUnitMeterView.value = leftChannelValue;
	self.rightChannelVolumeUnitMeterView.value = rightChannelValue;
}

#pragma mark - MYSettingsViewControllerDelegate

- (void)settingsViewController:(MYSettingsViewController *)settingsViewController didUpdateEnabledSwitchValue:(float)switchValue {
	// Forward value to audio tap processor.
	self.audioTapProcessor.enableBandpassFilter = switchValue;
}

- (void)settingsViewController:(MYSettingsViewController *)settingsViewController didUpdateCenterFrequencySliderValue:(float)sliderValue {
	// Forward value to audio tap processor.
	self.audioTapProcessor.centerFrequency = sliderValue;
}

- (void)settingsViewController:(MYSettingsViewController *)settingsViewController didUpdateBandwidthSliderValue:(float)sliderValue {
	// Forward value to audio tap processor.
	self.audioTapProcessor.bandwidth = sliderValue;
}

@end

#pragma mark - Functions

static NSString *stringFromCMTime(CMTime time, NSString *sign) {
	NSString *stringFromCMTime;
	
	float seconds = round(CMTimeGetSeconds(time));
	int hh = (int)floorf(seconds / 3600.0f);
	int mm = (int)floorf((seconds - hh * 3600.0f) / 60.0f);
	int ss = (((int)seconds) % 60);
	
	if (hh > 0) {
		stringFromCMTime = [NSString stringWithFormat:@"%@%02d:%02d:%02d", (sign ? sign : @""), hh, mm, ss];
	}
	else {
		stringFromCMTime = [NSString stringWithFormat:@"%@%02d:%02d", (sign ? sign : @""), mm, ss];
	}
	
	return stringFromCMTime;
}
