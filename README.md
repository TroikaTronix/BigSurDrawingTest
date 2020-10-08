# BigSurDrawingTest
Test Big Sur Drawing Inconsistencies
 
This file demonstrates a serious bug in the Big Sur Beta 9.

On previous versions of macOS, when you invalidated an area using setNeedsDisplayInRect:, calling the `getRectsBeingDrawn:count:` method in the drawRect: method for a view would correctly return the invalidated area.

Under Big Sur Beta 9, calling `getRectsBeingDrawn:count:` to determine the invalid area always returns the entire frame of the view. This is bad because routines that rely on `getRectsBeingDrawn:count:` to optimize drawing are getting the wrong information, and will draw more than they need to draw.

But even more serious is this: even `getRectsBeingDrawn:count:` reports the entire frame as being invalid, you cannot successfully to draw into the area that has not been invalidated.

To see this more serious problem in action, run the BigSurDrawingTest under Big Sur, and choose "Invalidate Inner View 2 Partial Rect" from the "Action" menu.

This executes the xxx function, which executes the following code to invalidate a rect that is 100 pixels across by 10 pixels high at the coordinate 10,10.

    sDrawView2AltColor = true;
    [view2 setNeedsDisplayInRect:NSMakeRect(10, 10, 100, 10)];

Note also that the sDrawView2AltColor flag is set here.

When the drawing function for the custom view is called, it does the following test to see if the sDrawView2AltColor flag is set and if we are drawing view_2:

    sDrawView2AltColor && [[self identifier] isEqualToString:@"view_2"]

if that test is true, the drawing color is set to yellow instead of green.

If you put a breakpoint at the following line of code under Big Sur, you will see that the single invalid rectangle as reported by `getRectsBeingDrawn:count:` has an origin of 0,0 and dimensions of 360x240. And yet, when calling

    [[NSColor yellowColor] set];
    [NSBezierPath fillRect:rect];

only the **invalid** area is drawn, **nNOT* the entire frame as the result of `getRectsBeingDrawn:count:` would indicate.

-------

# DEBUG OUTPUT FOR BIG SUR, CATALINA AND MOJAVE


## MACOS BIG SUR - BETA 9 (20A5384c)

### Initial Update of Main Window

	2020-10-08 08:47:00.369389+0200 BigSurDrawingTest[643:7190] main_view - returning isOpauqe YES
	2020-10-08 08:47:00.369522+0200 BigSurDrawingTest[643:7190] view_1 - returning isOpauqe YES
	2020-10-08 08:47:00.369592+0200 BigSurDrawingTest[643:7190] Drawing main_view - Rects = 1
	2020-10-08 08:47:00.369669+0200 BigSurDrawingTest[643:7190] -- 0, 0 (440 x 320)
	2020-10-08 08:47:00.370262+0200 BigSurDrawingTest[643:7190] view_2 - returning isOpauqe YES
	2020-10-08 08:47:00.370373+0200 BigSurDrawingTest[643:7190] Drawing view_1 - Rects = 1
	2020-10-08 08:47:00.370404+0200 BigSurDrawingTest[643:7190] -- 0, 0 (400 x 280)
	2020-10-08 08:47:00.370472+0200 BigSurDrawingTest[643:7190] Drawing view_2 - Rects = 1
	2020-10-08 08:47:00.370497+0200 BigSurDrawingTest[643:7190] -- 0, 0 (360 x 240)

