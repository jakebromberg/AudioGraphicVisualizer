#import <UIKit/UIKit.h>

@protocol MYSettingsViewControllerDelegate;

@interface MYSettingsViewController : UITableViewController

// Properties
@property (weak, nonatomic) id <MYSettingsViewControllerDelegate> delegate;
@property (nonatomic) BOOL enabledSwitchValue;
@property (nonatomic) float centerFrequencySliderValue;
@property (nonatomic) float bandwidthSliderValue;

/*// IBOutlets
@property (strong, nonatomic) IBOutlet UISwitch *enabledSwitch;
@property (strong, nonatomic) IBOutlet UISlider *centerFrequencySlider;
@property (strong, nonatomic) IBOutlet UISlider *bandwidthSlider;

// IBActions
- (IBAction)updateEnabledSwitchValue:(id)sender;
- (IBAction)updateCenterFrequencySliderValue:(id)sender;
- (IBAction)updateBandwidthSliderSliderValue:(id)sender;*/

@end

#pragma mark - Protocols

@protocol MYSettingsViewControllerDelegate <NSObject>

// Add comment…
- (void)settingsViewController:(MYSettingsViewController *)settingsViewController didUpdateEnabledSwitchValue:(float)switchValue;
- (void)settingsViewController:(MYSettingsViewController *)settingsViewController didUpdateCenterFrequencySliderValue:(float)sliderValue;
- (void)settingsViewController:(MYSettingsViewController *)settingsViewController didUpdateBandwidthSliderValue:(float)sliderValue;

@end
