//
//  FAFOutlineViewItem.m
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

#import "FAFOutlineViewItem.h"


@implementation FAFOutlineViewItem

- (id) initWithItem: (id) item
{
	self = [super init];
	if (self != nil)
	{
		representedObject = [item retain];
		children = nil;
		_shouldSort = YES;
		_columnSpanCount = 1;
	}
	return self;
}

- (void) dealloc {
	[children release];
	[representedObject release];
	[_sortDescriptors release];
	[super dealloc];
}

- (FAFOutlineView*) outlineView
{
	return outlineView;
}
- (void) setOutlineView: (FAFOutlineView*) ov
{
	outlineView = ov;
}

- (NSArray*) sortDescriptors
{
	return _sortDescriptors;
}

- (void) setSortDescriptors: (NSArray*) array
{
	_sortDescriptors = [array retain];
	if (nil == array) _shouldSort = NO;
}

- (int)columnSpanCount
{
    return _columnSpanCount;
}

- (void)setColumnSpanCount:(int)value
{
	_columnSpanCount = value;
}



- (FAFOutlineViewItem*) parent
{
	return _parent;
}
- (void) setParent: (FAFOutlineViewItem*) item
{
	_parent = item;
}


- (id) representedObject
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	return representedObject;
}

- (void) reload
{
	//NSLog(@"%s for item: %@", __PRETTY_FUNCTION__, representedObject);
	/*
	 
	 Here we may be faced with any of the following senarios:
	 
	 for a represented object that is an item...
	 (1) One or more of the attributes of the represented object have changed.
	 -> in this case reload need do nothing since the attributes are lazily fetched.
	 
	 for a represented object that is a collection...
	 (1) one or more children of the represented object may have been added.
	 -> in this case we should have been told, but will remake all children.
	 (2) one or more children of the represented object may have been removed.
	 -> in this case we should have been told, but will remake all children.
	 (3) one or more children of the represented object may have been changed.
	 -> in this case telling each child to reload will suffice.
 
	 */

	//[self numberOfChildren];
	return;
/*
	if ([self expandable])
	{
		NSUInteger numberOfChildren;
		if ( [representedObject respondsToSelector:@selector(count)] ) // e.g. custom object
			numberOfChildren = [representedObject count];
		else if ( [representedObject respondsToSelector:@selector(numberOfChildren)] ) // collection
			numberOfChildren = [representedObject numberOfChildren];
		
		if ([children count] != numberOfChildren)
		{
			[children release]; children = nil;
			[self numberOfChildren]; // force remake of children.
		}
		else
			[children makeObjectsPerformSelector:@selector(reload)];

	}
*/
}

- (BOOL) expandable
{
	if ( [representedObject respondsToSelector:@selector(expandable)] ) // e.g. custom object
		return [representedObject expandable];
	else if ( [representedObject isKindOfClass:[NSArray class]]) // collection
		return YES;
	
	return NO;
}


- (unsigned) numberOfChildren
{
	
	//if ( ! children )
	{
		unsigned capacity;
		
		/*** case 1 : item is NSArray ***/
		/* each entry in the array becomes child */
		if ([representedObject isKindOfClass:[NSArray class]])
		{
			capacity = [representedObject count];
			if ( ! children || [children count] == 0 )
			{
				[children release];
				children = [[NSMutableArray alloc] initWithCapacity:capacity];
				unsigned i;
				for (i = 0; i < capacity; i++)
				{
					FAFOutlineViewItem* item = [[[self class] alloc] initWithItem: 
						[representedObject objectAtIndex:i]];
					[item setParent:self];
					[item setOutlineView:outlineView];
					[children addObject:item];
					[item release];
					if ([[representedObject objectAtIndex:i] isKindOfClass:[NSString class]]) _shouldSort = NO;
				}
				
			}
			
		}
		
		
		/*** case 2 : item is FAFOutlineViewRepresentedObject ***/
		/* each child thereof becomes a child hereof */
		else if ([representedObject respondsToSelector:@selector(numberOfChildren)])
		{
			capacity = [representedObject numberOfChildren];
			if ( ! children || [children count] == 0 )
			{
				[children release];
				children = [[NSMutableArray alloc] initWithCapacity:capacity];
				
				if ([representedObject respondsToSelector:@selector(childAtIndex:)])
				{
					unsigned i;
					for (i = 0; i < capacity; i++)
					{
						FAFOutlineViewItem* item = [[FAFOutlineViewItem alloc] initWithItem: 
							[representedObject childAtIndex:i]];
						[item setParent:self];
						[item setOutlineView:outlineView];
						[children addObject:item];
						[item release];
					}				
				}
			}
		}
		
		/*** case 3 : item is something else (not a container) ***/
		/* no children */
		else
		{
			return 0;
		}
		
		if (_sortDescriptors && _shouldSort)
		{
			[children sortUsingDescriptors:_sortDescriptors];
		}
			
		
	}
	
	
	//NSLog(@"%s (%u)", __PRETTY_FUNCTION__, [children count]);
	
	return [children count];
	
}

