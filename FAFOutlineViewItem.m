//
//  FAFOutlineViewItem.m
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

#import "FAFOutlineViewItem.h"


@implementation FAFOutlineViewItem

- (id) initWithItem: (id) item inOutlineView:(FAFOutlineView*) ov
{
	self = [super init];
	if (self != nil)
	{
		outlineView = ov;
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

- (BOOL)shouldSort {
    return _shouldSort;
}

- (void)setShouldSort:(BOOL)value {
    if (_shouldSort != value) {
        _shouldSort = value;
    }
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
	
	/* IMPORTANT: do not call [self numberOfChildren] within this method,
		as it will cause decent all the way into any indefinite/infinite datasource.
	 */

	static int assdfsadfsdfdfsdf = 9;
	if ([self expandable] && (assdfsadfsdfdfsdf > 0)) // expansion state
	{
		//[outlineView expandItem:self];
		assdfsadfsdfdfsdf =  assdfsadfsdfdfsdf - 1;
	}
	if ([self expandable] && children)
	{
		
		[children makeObjectsPerformSelector:@selector(reload)];

	}
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
																	[representedObject objectAtIndex:i]
																	inOutlineView:
												outlineView];
					[item setParent:self];
					[children addObject:item];
					[item release];
					//if ([[representedObject objectAtIndex:i] isKindOfClass:[NSString class]]) _shouldSort = NO;
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
							[representedObject childAtIndex:i]
																			  inOutlineView:outlineView];
						[item setParent:self];
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
	//NSLog(@"outlineView: %u", [[outlineView rootItem] numberOfChildren]);
	[item setParent:self];
	[children addObject:item];
	//NSLog(@"outlineView: %u", [[outlineView rootItem] numberOfChildren]);
	//NSLog(@"%s %@ (%u)", __PRETTY_FUNCTION__, self, [self numberOfChildren]);
	
	if (_parent)
		[outlineView reloadItem:_parent];
	else
		[outlineView reloadData];
}

- (void) addObject: (id) someObject
{
	FAFOutlineViewItem* item;
	item = [[[FAFOutlineViewItem alloc] initWithItem:someObject
									   inOutlineView:outlineView] autorelease];
	[item setParent:self];
	[children addObject:item];
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
