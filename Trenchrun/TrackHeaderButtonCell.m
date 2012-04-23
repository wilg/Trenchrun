#import "TrackHeaderButtonCell.h"
#import "NSImage+FlippedDrawing.h"

@implementation TrackHeaderButtonCell
@synthesize position;

#pragma mark Draw Functions

-(id)init {
	
	self = [super init];
	
	if(self) {
        self.highlightsBy = NSCellLightsByContents;
        self.position = WGButtonCellPositionAlone;
	}
	
	return self;
}


-(void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {

    if([self isHighlighted]) {
        image = [self image];
    }

    if (self.state ==  NSOnState) {
        image = [self alternateImage];
    }
    
    [super drawImage:image withFrame:frame inView:controlView];
 }

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    self.highlightsBy = NSCellLightsByGray;

    NSImage *background;
    
    if (self.state ==  NSOnState) {
        if (self.position == WGButtonCellPositionAlone) {
            background = [NSImage imageNamed:@"Track-HeaderButton-Single0H.tiff"];
        }
        else if (self.position == WGButtonCellPositionLeft) {
            background = [NSImage imageNamed:@"Track-HeaderButton-Left0H.tiff"];
        }
        else if (self.position == WGButtonCellPositionCenter) {
            background = [NSImage imageNamed:@"Track-HeaderButton-Middle0H.tiff"];
        }
        else if (self.position == WGButtonCellPositionRight) {
            background = [NSImage imageNamed:@"Track-HeaderButton-Right0H.tiff"];
        }
    }
    else {
        if (self.position == WGButtonCellPositionAlone) {
            background = [NSImage imageNamed:@"Track-HeaderButton-Single0N.tiff"];
        }
        else if (self.position == WGButtonCellPositionLeft) {
            background = [NSImage imageNamed:@"Track-HeaderButton-Left0N.tiff"];
        }
        else if (self.position == WGButtonCellPositionCenter) {
            background = [NSImage imageNamed:@"Track-HeaderButton-Middle0N.tiff"];
        }
        else if (self.position == WGButtonCellPositionRight) {
            background = [NSImage imageNamed:@"Track-HeaderButton-Right0N.tiff"];
        }
    }
    
    if([self isHighlighted]) {
        if (self.position == WGButtonCellPositionAlone) {
            background = [NSImage imageNamed:@"Track-HeaderButton-Single0H.tiff"];
        }
        else if (self.position == WGButtonCellPositionLeft) {
            background = [NSImage imageNamed:@"Track-HeaderButton-Left0H.tiff"];
        }
        else if (self.position == WGButtonCellPositionCenter) {
            background = [NSImage imageNamed:@"Track-HeaderButton-Middle0H.tiff"];
        }
        else if (self.position == WGButtonCellPositionRight) {
            background = [NSImage imageNamed:@"Track-HeaderButton-Right0H.tiff"];
        }
    }

    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];

    [ctx saveGraphicsState];

    [background drawAdjustedInRect:frame
                          fromRect:frame
                         operation:NSCompositeSourceOver
                          fraction:1.0];
    
    [ctx restoreGraphicsState];
    
}
#pragma mark -

@end
