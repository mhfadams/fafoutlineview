//
//  FAFOutlineViewProtocols.h
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

@class	FAFOutlineView,
		FAFOutlineViewItem;

@protocol FAFOutlineViewDelegate <NSObject>



@end


@protocol FAFOutlineViewRepresentedObject <NSObject>

/*
- (BOOL) expandable;
- (BOOL) editable;
- (NSString*) labelColor;
- (unsigned) numberOfChildren;
- (id) childAtIndex:(unsigned)index;
*/

@end

@interface NSObject (FAFOutlineViewRepresentedObject)

- (BOOL) expandable;
- (BOOL) editable;
- (NSString*) labelColor;
- (unsigned) numberOfChildren;
- (id) childAtIndex:(unsigned)index;

@end
