//
//  FAFOutlineViewItem.h
//  FAFOutlineView
//
//  Created by Manoah F Adams on 2014-04-27.
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

- (id) initWithItem: (id) item;


- (FAFOutlineViewItem*) parent;
- (void) setParent: (FAFOutlineViewItem*) item;

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
- (void) setOutlineView: (FAFOutlineView*) ov;

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









