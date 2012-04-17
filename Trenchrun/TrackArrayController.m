#import "TrackArrayController.h"
#import "MocoFrame.h"


@implementation TrackArrayController


#pragma mark ======== drag and drop methods =========
/* 
 ** --------------------------------------------------------
 **   Standard table view data source drag and drop methods
 ** --------------------------------------------------------
 
 These methods implement support for drag and drop for table views.
 
 These methods are described in
 - NSTableDataSource Protocol Objective-C Reference 
 - Table View Programming Guide
 */

//- (BOOL)tableView:(NSTableView *)aTableView
//writeRowsWithIndexes:(NSIndexSet *)rowIndexes
//	 toPasteboard:(NSPasteboard*)pboard
//{
//	/*
//	 If copied row has an URL, add NSURLPboardType to the declared types and write the URL to the pasteboard
//	 */
//	
//	/*
//	 For convenience, conciseness, and clarity, assume here that multiple selections are not allowed.
//	 */
//	unsigned int row = [rowIndexes firstIndex];
//	
//	/*
//	 The objects display in the table view may be in a different order than they appear in the original collection.  The content may even be filtered.  The arrangedObjects method returns the objects the table view displays, in the order in which it displays them.
//	 */
//	NSURL *url = [[[self arrangedObjects] objectAtIndex:row] URL];
//	
//	/*
//	 If the copied row does not have an URL, then exit
//	 */
//	if (url == nil)
//	{
//		return NO;
//	}
//	
//	/*
//	 Declare the pastboard types and write the corresponding data
//	 */
//	NSArray *pboardTypes = [NSArray arrayWithObjects:NSURLPboardType, NSStringPboardType, nil];
//	[pboard declareTypes:pboardTypes owner:self];
//	
//    [pboard setString:[url absoluteString] forType:NSStringPboardType];
//	[url writeToPasteboard:pboard];
//	
//	return YES;
//}
//
//
//
//
//- (NSDragOperation)tableView:(NSTableView*)tv
//				validateDrop:(id <NSDraggingInfo>)info
//				 proposedRow:(int)row
//	   proposedDropOperation:(NSTableViewDropOperation)op
//{
//    
//	if ([info draggingSource] == tableView)
//	{
//		return NSDragOperationNone;
//    }
//	
//	NSDragOperation dragOp = NSDragOperationNone;
//	
//	NSURL *url = [NSURL URLFromPasteboard:[info draggingPasteboard]];
//	
//	if (url != nil)
//	{
//		dragOp = NSDragOperationCopy;
//		/*
//		 we want to put the object at, not over, the current row (contrast NSTableViewDropOn) 
//		 */
//		[tv setDropRow:row dropOperation:NSTableViewDropAbove];
//	}
//	
//    return dragOp;
//}
//
//
//- (BOOL)tableView:(NSTableView*)tv
//	   acceptDrop:(id <NSDraggingInfo>)info
//			  row:(int)row
//	dropOperation:(NSTableViewDropOperation)op
//{
//    if (row < 0)
//	{
//		row = 0;
//	}
//    
//	// Can we get an URL?  If not, return NO.
//	NSURL *url = [NSURL URLFromPasteboard:[info draggingPasteboard]];
//	
//	if (url == nil)
//	{
//		return NO;
//	}
//	
//	// create and configure a new Bookmark
//	Bookmark *newBookmark = [self newObject];
//	[newBookmark setURL:url];
//	[newBookmark setTitle:[url absoluteString]];
//
//	/*
//	 The objects display in the table view may be in a different order than they appear in the original collection.  The content may even be filtered.  Using insertObject:atArrangedObjectIndex: inserts the object at the right place, taking sort orderings and filters into account.
//
//	 */
//	[self insertObject:newBookmark atArrangedObjectIndex:row];
//	[newBookmark release];
//
//	/*
//	 There is no need to update the selection detail fields etc.
//	 The values of the detail fields are bound to properties of the array controller's selection. As the selection changes, the fields are updated automatically through KVO.
//	 */
//	return YES;		
//}



#pragma mark ======== awakeFromNib =========
/* 
 ** --------------------------------------------------------
 **    awakeFromNib
 ** --------------------------------------------------------
 
 Here awakeFromNib is used to register the table view for dragged types an set the drag mask
 */

//- (void)awakeFromNib
//{
//	[tableView setDraggingSourceOperationMask:NSDragOperationLink
//									 forLocal:NO];
//	[tableView setDraggingSourceOperationMask:NSDragOperationMove
//									 forLocal:YES];
//	[tableView registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
//}


@end

