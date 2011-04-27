//
//  HGPageScrollView.h
//  HGPageDeckSample
//
//  Created by Rotem Rubnov on 25/10/2010.
//	Copyright (C) 2010 100 grams software
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "HGPageView.h"

typedef enum{
	HGPageScrollViewModePage,
	HGPageScrollViewModeDeck 
} HGPageScrollViewMode; 


@class HGPageScrollView; 

// ------------------------------------------------------------------------------------------------------------------------------------------------------
// this protocol represents the data source for HGPageScrollerView. 
@protocol HGPageScrollViewDataSource <NSObject>
@required
// Page display. Implementers should *always* try to reuse pageViews by setting each page's reuseIdentifier. 
// This mechanism works the same as in UITableViewCells.  
- (HGPageView *)pageScrollView:(HGPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index;

@optional

- (NSInteger)numberOfPagesInScrollView:(HGPageScrollView *)scrollView;   // Default is 1 if not implemented

// you should re-use the UIView that you return here, only initialize it with appropriate values. 
- (UIView *)pageScrollView:(HGPageScrollView *)scrollView headerViewForPageAtIndex:(NSInteger)index;  

- (NSString *)pageScrollView:(HGPageScrollView *)scrollView titleForPageAtIndex:(NSInteger)index;  
- (NSString *)pageScrollView:(HGPageScrollView *)scrollView subtitleForPageAtIndex:(NSInteger)index;  

@end



// ------------------------------------------------------------------------------------------------------------------------------------------------------
// this represents the display and behaviour of the HGPageScrollView and its subviews.
@protocol HGPageScrollViewDelegate<NSObject, UIScrollViewDelegate>

@optional

// Dragging
- (void) pageScrollViewWillBeginDragging:(HGPageScrollView *)scrollView;
- (void) pageScrollViewDidEndDragging:(HGPageScrollView *)scrollView willDecelerate:(BOOL)decelerate;

// Decelaration
- (void)pageScrollViewWillBeginDecelerating:(HGPageScrollView *)scrollView;
- (void)pageScrollViewDidEndDecelerating:(HGPageScrollView *)scrollView;

// Called before the page scrolls into the center of the view.
- (void)pageScrollView:(HGPageScrollView *)scrollView willScrollToPage:(HGPageView*)page atIndex:(NSInteger)index;

// Called after the page scrolls into the center of the view.
- (void)pageScrollView:(HGPageScrollView *)scrollView didScrollToPage:(HGPageView*)page atIndex:(NSInteger)index;

// Called before the user changes the selection.
- (void)pageScrollView:(HGPageScrollView *)scrollView willSelectPageAtIndex:(NSInteger)index;
- (void)pageScrollView:(HGPageScrollView *)scrollView willDeselectPageAtIndex:(NSInteger)index;

// Called after the user changes the selection.
- (void)pageScrollView:(HGPageScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index;
- (void)pageScrollView:(HGPageScrollView *)scrollView didDeselectPageAtIndex:(NSInteger)index;



@end


// ------------------------------------------------------------------------------------------------------------------------------------------------------

@class HGTouchView; 

@interface HGPageScrollView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate> {

	@private
	
	HGPageScrollViewMode _viewMode;

	IBOutlet id <HGPageScrollViewDelegate>  _delegate;
	IBOutlet id <HGPageScrollViewDataSource>  _dataSource;

	IBOutlet UIView			*_pageHeaderView;
    UIView                  *_userHeaderView; 
	IBOutlet UIView			*_pageDeckBackgroundView;
	
	IBOutlet UILabel		*_pageDeckTitleLabel;
	IBOutlet UILabel		*_pageDeckSubtitleLabel;
	
	IBOutlet UIScrollView	*_scrollView; 
	IBOutlet HGTouchView	*_scrollViewTouch;
	
	IBOutlet UIPageControl	*_pageSelector;
	IBOutlet HGTouchView	*_pageSelectorTouch;
	
	NSInteger				 _numberOfPages;
    NSInteger                _numberOfFreshPages;
	NSRange                  _visibleIndexes;
    NSMutableArray          *_visiblePages;
    NSMutableArray          *_deletedPages;
    NSMutableDictionary     *_reusablePages;
	
	HGPageView				*_selectedPage;
    
    BOOL                    _isPendingScrolledPageUpdateNotification;
}


@property(nonatomic,assign)   id <HGPageScrollViewDataSource> dataSource;
@property(nonatomic,assign)   id <HGPageScrollViewDelegate>   delegate;

// Info 

- (NSInteger) numberOfPages; 
- (HGPageView *)pageAtIndex:(NSInteger)index;            // returns nil if page is not visible or the index is out of range

 
// Selection

- (NSInteger)indexForSelectedPage;   // returns the index of the currently selected page.
- (NSInteger)indexForVisiblePage : (HGPageView*) page;   // returns the index of a page in the visible range

// Selects and deselects rows. These methods will not call the delegate methods (-pageScrollView:willSelectPageAtIndex: or pageScrollView:didSelectPageAtIndex:)
- (void) scrollToPageAtIndex  : (NSInteger) index animated : (BOOL) animated; 
- (void) selectPageAtIndex    : (NSInteger) index animated : (BOOL) animated;
- (void) deselectPageAnimated : (BOOL) animated;


// Appearance

@property(nonatomic,readwrite, retain) UIView *pageHeaderView;				// Shown above page view in HGPageScrollViewModePage (when a single page is selected). Hidden in HGPageScrollViewModeDeck. Default is an empty view (white/opaque background) with title/subtitle labels.
@property(nonatomic,readwrite, retain) UIView *pageDeckBackgroundView;     // Background of the page deck (HGPageScrollViewModeDeck). Hidden in HGPageScrollViewModePage. Default takes a greyscale gradient.

@property (nonatomic, readonly)	HGPageScrollViewMode viewMode;

- (HGPageView *)dequeueReusablePageWithIdentifier:(NSString *)identifier;  // Used by the delegate to acquire an already allocated page, instead of allocating a new one

// Data
- (void) reloadData; 



// Page insertion/deletion/reloading.

// insert on or more pages into the page scroller. 
// This method invokes HGPageScrollViewDataSource method numberOfPagesInScrollView:. Specifically, it expects the new number of pages to be equal to the previous number of pages plus the number of inserted pages. If this is not the case an exception is thrown. 
// Insertions are animated only if animated is set to YES and the insertion is into the visible page range.  
- (void)insertPagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated;

// delete one or more pages from the page scroller. 
// This method invokes HGPageScrollViewDataSource method numberOfPagesInScrollView:. Specifically, it expects the new number of pages to be equal to the previous number of pages minus the number of deleted pages. If this is not the case an exception is thrown.  
// Deletions are animated only if animated is set to YES and the deletion is from the visible page range.  
- (void)deletePagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated; 

- (void)reloadPagesAtIndexes:(NSIndexSet *)indexes;



@end
