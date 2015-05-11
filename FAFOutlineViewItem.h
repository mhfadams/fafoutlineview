//
//  FAFOutlineViewItem.h
//  Created by Manoah F Adams on 2014-04-27.
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

#import <Cocoa/Cocoa.h>
#import "FAFOutlineView.h"
#import "FAFOutlineViewProtocols.h"


/*!
	FAFOutlineViewItem is a controller layer object that you must subclass to interface between the FAFOutlineView
	and your data object.
	Exception: for a representedObject of an NSArray of strings, you may use without subclassing.
*/

@interface FAFOutlineViewItem : NSObject
{
	FAFOutlineView*				outlineView;
	FAFOutlineViewItem*			_parent;
	
	NSMutableArray*				children;
	NSArray*					_sortDescriptors; // array of NSSortDescriptors
	BOOL						_shouldSort;
		
	id							representedObject;
	int							_columnSpanCount;
}

- (id) initWithItem: (id) item inOutlineView:(FAFOutlineView*) ov;
- (FAFOutlineViewItem *)parent;
- (void)setParent:(FAFOutlineViewItem *)value;


/*!
 \brief	forces item to syncronize with model layer.
 
 For performance reasons, you should use any applicable more specific method.
 */
- (void) reload;

- (BOOL)shouldSort;
- (void)setShouldSort:(BOOL)value;

- (NSArray*) sortDescriptors;

/*!
 \brief	Set the sort descriptors for the item to use. Set to nil to turn off sorting.
 */
- (void) setSortDescriptors: (NSArray*) array;

- (int)columnSpanCount;
- (void)setColumnSpanCount:(int)value;

/*!
\brief You normally can rely on the default implementation of this method.
 */
- (FAFOutlineView*) outlineView;

/*!
\brief You normally can rely on the default implementation of this method.
 */
- (id) representedObject;

/*!
\brief You should override this method if supplying custom representedObject. Do not continue to super.
 
 By default simply returns [representedObject expandable], if available, otherwise appropriate calls for NSArray.
 */
- (BOOL) expandable;

/*!
\brief You Must Either override this method entirely, or rely on default implementation. Do not call to super.
 
 By default, builds children array upon first call. If you override, you must build your own children array or 
equivalent.
 */
- (unsigned) numberOfChildren;

/*!
\brief You Must Either override this method entirely, or rely on default implementation. Do not call to super.
 
 By default, assumes children array and returns specified child.
 */
- (FAFOutlineViewItem*) childAtIndex:(unsigned)index;

/*!

*/
- (void) addChild: (FAFOutlineViewItem*) item;

/*!
\brief	Add a row for a given represented object.
*/
- (void) addObject: (id) someObject;

/*!

*/
- (void) removeChild: (FAFOutlineViewItem*) item;

/*!
\brief You must override this method if supplying custom representedObject. Do not continue to super.
 */
- (id) objectValueForTableColumn:(NSTableColumn *)tableColumn;

/*!
\brief You must override this method if supplying custom representedObject. Do not continue to super.
 
 Default implementation presumes representedObject receives setValue:forKey:.
 */
- (void) setObjectValue: (id) value forTableColumn:(NSTableColumn *)tableColumn;

/*!
\brief Defaults to NO.
 */
- (BOOL) shouldEditAtColumn:(NSTableColumn *)tableColumn;

/*!
\brief Return NO to only allow edit when explicitly clicked on.
		Defaults to YES.
 */
- (BOOL) shouldAutoEditAtColumn:(NSTableColumn *)tableColumn;

/*!
\brief You must override this method if supplying custom representedObject. Do not continue to super.
 
 By default simply returns [representedObject labelColor], if available, otherwise appropriate calls for NSArray.
 */
- (NSString*) labelColor;

/*!
 \brief	The number of columns the row should span, including tableColumn. Defaults to 1;
 */
- (int)spanForTableColumn:(NSTableColumn *)tableColumn;

- (NSString *)toolTipForColumn:(NSTableColumn *)column;

@end









