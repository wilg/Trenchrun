//
//  MocoDocument.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <stdlib.h>

#import "TrackArrayController.h"
#import "MocoTimelineView.h"
#import <CorePlot/CorePlot.h>
#import "MocoDocument.h"
#import "MocoFrame.h"
#import "MocoTrack.h"

static NSString * kTrackEditContext = @"Track Edit";

@implementation MocoDocument

@synthesize trackList, flattenedFrameArray;

-(id)init
{
	self = [super init];
	if ( self ) {
//		dataPoints	   = [NSMutableArray array];
//		zoomAnnotation = nil;
//		dragStart	   = CGPointZero;
//		dragEnd		   = CGPointZero;
        
        // create the collection array
        trackList = [[NSMutableArray alloc] init];

        [self addObserver:self
                    forKeyPath:@"trackList"
                       options:0
                       context:&kTrackEditContext];


        for (int i = 0; i < 8; i++) {
            MocoTrack *track = [[MocoTrack alloc] init];
            track.axis = i;
            [trackList addObject:track];
        }
        
    
	}
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == &kTrackEditContext) {
        [self tracksDidChange];
    }
    else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

-(void)tracksDidChange {
    [self updateChangeCount:NSChangeDone];
    
//    [self updateGraphs];

}

-(NSString *)windowNibName
{
	return @"MocoDocument";
}

-(void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
//    [self updateGraphs];
    
}
//
//- (void)graphNormalizedData {
//    
//    [dataPoints removeAllObjects];
//    
//    minimumValueForXAxis = MAXFLOAT;
//    maximumValueForXAxis = -MAXFLOAT;
//    
//    minimumValueForYAxis = MAXFLOAT;
//    maximumValueForYAxis = -MAXFLOAT;
//    
//    for (MocoFrame *frame in self.frameList) {
//        
//        double xValue = [frame.frameNumber doubleValue];
//        double yValue = [frame.cameraPan doubleValue];
//        if ( xValue < minimumValueForXAxis ) {
//            minimumValueForXAxis = xValue;
//        }
//        if ( xValue > maximumValueForXAxis ) {
//            maximumValueForXAxis = xValue;
//        }
//        if ( yValue < minimumValueForYAxis ) {
//            minimumValueForYAxis = yValue;
//        }
//        if ( yValue > maximumValueForYAxis ) {
//            maximumValueForYAxis = yValue;
//        }
//        
//        [dataPoints addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:xValue], @"x", [NSNumber numberWithDouble:yValue], @"y", nil]];
//        
//        // Create a dictionary of the items, keyed to the header titles
//        //			NSDictionary *keyedImportedItems = [[NSDictionary alloc] initWithObjects:columnValues forKeys:columnHeaders];
//        // Process this
//    }
//    
//    majorIntervalLengthForX = (maximumValueForXAxis - minimumValueForXAxis) / 5.0;
//    if ( majorIntervalLengthForX > 0.0 ) {
//        majorIntervalLengthForX = pow( 10.0, ceil( log10(majorIntervalLengthForX) ) );
//    }
//    
//    majorIntervalLengthForY = (maximumValueForYAxis - minimumValueForYAxis) / 10.0;
//    if ( majorIntervalLengthForY > 0.0 ) {
//        majorIntervalLengthForY = pow( 10.0, ceil( log10(majorIntervalLengthForY) ) );
//    }
//    
//    minimumValueForXAxis = floor(minimumValueForXAxis / majorIntervalLengthForX) * majorIntervalLengthForX;
//    minimumValueForYAxis = floor(minimumValueForYAxis / majorIntervalLengthForY) * majorIntervalLengthForY;
//    
//}
//
//- (void)updateGraphs {
//    
//    [self graphNormalizedData];
//
//    
//	// Create graph from theme
//    if (!graph) {
//        graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:CGRectZero];
//        CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
//        [graph applyTheme:theme];
//        graphView.hostedGraph = graph;
//
//        graph.paddingLeft	= 0.0;
//        graph.paddingTop	= 0.0;
//        graph.paddingRight	= 0.0;
//        graph.paddingBottom = 0.0;
//        
//        //	graph.plotAreaFrame.paddingLeft	  = 55.0;
//        //	graph.plotAreaFrame.paddingTop	  = 40.0;
//        //	graph.plotAreaFrame.paddingRight  = 40.0;
//        //	graph.plotAreaFrame.paddingBottom = 35.0;
//        
//        graph.plotAreaFrame.paddingLeft	  = 4.0;
//        graph.plotAreaFrame.paddingTop	  = 4.0;
//        graph.plotAreaFrame.paddingRight  = 4.0;
//        graph.plotAreaFrame.paddingBottom = 4.0;
//        
//        graph.plotAreaFrame.plotArea.fill = graph.plotAreaFrame.fill;
//        graph.plotAreaFrame.fill		  = nil;
//        
//        graph.plotAreaFrame.borderLineStyle = nil;
//        graph.plotAreaFrame.cornerRadius	= 0.0;
//
//    
//    
//        // Setup plot space
//        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
//        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:[[NSNumber numberWithFloat:0.0] decimalValue] 
//                                                        length:[[NSNumber numberWithFloat:1.0] decimalValue]];
//        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:[[NSNumber numberWithFloat:0.0] decimalValue] 
//                                                        length:[[NSNumber numberWithFloat:1.0] decimalValue]];
//        
//        // this allows the plot to respond to mouse events
//        [plotSpace setDelegate:self];
//        [plotSpace setAllowsUserInteraction:NO];
//        
//        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
//        
//        CPTXYAxis *x = axisSet.xAxis;
//        x.labelingPolicy        = CPTAxisLabelingPolicyNone;
//    //	x.minorTicksPerInterval = 9;
//    //	x.majorIntervalLength	= CPTDecimalFromDouble(majorIntervalLengthForX);
//        x.labelOffset			= 5.0;
//        x.axisConstraints		= [CPTConstraints constraintWithLowerOffset:0.0];
//        
//        CPTXYAxis *y = axisSet.yAxis;
//        y.labelingPolicy        = CPTAxisLabelingPolicyNone;
//    //	y.minorTicksPerInterval = 9;
//    //	y.majorIntervalLength	= CPTDecimalFromDouble(majorIntervalLengthForY);
//        y.labelOffset			= 5.0;
//        y.axisConstraints		= [CPTConstraints constraintWithLowerOffset:0.0];
//        
//        // Create the main plot for the delimited data
//        CPTScatterPlot *dataSourceLinePlot = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame:graph.bounds];
//        dataSourceLinePlot.identifier = @"Data Source Plot";
//        
//        CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
//        lineStyle.lineWidth				 = 3.0;
//        lineStyle.lineColor				 = [CPTColor colorWithComponentRed:0.153 green:0.453 blue:0.782 alpha:1.000];
//        dataSourceLinePlot.dataLineStyle = lineStyle;
//        
//        dataSourceLinePlot.dataSource = self;
//        [graph addPlot:dataSourceLinePlot];
//    
//    }
//    
//    // Setup plot space
//    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
//    
//    if (dataPoints.count >= 2) {
//        
//        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForXAxis)
//                                                        length:CPTDecimalFromDouble(ceil( (maximumValueForXAxis - minimumValueForXAxis) / majorIntervalLengthForX ) * majorIntervalLengthForX)];
//        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForYAxis)
//                                                        length:CPTDecimalFromDouble(ceil( (maximumValueForYAxis - minimumValueForYAxis) / majorIntervalLengthForY ) * majorIntervalLengthForY)];
//
//    }
//
//    [[graph plotAtIndex:0] reloadData];
//    
//    //
////    [graph reloadData];
////    [graphView setNeedsDisplay:YES];
//    
//}
//


