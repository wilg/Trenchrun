//
//  TrackHeaderButtonCell.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/23/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    WGButtonCellPositionLeft       = 0,
    WGButtonCellPositionCenter      = 1,
    WGButtonCellPositionRight         = 2,
    WGButtonCellPositionAlone         = 3
} WGButtonCellPosition;

@interface TrackHeaderButtonCell : NSButtonCell
@property WGButtonCellPosition position;

@end
