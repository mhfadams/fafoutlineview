
//	FAFOutlineView.h
//  Copyright 2014 Manoah F. Adams. <federaladamsfamily.com/developer>
//
/*
 FAFOutlineView is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 FAFOutlineView is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with FAFOutlineView.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "FAFOutlineView.h"
#import "FAFNSBezierPathAdditions.h"
#import "FAFOutlineViewItem.h"
#import "FAFOutlineViewRootItem.h"

const NSTimeInterval DOUBLE_CLICK_MAX_INTERVAL = 1.0;
//const NSTimeInterval SINGLE_CLICK_MAX_INTERVAL = 3.0;
//const NSTimeInterval LONG_DOUBLE_CLICK_MIN_INTERVAL = 1.3;
const NSTimeInterval LONG_DOUBLE_CLICK_MAX_INTERVAL = 2.0;

@interface FAFOutlineView (internal)

- (void) setup;
-(void)doClick:(id)sender;
-(void)doDoubleClick:(id)sender;

- (int)spanForTableColumn:(NSTableColumn *)tableColumn row:(int)row;


	/* Drag and Drop */
	/* This method is called after it has been determined that a drag should begin, 
	but before the drag has been started.  To refuse the drag, return NO.  
	To start a drag, return YES and place the drag data onto the pasteboard (data, owner, etc...).  
	The drag image and other drag related information will be set up and provided by the outline view 
	once this call returns with YES.  The items array is the list of items that will be participating 
	in the drag.
	*/
- (BOOL)outlineView:(NSOutlineView *)olv writeItems:(NSArray*)items toPasteboard:(NSPasteboard*)pboard;

/* This method is used by NSOutlineView to determine a valid drop target.  Based on the mouse position, the outline view will suggest a proposed drop location.  This method must return a value that indicates which dragging operation the data source will perform.  The data source may "re-target" a drop if desired by calling setDropItem:dropChildIndex: and returning something other than NSDragOperationNone.  One may choose to re-target for various reasons (eg. for better visual feedback when inserting into a sorted position).
	*/
- (NSDragOperation)outlineView:(NSOutlineView*)olv validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)index;

	/* This method is called when the mouse is released over an outline view that previously decided to allow a drop via the validateDrop method.  The data source should incorporate the data from the dragging pasteboard at this time.
	*/
- (BOOL)outlineView:(NSOutlineView*)olv acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index;

@end

@implementation FAFOutlineView


#pragma mark Setup
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (nil != self)
	{
		[self setup];

	}
	return self;
}

- (void) setup
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	if (inited == 0)
	{
		_inDragOperation = NO;
		
		realTarget = nil;
		realDelegate = nil;
		lastClickTime = [[NSApp currentEvent] timestamp];
		
		lastClickEventNumber = 0;
		_canEditOnNextClick = YES;
		
		realDoubleAction = NULL;
		
		_isOpaque = YES;
		
		[self setGridStyleMask:NSTableViewGridNone];
		_shouldShowLabels = NO;
		
		OutlineViewItemClass = [FAFOutlineViewItem class];
	}
	inited = 1;
}


- (Class)OutlineViewItemClass
{
    return OutlineViewItemClass;
}

- (void)setOutlineViewItemClass:(Class)value
{
	if ( ! realDelegate)
		OutlineViewItemClass = value;
	else
	{
		[NSException raise:NSInternalInconsistencyException
					format:@"%s: Error: you must set this value before setting my delegate.", __PRETTY_FUNCTION__];
	}
}


- (id) delegate
{
	return realDelegate;
}


