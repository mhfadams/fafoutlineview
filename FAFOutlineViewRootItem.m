//
//  FAFOutlineViewRootItem.m
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

#import "FAFOutlineViewRootItem.h"


@implementation FAFOutlineViewRootItem


- (id) initWithItem: (id) item inOutlineView:(FAFOutlineView*) ov
{
	self = [super initWithItem:item inOutlineView:ov];
	if (self != nil)
	{
		//NSLog(@"%s", __PRETTY_FUNCTION__);
	}
	return self;
}





- (BOOL) expandable
{	
	return YES;
}


- (unsigned) numberOfChildren
{

	//if ( ! children )
	{
		unsigned capacity;
		
		/*** case 1 : root is NSArray ***/
		/* each entry in the array becomes a row in the table view */
		if ([representedObject isKindOfClass:[NSArray class]])
		{
			capacity = [representedObject count];
			if ( ! children )
			{	
				//NSLog(@"FAFOutlineViewRootItem: will build children with class %@", NSStringFromClass([outlineView OutlineViewItemClass]) );
				//[children release];
				children = [[NSMutableArray alloc] initWithCapacity:capacity];
				unsigned i;
				for (i = 0; i < capacity; i++)
				{
					FAFOutlineViewItem* item = [[[outlineView OutlineViewItemClass] alloc]
												initWithItem:[representedObject objectAtIndex:i]
												inOutlineView:outlineView
					];
					[item setParent:self];
					//NSLog(@"item: %@", item);
					[children addObject:item];
					[item release];
					if ([[representedObject objectAtIndex:i] isKindOfClass:[NSString class]]) _shouldSort = NO;
				}
				
				if ( ! _sortDescriptors && _shouldSort)
				{
					NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:
												  [[[outlineView tableColumns] objectAtIndex:0] identifier] ascending:YES];
					[self setSortDescriptors:[NSArray arrayWithObject:sortDesc] ];
				}
				
			}
		}
		
		
		/*** case 2 : root is NSDictionary ***/
		/* key/value pair becomes a row in the table view */
		else if ([representedObject isKindOfClass:[NSDictionary class]])
		{
			capacity = [[representedObject allKeys] count];
			if ( ! children )
			{	
				//[children release];
				children = [[NSMutableArray alloc] initWithCapacity:capacity];
				
				NSEnumerator* e = [[representedObject allKeys] objectEnumerator];
				NSString* key;
				while (key = [e nextObject])
				{
					NSDictionary* rowEntry = [NSDictionary dictionaryWithObjectsAndKeys:
						key,									@"key",
						[representedObject valueForKey:key],	@"value", nil];
					
					FAFOutlineViewItem* item = [[FAFOutlineViewItem alloc] 
												initWithItem: rowEntry
												inOutlineView:outlineView
					];
					[item setParent:self];
					[children addObject:item];
					[item release];
				}
			}
			
		}
		
		if (children && _sortDescriptors && _shouldSort)
		{
			[children sortUsingDescriptors:_sortDescriptors];
		}

	
	}
	
	unsigned cnt = [children count];
	
	//NSLog(@"%s %@ (%u)", __PRETTY_FUNCTION__, self, cnt);
		
		
	return cnt;
	
}





@end
