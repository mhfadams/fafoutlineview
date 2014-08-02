
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

/*
  All code by above noted author, Except:
 
technique and code for row spanning cells, comes from article at MacTech:
 http://www.mactech.com/articles/mactech/Vol.18/18.11/1811TableTechniques/index.html
 (see that article to find unmodified source for the row-spanning)
 
 */


#import <Cocoa/Cocoa.h>
#import "FAFOutlineViewProtocols.h"

/*!
	FAFOutlineView extends NSOutlineView to provide 5 main features:
	(1) disables auto-expansion of outline during drag operations;
	(2) provides long-double-click renaming (Finder style), without hurting standard action/double-action;
	(3) provides optional label colors for rows. (if delegate implements labelColorForRow: and sends shouldShowLabels:);
	Note: prividing above facilities required internal handling of delegate methods and thus forwarding, which can be tricky.
			If you are having weird problems, try downgrading to NSOutlineView to see if problems persist. If they
			do not persist, then there is an issue to be fixed here, so let me know.
	(4) permits row-spanning cells;
	(5) restructures data-sourcing into more objected oriented style, with separate controller for each row entry.
*/

@class	FAFOutlineViewItem,
		FAFOutlineViewRootItem;

@interface FAFOutlineView : NSOutlineView
{
	
	BOOL						_shouldShowLabels;
	BOOL						_inDragOperation;
	BOOL						_canEditOnNextClick;
	BOOL						_isOpaque;
	int							lastClickedColumn;
	int							lastClickedRow;
	NSTimeInterval				lastClickTime;
	int							lastClickEventNumber;
	id							realDelegate;
	id							realTarget;
	SEL							realAction;
	SEL							realDoubleAction;
	
	FAFOutlineViewItem*			rootItem;
	FAFOutlineViewRootItem*			rItem; // temp for internal use
	
	Class		OutlineViewItemClass; // used by outlineview items for creating children.
	
	int							inited; // internal use only

}

// following two methods are for childrens use, not our own.
- (Class)OutlineViewItemClass;
- (void)setOutlineViewItemClass:(Class)value;

- (FAFOutlineViewItem*) rootItem;

// convenience method...
- (FAFOutlineViewRootItem*) rootItemWithObject:(id) object;

- (BOOL)isOpaque;
- (void)setIsOpaque:(BOOL)value;

/*!
\brief	Set the action to fire on a double click; also sets editing mode.
 
 If you setDoubleAction to NULL, or leave it unset, outline view will trigger cell edit on double-click.
 If set to a selector, selector is called and  outline view will edit cells on long double click
 a-la Finder.
 */
- (void)setDoubleAction:(SEL)aSelector;


/*!
\brief	If shouldShowLabels, then delegate will be asked for ( - (NSString*) labelColorForRow:(int) row ).
 
 Label color must be one of: Red, Orange, Yellow, Green, Blue, Purple, Gray. Any other value will be treated
as white/none.
 */
- (BOOL) shouldShowLabels;
- (void) setShouldShowLabels: (BOOL) flag;




@end