### Choosing **Invalidate Inner View 2 Partial Rect**

	2020-10-08 08:47:07.048266+0200 BigSurDrawingTest[643:7190] ******* Inner View 2: Set Needs Display in Rect (10,10 --  100x10)
	2020-10-08 08:47:07.049914+0200 BigSurDrawingTest[643:7190] main_view - returning isOpauqe YES
	2020-10-08 08:47:07.050185+0200 BigSurDrawingTest[643:7190] view_1 - returning isOpauqe YES
	2020-10-08 08:47:07.050275+0200 BigSurDrawingTest[643:7190] Drawing main_view - Rects = 1
	2020-10-08 08:47:07.050314+0200 BigSurDrawingTest[643:7190] -- 0, 0 (440 x 320)
	2020-10-08 08:47:07.050454+0200 BigSurDrawingTest[643:7190] view_2 - returning isOpauqe YES
	2020-10-08 08:47:07.050520+0200 BigSurDrawingTest[643:7190] Drawing view_1 - Rects = 1
	2020-10-08 08:47:07.050559+0200 BigSurDrawingTest[643:7190] -- 0, 0 (400 x 280)
	2020-10-08 08:47:07.050634+0200 BigSurDrawingTest[643:7190] Drawing view_2 - Rects = 1
	2020-10-08 08:47:07.050676+0200 BigSurDrawingTest[643:7190] -- 0, 0 (360 x 240)

### Choosing **Invalidate Inner View 1 Partial Rect**

	2020-10-08 08:47:14.426326+0200 BigSurDrawingTest[643:7190] ******* Inner View 1: Set Needs Display in Rect (40,40 --  100x10)
	2020-10-08 08:47:14.427634+0200 BigSurDrawingTest[643:7190] main_view - returning isOpauqe YES
	2020-10-08 08:47:14.427795+0200 BigSurDrawingTest[643:7190] view_1 - returning isOpauqe YES
	2020-10-08 08:47:14.427881+0200 BigSurDrawingTest[643:7190] Drawing main_view - Rects = 1
	2020-10-08 08:47:14.427922+0200 BigSurDrawingTest[643:7190] -- 0, 0 (440 x 320)
	2020-10-08 08:47:14.427994+0200 BigSurDrawingTest[643:7190] view_2 - returning isOpauqe YES
	2020-10-08 08:47:14.428043+0200 BigSurDrawingTest[643:7190] Drawing view_1 - Rects = 1
	2020-10-08 08:47:14.428075+0200 BigSurDrawingTest[643:7190] -- 0, 0 (400 x 280)
	2020-10-08 08:47:14.428130+0200 BigSurDrawingTest[643:7190] Drawing view_2 - Rects = 1
	2020-10-08 08:47:14.428165+0200 BigSurDrawingTest[643:7190] -- 0, 0 (360 x 240)

## MACOS CATALINA - 10.15.7

### Initial Update of Main Window

	2020-10-08 08:51:54.298842+0200 BigSurDrawingTest[685:7743] Metal API Validation Enabled
	2020-10-08 08:51:54.651514+0200 BigSurDrawingTest[685:7743] main_view - returning isOpauqe YES
	2020-10-08 08:51:54.651641+0200 BigSurDrawingTest[685:7743] view_1 - returning isOpauqe YES
	2020-10-08 08:51:54.651690+0200 BigSurDrawingTest[685:7743] Drawing main_view - Rects = 1
	2020-10-08 08:51:54.651716+0200 BigSurDrawingTest[685:7743] -- 0, 0 (440 x 320)
	2020-10-08 08:51:54.653408+0200 BigSurDrawingTest[685:7743] view_2 - returning isOpauqe YES
	2020-10-08 08:51:54.653476+0200 BigSurDrawingTest[685:7743] Drawing view_1 - Rects = 1
	2020-10-08 08:51:54.653502+0200 BigSurDrawingTest[685:7743] -- 0, 0 (400 x 280)
	2020-10-08 08:51:54.653806+0200 BigSurDrawingTest[685:7743] Drawing view_2 - Rects = 1
	2020-10-08 08:51:54.653836+0200 BigSurDrawingTest[685:7743] -- 0, 0 (360 x 240)

