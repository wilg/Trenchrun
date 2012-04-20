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
#import "MocoDriverResponse.h"

static NSString * kTrackEditContext = @"Track Edit";

@implementation MocoDocument

@synthesize trackList, flattenedFrameArray;

-(id)init
{
	self = [super init];
	if ( self ) {

        recording = NO;
        
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
        
//        [self add1000BogusFrames:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(axisDataUpdated:)
                                                     name:@"MocoAxisPositionUpdated"
                                                   object:nil];

    
	}
	return self;
}

- (void)awakeFromNib {
    [timelineViewController.view setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    [timelineViewController.view setFrame:[timelineContainer bounds]];
    [timelineContainer addSubview:timelineViewController.view];
}

- (MocoTrack *)trackWithAxis:(MocoAxis)axis {
    for (MocoTrack *track in trackList) {
        if (track.axis == axis)
            return track;
    }
    return nil;
}


- (void)savePosition:(NSNumber *)position forAxis:(MocoAxis)axis {
    [[self trackWithAxis:axis] appendFrameWithPosition:position];
    [self updateChangeCount:NSChangeDone];
}

- (void)axisDataUpdated:(NSNotification *)notification {
    if (recording) {
        MocoDriverResponse *driverResponse = notification.object;
        [self savePosition:[driverResponse.parsedResponse valueForKey:@"position"]
                   forAxis:[[driverResponse.parsedResponse valueForKey:@"axis"] intValue]];
//        [self tracksDidChange];
    }
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
    [timelineViewController refreshGraph:nil];
    [self updateChangeCount:NSChangeDone];
}

-(NSString *)windowNibName
{
	return @"MocoDocument";
}

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

#pragma mark -
#pragma mark UI Shit

-(IBAction)addBogusFrame:(id)sender {
    for (MocoTrack *track in trackList) {
        [track appendFrameWithPosition:[NSNumber numberWithFloat:(float)random()/RAND_MAX]];
    }
    [self tracksDidChange];
}

-(IBAction)add1000BogusFrames:(id)sender {
    int i = 0;
    while (i < 1000) {
        [self addBogusFrame:nil];
        i++;
    }
}

-(IBAction)swapViews:(id)sender {
    if (viewSwapControl.selectedSegment == 0) {
        viewSwapControl.selectedSegment = 1;
    }
    else {
        viewSwapControl.selectedSegment = 0;
    }
    [self updateFakeTabs:viewSwapControl];
}

-(IBAction)record:(id)sender {
    NSButton *button = (NSButton *)sender;
    if (button.state == 1)
        recording = YES;
    else {
        recording = NO;
    }
}

-(IBAction)updateFakeTabs:(id)sender {
    NSSegmentedControl *button = (NSSegmentedControl *)sender;
    if (button.selectedSegment == 0) {
        timelineViewController.view.frame = timelineContainer.bounds;

        [timelineContainer addSubview:timelineViewController.view];
        [listView removeFromSuperview];
    }
    else {
        listView.frame = timelineContainer.bounds;
        [timelineContainer addSubview:listView];
        [timelineViewController.view removeFromSuperview];
    }
}


@end