- (FAFOutlineViewItem*) childAtIndex:(unsigned)index
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	return [children objectAtIndex:index];
}

- (void) addChild: (FAFOutlineViewItem*) item
{
	//NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
	[item setParent:self];
	[item setOutlineView:outlineView];
	[children addObject:item];
	//NSLog(@"outlineView: %u", [[outlineView rootItem] numberOfChildren]);
	//NSLog(@"%s %@ (%u)", __PRETTY_FUNCTION__, self, [self numberOfChildren]);
	
	if (_parent)
		[outlineView reloadItem:_parent];
	else
		[outlineView reloadData];
}

- (void) removeChild: (FAFOutlineViewItem*) item
{
	[children removeObject:item];
	if (_parent)
		[outlineView reloadItem:_parent];
	else
		[outlineView reloadData];
}

- (id) objectValueForTableColumn:(NSTableColumn *)tableColumn
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	if ( [representedObject isKindOfClass:[NSString class]] ) // NSString
		return representedObject;
	else if ( [representedObject isKindOfClass:[NSArray class]] ) // NSArray
		return [representedObject objectAtIndex: [outlineView columnWithIdentifier:[tableColumn identifier]] ];
	else if ( [representedObject respondsToSelector:@selector(valueForKey:)] ) // NSDictionary or custom object
		return [representedObject valueForKey: [tableColumn identifier] ];
	else if ( [representedObject respondsToSelector:@selector(description)] ) // generic
		return [representedObject description];
	
	return @"---";
}

- (void) setObjectValue: (id) value forTableColumn:(NSTableColumn *)tableColumn
{
	if ( [representedObject respondsToSelector:@selector(setValue:forKey:)] ) // generic
	{
		[representedObject setValue: value forKey: [tableColumn identifier]];
	}
}

- (BOOL) shouldEditAtColumn:(NSTableColumn *)tableColumn
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);

	if ([self spanForTableColumn:tableColumn] == 0)
		return NO;
	
	return NO; //[tableColumn isEditable];
}

- (NSString*) labelColor
{
	if ( [representedObject respondsToSelector:@selector(labelColor)] )
		return [representedObject labelColor];
	
	if ( [representedObject isKindOfClass:[NSDictionary class]] )
		return [representedObject valueForKey:@"labelColor"];
	
	 
	 return @"White";
}

- (int)spanForTableColumn:(NSTableColumn *)tableColumn
{	
	return _columnSpanCount;
}

/*
- (BOOL) isEqual: (id) item
{
	return [representedObject isEqual:item];
}

- (unsigned) hash
{
	return [representedObject hash];
}
*/

/*
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [representedObject methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL aSelector = [invocation selector];
	
    if ([representedObject respondsToSelector:aSelector])
        [invocation invokeWithTarget:representedObject];
    else
        [self doesNotRecognizeSelector:aSelector];
}
*/

- (id) valueForUndefinedKey: (NSString*) key
{
	return [representedObject valueForKey:key];
}

- (NSString *)toolTipForColumn:(NSTableColumn *)column
{
	return nil;
}

@end
