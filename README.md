FAFOutlineView
==============


Introduction
------------
In the course of my programming activities, I have found that I tend to use outline views quite frequently, and am often having to deal with the same issues each time:
- NSOutlineView auto-expands items on receiving drags, and this is often undesirable, not to mention having too short a timing delay.
- NSOutlineView is missing (at least under Tiger) Finder-style 'long-click' renaming.
- NSOutlineViews don't support representing the same model object in more than one place in the same outline view.

FAFOutlineView addresses these deficiencies, as well as adding a couple bonus points:
- label colored rows,
- column-spanning row cells,
- a better controller model.

FAFOutlineView is used for both table views and outline views.

FAFOutlineView uses a very different data source and delegate methodology than NSOutlineView, so I highly recommend using FAFOutlineView only on new projects, until you are familiar with how it works. Trying to replace NSOutlineView with FAFOutlineView on existing projects is error prone.


Status
------
This project is early beta.
The structure is stable but the API might be adjusted, and there are no doubt unexplored bugs.
I use it frequently, however, so it does get good end-use testing.


DataSource and Delegation Methodology
---------------------------------------------
FAFOutlineView decentralizes the NSOutlineView datasourcing. There is a controller object paired up with each model object. A default controller object (FAFOutlineViewItem) is provided for use with NSString, NSArray, and NSDictionary model objects, but can be subclassed for custom model objects.
The delegate provides a root item and that root item (controller object) and its children then on act as the data source for their represented object.


Basic Setup
----------------------------------------------
- Create your usual NSOutlineView in your nib as usual;
- implement [code]- (FAFOutlineViewItem*) rootItem;[/code] in your outline view delegate returning 








Licensing
---------
This project is licensed under the LGPL.
However, some segments of the code borrowed from others may be obtainable from the original authors under less restrictive licensing:
- NDSDKCompatibility.h <https://github.com/nathanday/ndalias>
- (FAF)NSBezierPathAdditions <https://github.com/fishman/mail.appetizer>
- techniques for column spanning rows <http://www.mactech.com/articles/mactech/Vol.18/18.11/1811TableTechniques/index.html>
