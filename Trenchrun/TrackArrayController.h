#import <Cocoa/Cocoa.h>

@interface TrackArrayController : NSArrayController
{
	IBOutlet NSTableView *tableView;
}

/*
 support for drag and drop
 */

//- (BOOL)tableView:(NSTableView *)aTableView
//writeRowsWithIndexes:(NSIndexSet *)rowIndexes
//	 toPasteboard:(NSPasteboard*)pboard;
//
//
//- (NSDragOperation)tableView:(NSTableView*)tv
//				validateDrop:(id <NSDraggingInfo>)info
//				 proposedRow:(int)row
//	   proposedDropOperation:(NSTableViewDropOperation)op;
//
//
//- (BOOL)tableView:(NSTableView*)tv
//	   acceptDrop:(id <NSDraggingInfo>)info
//			  row:(int)row
//	dropOperation:(NSTableViewDropOperation)op;


@end

