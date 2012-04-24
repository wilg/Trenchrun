//
//  MocoDocument.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/13/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
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
#import "MocoTimelinePlaybackAnimation.h"

static NSString * kTrackEditContext = @"Track Edit";

@interface MocoDocument ( /* class extension */ ) {
    NSTimer *_playbackTimer;
    MocoTimelinePlaybackAnimation *_playbackAnimation;
}
@end

@implementation MocoDocument

@synthesize trackList = _trackList;
@synthesize rigPlaybackEngaged = _rigPlaybackEngaged;
@synthesize fps = _fps;
@synthesize  recording = _recording;
@synthesize playing = _playing;

-(id)init
{
	self = [super init];
	if ( self ) {

        self.recording = NO;
        self.rigPlaybackEngaged = YES;
        
        self.fps = 50;
        
        // create the collection array
        self.trackList = [[NSMutableArray alloc] init];

        [self addObserver:self
                    forKeyPath:@"trackList"
                       options:0
                       context:&kTrackEditContext];


        for (int i = 0; i < 8; i++) {
            MocoTrack *track = [[MocoTrack alloc] init];
            track.axis = i;
            [self.trackList addObject:track];
        }
        
//        [self add1000BogusFrames:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(axisDataUpdated:)
                                                     name:@"MocoAxisPositionUpdated"
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rigPlaybackStarted:)
                                                     name:@"MocoRigPlaybackStarted"
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
    
    for (MocoTrack *track in self.trackList) {
        [track bind:@"lastKnownPlayheadPosition" toObject:timelineViewController withKeyPath:@"playheadPosition" options:nil];
    }
    
}

- (MocoTrack *)trackWithAxis:(MocoAxis)axis {
    for (MocoTrack *track in self.trackList) {
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
    MocoAxisPosition *axisPosition = notification.object;
    if (self.recording) {
        [self savePosition:axisPosition.position
                   forAxis:axisPosition.axis];
    }
    MocoTrack *track = [self trackWithAxis:axisPosition.axis];
    track.currentPosition = axisPosition;
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
    for (MocoTrack *track in self.trackList) {
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
        self.recording = YES;
    else {
        [self stopRecording];
    }
}

-(IBAction)rewind:(id)sender {
    if (self.playing) {
        [self stopPlayback:nil];
    }
    if (self.recording) {
        [self stopRecording];
    }
    [timelineViewController backBySeconds:1];
}

-(IBAction)fastForward:(id)sender {
    if (self.playing) {
        [self stopPlayback:nil];
    }
    if (self.recording) {
        [self stopRecording];
    }
    [timelineViewController forwardBySeconds:1];
}

-(IBAction)beginning:(id)sender {
    if (self.playing) {
        [self stopPlayback:nil];
    }
    if (self.recording) {
        [self stopRecording];
    }
    [timelineViewController followPlayheadToFrame:0];
}

-(IBAction)play:(id)sender {
    if (self.recording) {
        [self stopRecording];
    }
    else {
        if (self.playing){
            [self stopPlayback:nil];
        }
        else {
            // play
            if (self.rigPlaybackEngaged && [self driver].recordAndPlaybackOperational) {
                [timelineViewController startPulsingPlayhead];
                [[self driver] beginPlaybackWithTracks:self.trackList atFrame:timelineViewController.playheadPosition];
            }
            else {
                [self startTimelinePlayback];
            }
            
            playButton.image = [NSImage imageNamed:@"Stop0N.tiff"];
            playButton.alternateImage = [NSImage imageNamed:@"StopBH.tiff"];
            
            self.playing = YES;
        }
    }
}

- (void)startTimelinePlayback {
    _playbackAnimation = [MocoTimelinePlaybackAnimation playTimelineAnimatedWithDelegate:self];
}

-(void)rigPlaybackStarted:(NSNotification *)notification{ 
    NSLog(@"Heard from the rig. Starting the timeline.");
    [self startTimelinePlayback];
    [timelineViewController stopPulsingPlayhead];
}

- (NSTimeInterval)durationOfTimelinePlaybackAnimation {
    return timelineViewController.timeRemaining;
}

- (NSTimeInterval)currentPlayheadTimeForTimelineAnimation {
    return timelineViewController.playheadTimeInterval;
}

- (void)timelinePlaybackAnimationDidAdvanceToTime:(NSTimeInterval)seconds {
//    NSLog(@"timelinePlaybackAnimationDidAdvanceToTime: %f", seconds);
    if (![timelineViewController playToTime:seconds]) {
        [self stopPlayback:nil];
    }
}

- (void)animationDidEnd:(NSAnimation *)animation {
    if (animation == _playbackAnimation) {
        [self stopPlayback:nil];
    }
}

-(void)stopRecording {
    self.recording = NO;
    recordButton.state = 0;
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
//    [_playbackTimer invalidate];
//    _playbackTimer = nil;
    [_playbackAnimation stopAnimation];
    _playbackAnimation = nil;
    
//    playButton.state = 0;
    self.playing = NO;
    
    playButton.image = [NSImage imageNamed:@"Play0N.tiff"];
    playButton.alternateImage = [NSImage imageNamed:@"Play0H.tiff"];
    
    [timelineViewController stopPulsingPlayhead];
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
