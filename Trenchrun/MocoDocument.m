//
//  MocoDocument.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <stdlib.h>

#import "MocoTimelineView.h"
#import "MocoDocument.h"
#import "MocoFrame.h"
#import "MocoTrack.h"
#import "MocoDriverResponse.h"
#import "MocoAxisPosition.h"
#import "MocoAppDelegate.h"
#import "MocoDriver.h"

static NSString * kTrackEditContext = @"Track Edit";

@interface MocoDocument ( /* class extension */ ) {
    NSTimer *_playbackTimer;
}
@end

@implementation MocoDocument

@synthesize trackList, flattenedFrameArray, rigPlaybackEngaged;

-(id)init
{
	self = [super init];
	if ( self ) {

        recording = NO;
        self.rigPlaybackEngaged = YES;
        
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

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [timelineViewController refreshGraph:nil];
    [super windowControllerDidLoadNib:windowController];
    
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
    MocoTrack *track = [self trackWithAxis:axis];
    if (track.recordEnabled) {
        [track appendFrameWithPosition:position];
        [timelineViewController followPlayheadToFrame:track.frames.count];
        [self updateChangeCount:NSChangeDone];
    }
}

- (void)axisDataUpdated:(NSNotification *)notification {
    if (recording) {
        MocoAxisPosition *axisPosition = notification.object;
        [self savePosition:axisPosition.position
                   forAxis:axisPosition.axis];
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
        [self savePosition:[NSNumber numberWithFloat:(float)random()/RAND_MAX] forAxis:track.axis];
    }
}

-(IBAction)addManyBogusFrames:(id)sender {
    int i = 0;
    
    while (i < 50) {
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

-(IBAction)play:(id)sender {
    if (recording) {
        [self record:nil];
    }
    else {
        NSButton *button = (NSButton *)sender;
        if (button.state == 1){
            // play
            if (rigPlaybackEngaged) {
                [[self driver] beginPlaybackWithTracks:self.trackList atFrame:timelineViewController.playheadPosition];
            }
            
            // fake playback on the driver
            _playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/50.0 target:self selector:@selector(advanceFrame) userInfo:nil repeats:YES];
        }
        else {
            // pause
            [self stopPlayback:nil];
        }
    }
}

-(void)advanceFrame {
    if (![timelineViewController playOneFrame]) {
        [self stopPlayback:nil];
    }
}

- (MocoAppDelegate *)appDelegate {
    return (MocoAppDelegate *)[[NSApplication sharedApplication] delegate];
}

- (MocoDriver *)driver {
    return [self appDelegate].mocoDriver;
}

-(IBAction)stopPlayback:(id)sender {
    [[self driver] pausePlayback];
    [_playbackTimer invalidate];
    _playbackTimer = nil;
    playButton.state = 0;
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
