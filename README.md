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



Status
------
This project is early beta.
The structure is stable but the API might be adjusted, and there are no doubt unexplored bugs.
I use it frequently, however, so it does get good end-use testing.


Licensing
---------
This project is licensed under the LGPL.
However, some segments of the code borrowed from others may be obtainable from the original authors under less restrictive licensing:
- NDSDKCompatibility.h <https://github.com/nathanday/ndalias>
- (FAF)NSBezierPathAdditions <https://github.com/fishman/mail.appetizer>
- techniques for column spanning rows <http://www.mactech.com/articles/mactech/Vol.18/18.11/1811TableTechniques/index.html>