- (void) setDelegate: (id) object
{
	/*
	 Turn on the log item below and find a very strange situation when FAFOutlineView is subclassed:
		this method is called *before* -initWithFrame ! (and after of course).
	 [super setDelegate:self] must be here, not in init, as it does not work if put in init !
	 Also, on that first call, object will be nil !
	 */
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	if (inited == 0) return;

	//if (object)
	{
		realDelegate = object;
		[super setDelegate:self];
		[super setDataSource:self];
		//rootItem = [[realDelegate rootItem] retain];
		
		[[self tableColumns] makeObjectsPerformSelector:@selector(setEditable:) withObject:NO];
		/*
		NSEnumerator* e = [[self tableColumns] objectEnumerator];
		NSTableColumn* column;
		while (column = [e nextObject])
		{
			[column setEditable:NO];
		}
		*/
		
		
		//[super setTarget:self];
		_target = self;
		//[super setAction:@selector(doClick:)];
		_action = @selector(doClick:);
		//[super setDoubleAction:@selector(doDoubleClick:)];
		_doubleAction = @selector(doDoubleClick:);
		
		[self reloadData];
	}
	//NSLog(@"%s %@", __PRETTY_FUNCTION__, [super delegate]);
}

/*
 We cannot implement this method, as super's internals always call [self target] rather than 
 accessing _target directly, thus super class gets fooled if we do this.
- (id) target
{
	return realTarget;
}
*/

- (void) setTarget: (id) object
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	realTarget = object;
	//NSLog(@"%@", [super target]);
}

- (void)setDoubleAction:(SEL)aSelector
{
	realDoubleAction = aSelector;
	if (realDoubleAction == NULL)
		NSLog(@"FAFOutlineView edit mode: short-double-click");
	else
		NSLog(@"FAFOutlineView edit mode: long-double-click");

}

/*
 We cannot implement this method, as super's internals always call [self doubleAction] rather than 
 accessing _doubleAction directly, thus super class gets fooled if we do this.
- (SEL)doubleAction
{
	return realDoubleAction;
}
*/
- (void) setDataSource: (id) dataSource
{
	/* We are the data source, to trap, and warn user of unneeded message */
	NSLog(@"%s Notice: no need to call setDataSource: on FAFOutlineView.", __PRETTY_FUNCTION__);
}

-(void)dealloc
{
	[rootItem release];
	//[super dealloc]; //<- why cant I continue it ? why does [self setDataSource:] get called in [super dealloc] ?
}

#pragma mark Transparency

- (BOOL)isOpaque {
    return _isOpaque;
}

- (void)setIsOpaque:(BOOL)value {
    if (_isOpaque != value)
	{
        _isOpaque = value;
    }
    if ( ! _isOpaque) [[self enclosingScrollView] setDrawsBackground: NO];
}

- (void)awakeFromNib
{
	
	[self setup];

	_isOpaque = YES;

}

- (void)drawBackgroundInClipRect:(NSRect)clipRect
{
	if ( ! _isOpaque) // don't draw a background rect
		;
	else
		[super drawBackgroundInClipRect:clipRect];
}

#pragma mark Root Item

- (FAFOutlineViewItem*) rootItem
{
	return rootItem;
}

- (FAFOutlineViewRootItem*) rootItemWithObject:(id) object
{
	/* NOTICE:
	Every time we are told to reloadData, which is often, and certainly more than once, we must ask
	the delegate for the root item (since it may have changed).
	If the Delegate has used this convenience method, then we'd be giving back a new root each time,
	which is not normally what the delegate wanted.
	Therefore, we must be sure to return a singleton.
	*/
	//static FAFOutlineViewRootItem* rItem; <- DONT USE STATICS !! they get shared across outline views !!
	if ( ! rItem )
	{	
		rItem = [[FAFOutlineViewRootItem alloc] initWithItem:object];
		[rItem setOutlineView:self];
		[rItem autorelease];
	}
	else // if object is different than current, then still make new rootItem
	{
		if ( ! ([[rItem representedObject] isEqual: object]) )
		{
			//NSLog(@"returning new root");
			rItem = [[[FAFOutlineViewRootItem alloc] initWithItem:object] autorelease];
			[rItem setOutlineView:self];
		}
	}
	return rItem;
}


