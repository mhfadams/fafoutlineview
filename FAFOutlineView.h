
//	FAFOutlineView.h
/*
 FAFOutlineView
 Copyright (c) 2014, Manoah F. Adams, All rights reserved.
 federaladamsfamily.com/developer
 developer@federaladamsfamily.com
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, 
 this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, 
 this list of conditions and the following disclaimer in the documentation and/or 
 other materials provided with the distribution.
 
 3. Neither the name of the copyright holder nor the names of its contributors may 
 be used to endorse or promote products derived from this software without specific 
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE.
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
	FAFOutlineViewRootItem*		rItem; // temp for internal use
	
	Class		OutlineViewItemClass; // used by outlineview items for creating children.
	
	int							inited; // internal use only by -[FAFOutlineView rootItemWithObject:]
	
	NSCellStateValue			delegateHandlesToolTips;

}

// following two methods are for childrens use, not our own.
- (Class)OutlineViewItemClass;
- (void)setOutlineViewItemClass:(Class)value;

- (FAFOutlineViewItem*) rootItem;
- (void) setRootItem:(FAFOutlineViewItem*)item;

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
