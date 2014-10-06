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
The structure is stable but the API will be adjusted, and there are no doubt unexplored bugs.
There are no formal tests, however as I use it in for all my outline and table views, it does get heavy end-use testing.
It is being used and working in both code-created, and nib-loaded forms.
Deployment Target is 10.4.


DataSource and Delegation Methodology
---------------------------------------------
FAFOutlineView decentralizes the NSOutlineView datasourcing. There is a controller object paired up with each model object. A default controller object (FAFOutlineViewItem) is provided for use with NSString, NSArray, and NSDictionary model objects, but can be subclassed for custom model objects.
The delegate must provide a root item and that root item (controller object) and its children then on act as the data source for their represented object.
Drag-and-drop is still handled by the outline view delegate.


Basic Setup
----------------------------------------------
- Create your usual NSOutlineView in your nib or code as usual, substituting FAFOutlineView for NSOutlineView;
- call [code] -\[FAFOutlineView setRootItem:(FAFOutlineViewItem*) rootItem\];[/code] with the root item of your choice.
- call [code] -\[FAFOutlineView setDelegate:(id) object\];[/code] with the delegate of your choice.

Other configuration options can be gleaned from the generated class documentation.





Licensing
---------
This project is licensed under the LGPL.
However, some segments of the code borrowed from others may be obtainable from the original authors under less restrictive licensing:
- NDSDKCompatibility.h <https://github.com/nathanday/ndalias>
- (FAF)NSBezierPathAdditions <https://github.com/fishman/mail.appetizer>
- techniques for column spanning rows <http://www.mactech.com/articles/mactech/Vol.18/18.11/1811TableTechniques/index.html>
