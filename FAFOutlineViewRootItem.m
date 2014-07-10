//
//  FAFOutlineViewRootItem.m
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

#import "FAFOutlineViewRootItem.h"


@implementation FAFOutlineViewRootItem


- (id) initWithItem: (id) item
{
	self = [super initWithItem:item];
	if (self != nil)
	{
		OutlineViewItemClass = [FAFOutlineViewItem class];
	}
	return self;
}


- (Class)OutlineViewItemClass
{
    return OutlineViewItemClass;
}

- (void)setOutlineViewItemClass:(Class)value
{
	OutlineViewItemClass = value;
}




- (BOOL) expandable
{	
	return YES;
}


- (unsigned) numberOfChildren
{
	if ( ! children )
	{
		unsigned capacity;
		
		/*** case 1 : root is NSArray ***/
		/* each entry in the array becomes a row in the table view */
		if ([representedObject isKindOfClass:[NSArray class]])
		{
			capacity = [representedObject count];
			children = [[NSMutableArray alloc] initWithCapacity:capacity];
			unsigned i;
			for (i = 0; i < capacity; i++)
			{
				FAFOutlineViewItem* item = [[OutlineViewItemClass alloc] initWithItem: 
					[representedObject objectAtIndex:i]];
				[item setParent:self];
				[item setOutlineView:outlineView];
				[children addObject:item];
				[item release];
				if ([[representedObject objectAtIndex:i] isKindOfClass:[NSString class]]) _shouldSort = NO;
			}
			
			if ( ! _sortDescriptors)
			{
				NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:
					[[[outlineView tableColumns] objectAtIndex:0] identifier] ascending:YES];
				[self setSortDescriptors:[NSArray arrayWithObject:sortDesc] ];
			}
			
		}
		
		
		/*** case 2 : root is NSDictionary ***/
		/* key/value pair becomes a row in the table view */
		else if ([representedObject isKindOfClass:[NSDictionary class]])
		{
			capacity = [[representedObject allKeys] count];
			children = [[NSMutableArray alloc] initWithCapacity:capacity];
			
			NSEnumerator* e = [[representedObject allKeys] objectEnumerator];
			NSString* key;
			while (key = [e nextObject])
			{
				NSDictionary* rowEntry = [NSDictionary dictionaryWithObjectsAndKeys:
					key,									@"key",
					[representedObject valueForKey:key],	@"value", nil];
				
				FAFOutlineViewItem* item = [[FAFOutlineViewItem alloc] initWithItem: rowEntry];
				[item setParent:self];
				[item setOutlineView:outlineView];
				[children addObject:item];
				[item release];
			}

			
		}
		
		if (_sortDescriptors && _shouldSort)
		{
			[children sortUsingDescriptors:_sortDescriptors];
			NSTableColumn* sortColumn = [outlineView tableColumnWithIdentifier:[[_sortDescriptors objectAtIndex:0] key]];
			BOOL sortOrder = [[_sortDescriptors objectAtIndex:0] ascending];
			NSString* sortIndicatorName;
			if (sortOrder)
				sortIndicatorName = @"NSAscendingSortIndicator";
			else
				sortIndicatorName = @"NSDescendingSortIndicator";
			
			[outlineView setIndicatorImage:[NSImage imageNamed:sortIndicatorName]
							 inTableColumn:sortColumn];
			
			
		}

	
	}
	
	
	//NSLog(@"%s %@ (%u)", __PRETTY_FUNCTION__, self, [children count]);
		
		
	return [children count];
	
}





@end
