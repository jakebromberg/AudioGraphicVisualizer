#import "MYSettingsViewController.h"

@interface MYSettingsViewController ()

// IBOutlets
@property (strong, nonatomic) IBOutlet UISwitch *enabledSwitch;
@property (strong, nonatomic) IBOutlet UISlider *centerFrequencySlider;
@property (strong, nonatomic) IBOutlet UISlider *bandwidthSlider;

// IBActions
- (IBAction)updateEnabledSwitchValue:(id)sender;
- (IBAction)updateCenterFrequencySliderValue:(id)sender;
- (IBAction)updateBandwidthSliderSliderValue:(id)sender;

@end

@implementation MYSettingsViewController

- (BOOL)enabledSwitchValue {
	// Make sure view is already loaded.
	if (!self.enabledSwitch)
		[self loadView];
	
	return self.enabledSwitch.isOn;
}

- (void)setEnabledSwitchValue:(BOOL)enabledSwitchValue {
	// Make sure view is already loaded.
	if (!self.enabledSwitch)
		[self loadView];
	
	self.enabledSwitch.on = enabledSwitchValue;
}

- (float)centerFrequencySliderValue {
	// Make sure view is already loaded.
	if (!self.centerFrequencySlider)
		[self loadView];
	
	return self.centerFrequencySlider.value;
}

- (void)setCenterFrequencySliderValue:(float)centerFrequencySliderValue {
	// Make sure view is already loaded.
	if (!self.centerFrequencySlider)
		[self loadView];
	
	self.centerFrequencySlider.value = centerFrequencySliderValue;
}

- (float)bandwidthSliderValue {
	// Make sure view is already loaded.
	if (!self.bandwidthSlider)
		[self loadView];
	
	return self.bandwidthSlider.value;
}

- (void)setBandwidthSliderValue:(float)bandwidthSliderValue {
	// Make sure view is already loaded.
	if (!self.bandwidthSlider)
		[self loadView];
	
	self.bandwidthSlider.value = bandwidthSliderValue;
}

#pragma mark - IBActions

- (IBAction)updateEnabledSwitchValue:(id)sender {
	// Forward switch value changes to delegate.
	if (self.delegate && [self.delegate respondsToSelector:@selector(settingsViewController:didUpdateEnabledSwitchValue:)])
		[self.delegate settingsViewController:self didUpdateEnabledSwitchValue:self.enabledSwitch.isOn];
}

- (IBAction)updateCenterFrequencySliderValue:(id)sender {
	// Forward slider value changes to delegate.
	if (self.delegate && [self.delegate respondsToSelector:@selector(settingsViewController:didUpdateCenterFrequencySliderValue:)])
		[self.delegate settingsViewController:self didUpdateCenterFrequencySliderValue:self.centerFrequencySlider.value];
}

- (IBAction)updateBandwidthSliderSliderValue:(id)sender {
	// Forward slider value changes to delegate.
	if (self.delegate && [self.delegate respondsToSelector:@selector(settingsViewController:didUpdateBandwidthSliderValue:)])
		[self.delegate settingsViewController:self didUpdateBandwidthSliderValue:self.bandwidthSlider.value];
}

@end