- (void) reloadData
{
	[rootItem autorelease]; // <-- this has to be *auto*release, because we might get handed back the same item.
	rootItem = [[realDelegate rootItemForOutlineView:self] retain];
	[rootItem reload];
	[super reloadData];
}



-(void)doClick:(id)sender
{
		
	NSEvent* e = [NSApp currentEvent];
	NSTimeInterval interval;
	interval = [e timestamp] - lastClickTime;
	//NSLog(@"Interval: %8.3f", interval);
		
	
	if // LONG DOUBLE CLICK
		(
		 _canEditOnNextClick
		 &&
		 (interval < LONG_DOUBLE_CLICK_MAX_INTERVAL) //SINGLE_CLICK_MAX_INTERVAL)
		 &&
		 (lastClickedRow == [self clickedRow])
		 &&
		 (lastClickedColumn == [self clickedColumn])
		 )		 
	{
		//NSLog(@"%s - Long DoubleClick", __PRETTY_FUNCTION__);
		int row = [self selectedRow];
		if ( (row != -1) && (realDoubleAction != NULL) )
		{
			if ([self outlineView:self //realDelegate[self delegate]
			shouldEditTableColumn:[[self tableColumns] objectAtIndex:lastClickedColumn] 
							 item:[self itemAtRow:row]])
				[self editColumn:lastClickedColumn row:row withEvent:e select:YES];
		}
	}
	else // SINGLE CLICK
	{
		//NSLog(@"%s - Single Click", __PRETTY_FUNCTION__);
		if (realAction)
		{
			[realTarget performSelector:realAction withObject:sender];
		}
	}
	
	
	// set up for next check ...
	lastClickTime = [e timestamp];
	lastClickedColumn = [self clickedColumn];
	lastClickedRow = [self clickedRow];
	_canEditOnNextClick = YES;

	
	return;
	
	
}

-(void)doDoubleClick:(id)sender
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	_canEditOnNextClick = NO;
	if (realDoubleAction == NULL)
	{
		int row = [self selectedRow];
		if (row != -1)
		{
			if ([self outlineView:self
			shouldEditTableColumn:[[self tableColumns] objectAtIndex:[self clickedColumn]] 
							 item:[self itemAtRow:row]])
				[self editColumn:lastClickedColumn row:row withEvent:[NSApp currentEvent] select:YES];
		}
	}
	else
		[realTarget performSelector:realDoubleAction withObject:sender];
		
}




/*

// NSTableView delegate
-(void)tableViewSelectionDidChange:(NSNotification *)notification {
	NSLog(@"tableViewSelectionDidChange:");
	[realDelegate performSelector:@selector(tableViewSelectionDidChange:) withObject:notification];
}
*/


- (void)drawRow:(int)row clipRect:(NSRect)clipRect
{
#pragma mark Row Label Color (drawRow:clipRect:)
	/*** LABEL DRAWING ***/
	if (_shouldShowLabels)
	{
		//[NSGraphicsContext saveGraphicsState];
		[self lockFocus];
		NSRect rowRect = [self rectOfRow:row];
		NSRect rect = NSMakeRect(rowRect.origin.x + 1.0,
								 rowRect.origin.y + 1.0,
								 rowRect.size.width - 2.0,
								 rowRect.size.height - 1.0);
		NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:rect];
		NSString* labelColor = [[self itemAtRow:row] labelColor];
		if ([labelColor isEqualToString:@"Red"])
		{	
			[[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.6] set];
		}
		else if ([labelColor isEqualToString:@"Orange"])
		{	
			[[NSColor colorWithCalibratedRed:1.0 green:0.5 blue:0.2 alpha:0.6] set];
		}
		else if ([labelColor isEqualToString:@"Yellow"])
		{	
			[[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:0.0 alpha:0.6] set];
		}
		else if ([labelColor isEqualToString:@"Green"])
		{	
			[[NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:0.6] set];
		}
		else if ([labelColor isEqualToString:@"Blue"])
		{	
			[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:0.6] set];
		}
		else if ([labelColor isEqualToString:@"Purple"])
		{	
			[[NSColor colorWithCalibratedRed:0.5 green:0.0 blue:0.8 alpha:0.6] set];
		}
		else if ([labelColor isEqualToString:@"Gray"])
		{	
			[[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:0.6] set];
		}
		else
		{
			path = [NSBezierPath bezierPathWithRect:rect];
			[[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0] set];
		}
		[path fill];
		//[NSGraphicsContext restoreGraphicsState];
		[self unlockFocus];
	}
	
	