### Choosing **Invalidate Inner View 2 Partial Rect**

	2020-10-08 08:52:01.621290+0200 BigSurDrawingTest[685:7743] ******* Inner View 2: Set Needs Display in Rect (10,10 --  100x10)
	2020-10-08 08:52:01.622452+0200 BigSurDrawingTest[685:7743] main_view - returning isOpauqe YES
	2020-10-08 08:52:01.625247+0200 BigSurDrawingTest[685:7743] view_1 - returning isOpauqe YES
	2020-10-08 08:52:01.625324+0200 BigSurDrawingTest[685:7743] Drawing main_view - Rects = 1
	2020-10-08 08:52:01.625356+0200 BigSurDrawingTest[685:7743] -- 50, 50 (100 x 10)
	2020-10-08 08:52:01.625436+0200 BigSurDrawingTest[685:7743] view_2 - returning isOpauqe YES
	2020-10-08 08:52:01.625476+0200 BigSurDrawingTest[685:7743] Drawing view_1 - Rects = 1
	2020-10-08 08:52:01.625500+0200 BigSurDrawingTest[685:7743] -- 30, 30 (100 x 10)
	2020-10-08 08:52:01.625541+0200 BigSurDrawingTest[685:7743] Drawing view_2 - Rects = 1
	2020-10-08 08:52:01.625567+0200 BigSurDrawingTest[685:7743] -- 10, 10 (100 x 10)

### Choosing **Invalidate Inner View 1 Partial Rect**

	2020-10-08 08:52:03.021304+0200 BigSurDrawingTest[685:7743] ******* Inner View 1: Set Needs Display in Rect (40,40 --  100x10)
	2020-10-08 08:52:03.022227+0200 BigSurDrawingTest[685:7743] main_view - returning isOpauqe YES
	2020-10-08 08:52:03.022454+0200 BigSurDrawingTest[685:7743] view_1 - returning isOpauqe YES
	2020-10-08 08:52:03.022524+0200 BigSurDrawingTest[685:7743] Drawing main_view - Rects = 1
	2020-10-08 08:52:03.022561+0200 BigSurDrawingTest[685:7743] -- 60, 60 (100 x 10)
	2020-10-08 08:52:03.022633+0200 BigSurDrawingTest[685:7743] view_2 - returning isOpauqe YES
	2020-10-08 08:52:03.022676+0200 BigSurDrawingTest[685:7743] Drawing view_1 - Rects = 1
	2020-10-08 08:52:03.022707+0200 BigSurDrawingTest[685:7743] -- 40, 40 (100 x 10)
	2020-10-08 08:52:03.022754+0200 BigSurDrawingTest[685:7743] Drawing view_2 - Rects = 1
	2020-10-08 08:52:03.022786+0200 BigSurDrawingTest[685:7743] -- 20, 20 (100 x 10)

## MACOS MOJAVE - 10.14.6

### Initial Update of Main Window

	2020-10-08 08:42:39.107269+0200 BigSurDrawingTest[668:13944] Metal API Validation Enabled
	2020-10-08 08:42:39.167637+0200 BigSurDrawingTest[668:13944] main_view - returning isOpauqe YES
	2020-10-08 08:42:39.167779+0200 BigSurDrawingTest[668:13944] main_view - returning isOpauqe YES
	2020-10-08 08:42:39.167822+0200 BigSurDrawingTest[668:13944] main_view - returning isOpauqe YES
	2020-10-08 08:42:39.167855+0200 BigSurDrawingTest[668:13944] view_1 - returning isOpauqe YES
	2020-10-08 08:42:39.167894+0200 BigSurDrawingTest[668:13944] Drawing main_view - Rects = 1
	2020-10-08 08:42:39.167918+0200 BigSurDrawingTest[668:13944] -- 0, 0 (440 x 320)
	2020-10-08 08:42:39.169764+0200 BigSurDrawingTest[668:13944] view_1 - returning isOpauqe YES
	2020-10-08 08:42:39.169809+0200 BigSurDrawingTest[668:13944] view_2 - returning isOpauqe YES
	2020-10-08 08:42:39.169840+0200 BigSurDrawingTest[668:13944] Drawing view_1 - Rects = 1
	2020-10-08 08:42:39.169863+0200 BigSurDrawingTest[668:13944] -- 0, 0 (400 x 280)
	2020-10-08 08:42:39.170175+0200 BigSurDrawingTest[668:13944] view_2 - returning isOpauqe YES
	2020-10-08 08:42:39.170211+0200 BigSurDrawingTest[668:13944] Drawing view_2 - Rects = 1
	2020-10-08 08:42:39.170233+0200 BigSurDrawingTest[668:13944] -- 0, 0 (360 x 240)