+ (BOOL)autosavesInPlace
{
    return NO;
}


#pragma mark -
#pragma mark Data loading methods

-(NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	// Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.
    
    // create an archive of the collection and its attributes
    NSKeyedArchiver *archiver;
    NSMutableData *data = [NSMutableData data];
	
    archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	
    [archiver encodeObject:self.trackList forKey:@"trackList"];
    	
    [archiver finishEncoding];
	
    return data;

    
//	// You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
//    
//	// For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
//    
//	if ( outError != NULL ) {
//		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
//	}
//	return nil;
}

-(BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{

    NSKeyedUnarchiver *unarchiver;
	
	// extract an archive of the collection and its attributes
    unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	
    self.trackList = [unarchiver decodeObjectForKey:@"trackList"];
	
    [self updateChangeCount:NSChangeCleared];

    [unarchiver finishDecoding];
	
	if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    
	return YES;
}
//
//
//
//#pragma mark -
//#pragma mark Plot Data Source Methods
//
//-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
//{
//	return [dataPoints count];
//}
//
//-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
//{
//	NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
//	NSNumber *num = [[dataPoints objectAtIndex:index] valueForKey:key];
//    
//	return num;
//}
#pragma mark -
#pragma mark UI Shit

-(IBAction)addBogusFrame:(id)sender {
    
    
    int nextFrame = [[(MocoTrack *)[trackList lastObject] frames] count];
    nextFrame++;
    
    

    for (MocoTrack *track in trackList) {
        MocoFrame *frame = [[MocoFrame alloc] init];
        frame.frameNumber = [NSNumber numberWithInt:nextFrame];
        frame.position = [NSNumber numberWithFloat:(float)random()/RAND_MAX];
        [track addFrame:frame];
    }
        
}

-(IBAction)add1000BogusFrames:(id)sender {
    int i = 0;
    while (i < 1000) {
        [self addBogusFrame:nil];
        i++;
    }
}


@end