#pragma mark Row Spanning (drawRow:clipRect:)
	/*** ROW SPANNING ***/
	NSRect newClipRect = clipRect;
	{
		int colspan = 0;
		int firstCol
			= [self columnsInRect:clipRect].location;
		// Does the FIRST one of these have a zero-colspan?  If so, extend range.
		while (0 == colspan)
		{
			colspan = [self spanForTableColumn:[[self tableColumns] objectAtIndex:firstCol] row:row];
			if (0 == colspan)
			{
				firstCol--;
				newClipRect = NSUnionRect(newClipRect,
										  [self frameOfCellAtColumn:firstCol row:row]);
			}
		}
	}
	
	
	/*** finish with default implementation ***/
	[super drawRow:row clipRect:newClipRect];
	//[super drawRow:row clipRect:clipRect];
}

#pragma mark Row Spanning (frameOfCellAtColumn:row:)
- (NSRect)frameOfCellAtColumn:(int)column row:(int)row
{
	if (column == -1) return [super frameOfCellAtColumn:column row:row];
	int colspan;
	colspan = [self spanForTableColumn:[[self tableColumns] objectAtIndex:column] row:row];
	if (0 == colspan)
	{
		return NSZeroRect;
	}
	if (1 == colspan)
	{
		return [super frameOfCellAtColumn:column row:row];
	}
	else      // 2 or more, it's responsibility of data source to provide reasonable number
	{
		NSRect merged
		= [super frameOfCellAtColumn:column row:row];
		// start out with this one
		int i;
		for (i = 1; i < colspan; i++ )   // start from next one
		{
			NSRect next
            = [super frameOfCellAtColumn:column+i row:row];
			merged = NSUnionRect(merged,next);
		}
		return merged;
	}
}



#pragma mark Row Spanning (drawGridInClipRect:)
- (void)drawGridInClipRect:(NSRect)rect
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	{
		NSRange rowRange = [self rowsInRect:rect];
		NSRange columnRange = [self columnsInRect:rect];
		int row;
		// Adjust column range, always go from zero, so we can gather columns even to 
		// the left of what we are supposed to draw.
		columnRange = NSMakeRange(0,NSMaxRange(columnRange));
		[[NSColor grayColor] set];
		for (   row = rowRange.location ;
				row < NSMaxRange(rowRange) ;
				row++ )
		{
			int col = columnRange.location;
			int oldLeftEdge
				= 0.5 + [self rectOfColumn:col].origin.x;
			NSRect rowRect = [self rectOfRow:row];
			// here, frame not the top and not the left, but the bottom
			[NSBezierPath strokeLineFromPoint:
				NSMakePoint(rowRect.origin.x,
							-0.5+rowRect.origin.y+rowRect.size.height)
									  toPoint:
				NSMakePoint(rowRect.origin.x + rowRect.size.width,
							-0.5+rowRect.origin.y+rowRect.size.height)];
			while (   col < NSMaxRange(columnRange) )
			{
				int colspan = [self spanForTableColumn:[[self tableColumns] objectAtIndex:col] row:row];
				NSRect gridRect = NSZeroRect;
				if (0 == colspan)
				{
					col++;      // no grid here, move along
				}
				else   // Now gather up the next <colspan> rectangles
				{
					int i, rightEdge, leftEdge;
					for ( i = 0 ; i < colspan ; i++ )
					{
						NSRect thisRect = NSIntersectionRect(
															 [self rectOfColumn:col+i],
															 [self rectOfRow:row]);
						gridRect = NSUnionRect(gridRect,thisRect);
					}
					col += colspan;
					// left edge.  Only draw if this left edge isn't one we just drew.
					leftEdge = (int) 0.5 + gridRect.origin.x;
					if (leftEdge != oldLeftEdge)
					{
						[NSBezierPath strokeLineFromPoint:
							NSMakePoint(
										-0.5+leftEdge, -0.5+gridRect.origin.y)
												  toPoint:
							NSMakePoint(-0.5+leftEdge,
										-0.5+gridRect.origin.y
										+ gridRect.size.height)];
					}
					// right edge
					rightEdge = (int) 0.5 + gridRect.origin.x
						+ gridRect.size.width;
					[NSBezierPath strokeLineFromPoint:
						NSMakePoint(-0.5+rightEdge,
									-0.5+gridRect.origin.y)
											  toPoint:
						NSMakePoint(-0.5+rightEdge,
									-0.5+gridRect.origin.y
									+ gridRect.size.height)];
					oldLeftEdge = rightEdge;   // save edge for next pass through.
				}
			}
		}
	}
}