### Choosing **Invalidate Inner View 2 Partial Rect**

	2020-10-08 08:42:52.946381+0200 BigSurDrawingTest[668:13944] ******* Inner View 2: Set Needs Display in Rect (10,10 --  100x10)
	2020-10-08 08:42:52.946878+0200 BigSurDrawingTest[668:13944] main_view - returning isOpauqe YES
	2020-10-08 08:42:52.949203+0200 BigSurDrawingTest[668:13944] main_view - returning isOpauqe YES
	2020-10-08 08:42:52.949277+0200 BigSurDrawingTest[668:13944] main_view - returning isOpauqe YES
	2020-10-08 08:42:52.949317+0200 BigSurDrawingTest[668:13944] view_1 - returning isOpauqe YES
	2020-10-08 08:42:52.949352+0200 BigSurDrawingTest[668:13944] Drawing main_view - Rects = 1
	2020-10-08 08:42:52.949376+0200 BigSurDrawingTest[668:13944] -- 50, 50 (100 x 10)
	2020-10-08 08:42:52.949490+0200 BigSurDrawingTest[668:13944] view_1 - returning isOpauqe YES
	2020-10-08 08:42:52.949522+0200 BigSurDrawingTest[668:13944] view_2 - returning isOpauqe YES
	2020-10-08 08:42:52.949549+0200 BigSurDrawingTest[668:13944] Drawing view_1 - Rects = 1
	2020-10-08 08:42:52.949574+0200 BigSurDrawingTest[668:13944] -- 30, 30 (100 x 10)
	2020-10-08 08:42:52.949620+0200 BigSurDrawingTest[668:13944] view_2 - returning isOpauqe YES
	2020-10-08 08:42:52.949649+0200 BigSurDrawingTest[668:13944] Drawing view_2 - Rects = 1
	2020-10-08 08:42:52.949671+0200 BigSurDrawingTest[668:13944] -- 10, 10 (100 x 10)

### Choosing **Invalidate Inner View 1 Partial Rect**

	2020-10-08 08:43:05.043092+0200 BigSurDrawingTest[668:13944] ******* Inner View 1: Set Needs Display in Rect (40,40 --  100x10)
	2020-10-08 08:43:05.044265+0200 BigSurDrawingTest[668:13944] main_view - returning isOpauqe YES
	2020-10-08 08:43:05.046604+0200 BigSurDrawingTest[668:13944] main_view - returning isOpauqe YES
	2020-10-08 08:43:05.046690+0200 BigSurDrawingTest[668:13944] main_view - returning isOpauqe YES
	2020-10-08 08:43:05.046742+0200 BigSurDrawingTest[668:13944] view_1 - returning isOpauqe YES
	2020-10-08 08:43:05.046786+0200 BigSurDrawingTest[668:13944] Drawing main_view - Rects = 1
	2020-10-08 08:43:05.046821+0200 BigSurDrawingTest[668:13944] -- 60, 60 (100 x 10)
	2020-10-08 08:43:05.046922+0200 BigSurDrawingTest[668:13944] view_1 - returning isOpauqe YES
	2020-10-08 08:43:05.046967+0200 BigSurDrawingTest[668:13944] view_2 - returning isOpauqe YES
	2020-10-08 08:43:05.047006+0200 BigSurDrawingTest[668:13944] Drawing view_1 - Rects = 1
	2020-10-08 08:43:05.047040+0200 BigSurDrawingTest[668:13944] -- 40, 40 (100 x 10)
	2020-10-08 08:43:05.047106+0200 BigSurDrawingTest[668:13944] view_2 - returning isOpauqe YES
	2020-10-08 08:43:05.047148+0200 BigSurDrawingTest[668:13944] Drawing view_2 - Rects = 1
	2020-10-08 08:43:05.047182+0200 BigSurDrawingTest[668:13944] -- 20, 20 (100 x 10)




