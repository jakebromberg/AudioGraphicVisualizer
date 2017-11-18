#import "MYGradientView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MYGradientView

+ (Class)layerClass {
	return [CAGradientLayer class];
}

#pragma mark -

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setupLayerTree];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self setupLayerTree];
	}
	
	return self;
}

#pragma mark -

- (void)setupLayerTree {
	// Setup gradient layer.
	((CAGradientLayer *)self.layer).colors = @[(id)[[UIColor darkGrayColor] CGColor], (id)[[UIColor colorWithWhite:0.125f alpha:1.0f] CGColor], (id)[[UIColor blackColor] CGColor], (id)[[UIColor blackColor] CGColor]];
	((CAGradientLayer *)self.layer).locations = @[@0.0f, @0.5f, @0.5f, @1.0f];
}


@end