#pragma mark Row Label Color (accessors)
- (BOOL) shouldShowLabels;
{
	return _shouldShowLabels;
}
- (void) setShouldShowLabels: (BOOL) flag
{
	//if ([[self delegate] respondsToSelector:@selector(labelColorForRow:)])
	{
		_shouldShowLabels = flag;
	}
	
}

#pragma mark Delegation Redirection

- (BOOL) outlineView:(NSOutlineView *)outlineView
			shouldEditTableColumn:(NSTableColumn *)tableColumn
				item:(id)item
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	return [item shouldEditAtColumn:tableColumn];
}


- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	if (item == nil)
		return [[self rootItem] childAtIndex:index];
	
	return [item childAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	if (item == nil) return YES;
		//return [[self rootItem] expandable];
	
	return [item expandable];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	//NSLog(@"%@", [self delegate]);
	if (_inDragOperation) return NO;

	return YES;
}


- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{	
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	if (item == nil)
		return [[self rootItem] numberOfChildren];
	
	return [item numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	if (item == nil)
		return [[self rootItem] objectValueForTableColumn:(NSTableColumn *)tableColumn];
	
	return [item objectValueForTableColumn:(NSTableColumn *)tableColumn];
}

- (void)outlineView:(NSOutlineView *)outlineView 
	 setObjectValue:(id)object 
	 forTableColumn:(NSTableColumn *)tableColumn 
			 byItem:(id)item
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);

	[item setObjectValue:object forTableColumn:tableColumn];
}


- (int)spanForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	id item = [self itemAtRow:row];
	if ([item respondsToSelector:@selector(spanForTableColumn:)])
		return [item spanForTableColumn:tableColumn];
	
	return 1;
}

- (void) tableView:(NSTableView*)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	if ([realDelegate respondsToSelector:@selector(outlineViewSelectionDidChange:)])
		[realDelegate performSelector:@selector(outlineViewSelectionDidChange:) withObject:notification];
}

- (void) textDidEndEditing: (NSNotification *) notification
{
   [super textDidEndEditing: notification];
	
	//NSLog(@"[self selectedRow]: %i", [self selectedRow]);
	int tColumnCount = [[self tableColumns] count];
	int nextColIndex;
	for (nextColIndex = [self editedColumn] + 1;
		(( nextColIndex < tColumnCount ) && ( nextColIndex > -1 ));
		nextColIndex++)
	{
		//NSLog(@"Should edit: %i", nextColIndex);
		if ([[self itemAtRow:[self selectedRow]] shouldEditAtColumn:[[self tableColumns] objectAtIndex:nextColIndex]])
		{		
			[self editColumn:nextColIndex row:[self selectedRow] withEvent:nil select:YES];
			break;
		}
	}
			
	
	
	
} // textDidEndEditing


- (void)keyDown:(NSEvent *)theEvent
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	NSIndexSet* rows = [self selectedRowIndexes];
	
	if ([[theEvent characters] characterAtIndex:0] == NSDeleteCharacter)
	{
		int index = [rows firstIndex];
		
		// collect the items
		NSMutableArray* array = [NSMutableArray new];
		FAFOutlineViewItem* item;
		while (index != NSNotFound)
		{
			item = [self itemAtRow:index];
			[array addObject:item ];
			index = [rows indexGreaterThanIndex:index];
		}
		
		// let the delegate delete model layer objects
		if ([realDelegate respondsToSelector:@selector(deleteItems:)])
		{
			array = [realDelegate deleteItems:array];
		}
		
		// remove the objects from view
		NSEnumerator* e = [array objectEnumerator];
		item = nil;
		while (item = [e nextObject])
		{
			[[item parent] removeChild:item];
		}
		
		// cleanup
		[self reloadData];
		[self selectRow: [rows firstIndex] byExtendingSelection:NO];
	}
	else
		[super keyDown:theEvent];
	
}


#pragma mark Message Forwarding
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [realDelegate methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL aSelector = [invocation selector];
	
    if ([realDelegate respondsToSelector:aSelector])
        [invocation invokeWithTarget:realDelegate];
    else
        [self doesNotRecognizeSelector:aSelector];
}



#pragma mark Drag and Drop (datasource)

- (BOOL)outlineView:(NSOutlineView *)olv writeItems:(NSArray*)items toPasteboard:(NSPasteboard*)pboard
{
	return [realDelegate outlineView:olv writeItems:items toPasteboard:pboard];
}

/* This method is used by NSOutlineView to determine a valid drop target.  Based on the mouse position, the outline view will suggest a proposed drop location.  This method must return a value that indicates which dragging operation the data source will perform.  The data source may "re-target" a drop if desired by calling setDropItem:dropChildIndex: and returning something other than NSDragOperationNone.  One may choose to re-target for various reasons (eg. for better visual feedback when inserting into a sorted position).
*/
- (NSDragOperation)outlineView:(NSOutlineView*)olv validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)index
{
	return [realDelegate outlineView:olv validateDrop:info proposedItem:item proposedChildIndex:index];
}

	/* This method is called when the mouse is released over an outline view that previously decided to allow a drop via the validateDrop method.  The data source should incorporate the data from the dragging pasteboard at this time.
	*/
- (BOOL)outlineView:(NSOutlineView*)olv acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index
{
	return [realDelegate outlineView:olv acceptDrop:info item:item childIndex:index];
}

- (void) concludeDragOperation: (id <NSDraggingInfo>)sender
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	_inDragOperation = NO;
	[super concludeDragOperation:sender];
}

- (NSDragOperation) draggingEntered:(id <NSDraggingInfo>)sender
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	_inDragOperation = YES;
	return [super draggingEntered:sender];
}

- (void) draggingEnded: (id <NSDraggingInfo>)sender
{
	_inDragOperation = NO;
	
	
	// Usage under Tiger, NSOutlineView never complained, but under Leopard, crash.
	//[super draggingEnded:sender];
}


#pragma mark Drag and Drop (highlighting)

#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
- (void) _drawDropHighlightOnRow: (int) row
{
	[self lockFocus];
	
	{	
		NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:[self rectOfRow:row]];
		//NSBezierPath* path = [NSBezierPath bezierPathWithRect:[self rectOfRow:row]];
		[[NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:0.5] set];
		[path fill];
		
	}
	
	[self unlockFocus];
	
}
#endif



@end
