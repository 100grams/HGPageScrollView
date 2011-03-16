//
//  HGPageScrollView.m
//  HGPageDeckSample
//
//  Created by Rotem Rubnov on 25/10/2010.
//  Copyright (C) 2010 100 grams software. All rights reserved.
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


#import "HGPageScrollView.h"
#import <QuartzCore/QuartzCore.h>



// ------------------------------------------------------------------------------------------------------------------------------------------------------
//Internal view class, used by to HGPageScrollView.   
@interface HGTouchView : UIView {
}
@property (nonatomic, retain) UIView *receiver;
@end



@implementation HGTouchView

@synthesize receiver;

- (void)dealloc {
	self.receiver = nil;
    [super dealloc];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if ([self pointInside:point withEvent:event]) {
		return self.receiver;
        NSLog(@"touched %@ receiver %@", self, [self receiver]);
	}
	return nil;
}

@end



// ------------------------------------------------------------------------------------------------------------------------------------------------------
@interface HGPageScrollView(private)

// initializing/updating controls
- (void) initHeaderForPageAtIndex : (NSInteger) index;
- (void) initDeckTitlesForPageAtIndex : (NSInteger) index;

// managing pages
- (void) loadPageAtIndex : (NSInteger) index insertIntoVisibleIndex : (NSInteger) visibleIndex;
- (void) insertPageInScrollView : (HGPageView *) page atIndex : (NSInteger) index;
- (void) updateScrolledPage : (HGPageView*) page index : (NSInteger) index;

// managing selection and scrolling
- (void) updateVisiblePages;
- (void) setAlphaForPage : (HGPageView*) page;
- (void) preparePage : (HGPageView *) page forMode : (HGPageScrollViewMode) mode; 
- (void) setViewMode:(HGPageScrollViewMode)mode animated:(BOOL)animated; //toggles selection/deselection

// responding to actions 
- (void) didChangePageValue : (id) sender;

@end



@implementation HGPageScrollView


@synthesize pageHeaderView			= _pageHeaderView; 
@synthesize pageDeckBackgroundView	= _pageDeckBackgroundView;
@synthesize dataSource				= _dataSource;
@synthesize delegate				= _delegate;
@synthesize viewMode				= _viewMode;

- (void) awakeFromNib{ 

	[super awakeFromNib];
	
	// init internal data structures
	_visiblePages = [[NSMutableArray alloc] initWithCapacity:3];
	_reusablePages = [[NSMutableDictionary alloc] initWithCapacity:3]; 
	
	// set gradient for background view
	CAGradientLayer *glayer = [CAGradientLayer layer];
	glayer.frame = _pageDeckBackgroundView.bounds;
	UIColor *topColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]; //light blue-gray
	UIColor *bottomColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]; //dark blue-gray
	glayer.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
	[_pageDeckBackgroundView.layer insertSublayer:glayer atIndex:0];
	
	// set tap gesture recognizer for page selection
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureFrom:)];
	[_scrollView addGestureRecognizer:recognizer];
	recognizer.delegate = self;
	[recognizer release];
	
	// setup scrollView
	_scrollView.decelerationRate = 1.0;//UIScrollViewDecelerationRateNormal;
    _scrollView.delaysContentTouches = NO;
    _scrollView.clipsToBounds = NO;	
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
	_pageSelectorTouch.receiver = _pageSelector;
	_scrollViewTouch.receiver = _scrollView;
	
	// setup pageSelector
	[_pageSelector addTarget:self action:@selector(didChangePageValue:) forControlEvents:UIControlEventValueChanged];
	
	// default number of pages 
	_numberOfPages = 0;
	
	// set initial visible indexes (page 0)
	_visibleIndexes.location = 0;
	_visibleIndexes.length = 1;
	
	// load the data 
	//[self reloadData];

	// set initial selected page
	//_selectedPage = [_visiblePages objectAtIndex:0];
	
	// set initial alpha values for all visible pages
//	[_visiblePages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		[self setAlphaForPage : obj];		
//	}];
	
	// update deck title and subtitle for selected page
//	NSInteger index = [self indexForSelectedPage];
//	if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
//		_pageDeckTitleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
//	}
//	if ([self.dataSource respondsToSelector:@selector(pageScrollView:subtitleForPageAtIndex:)]) {
//		_pageDeckSubtitleLabel.text = [self.dataSource pageScrollView:self subtitleForPageAtIndex:index];
//	}		
	

}


- (void)dealloc 
{
	[_visiblePages release];
	_visiblePages = nil;
	[_reusablePages release];
	_reusablePages = nil;
    [super dealloc];
}



#pragma mark -
#pragma mark Info


- (NSInteger) numberOfPages; 
{
	return _numberOfPages;
}


- (HGPageView *)pageAtIndex:(NSInteger)index;            // returns nil if page is not visible or the index is out of range
{
	if (index < _visibleIndexes.location || index > _visibleIndexes.location + _visibleIndexes.length-1) {
		return nil;
	}
	return [_visiblePages objectAtIndex:index-_visibleIndexes.location];
}



#pragma mark -
#pragma mark Page Selection


- (NSInteger)indexForSelectedPage;   
{
	NSInteger index = [_visiblePages indexOfObject:_selectedPage];
	return _visibleIndexes.location + index;
}



- (void) scrollToPageAtIndex : (NSInteger) index animated : (BOOL) animated; 
{
	CGPoint offset = CGPointMake(index * _scrollView.frame.size.width, 0);
	[_scrollView setContentOffset:offset animated:animated];
}


- (void) selectPageAtIndex : (NSInteger) index animated : (BOOL) animated;
{
	if (index != [self indexForSelectedPage]) {
        
        // rebuild _visibleIndexes
        BOOL isLastPage = (index == _numberOfPages-1);
        BOOL isFirstPage = (index == 0); 
        NSInteger selectedVisibleIndex; 
        if (_numberOfPages == 1) {
            _visibleIndexes.location = index;
            _visibleIndexes.length = 1;
            selectedVisibleIndex = 0;
        }
        else if (isLastPage) {
            _visibleIndexes.location = index-1;
            _visibleIndexes.length = 2;
            selectedVisibleIndex = 1;
        }
        else if(isFirstPage){
            _visibleIndexes.location = index;
            _visibleIndexes.length = 2;                
            selectedVisibleIndex = 0;
        }
        else{
            _visibleIndexes.location = index-1;
            _visibleIndexes.length = 3;           
            selectedVisibleIndex = 1;
        }
 
        // update the scrollView content offset
        _scrollView.contentOffset = CGPointMake(index * _scrollView.frame.size.width, 0);

        // reload the data for the new indexes
        [self reloadData];
        
        // update _selectedPage
        _selectedPage = [_visiblePages objectAtIndex:selectedVisibleIndex];
        
        // update the page selector (pageControl)
        [_pageSelector setCurrentPage:index];

	}
    
	[self setViewMode:HGPageScrollViewModePage animated:animated];
}


- (void) deselectPageAnimated : (BOOL) animated;
{
	[self setViewMode:HGPageScrollViewModeDeck animated:animated];
}


- (void) preparePage : (HGPageView *) page forMode : (HGPageScrollViewMode) mode 
{
    // When a page is presented in HGPageScrollViewModePage mode, it is scaled up and is moved to a different superview. 
    // As it captures the full screen, it may be cropped to fit inside its new superview's frame. 
    // So when moving it back to HGPageScrollViewModeDeck, we restore the page's proportions to prepare it to Deck mode.  
	if (mode == HGPageScrollViewModeDeck && 
        CGAffineTransformEqualToTransform(page.transform, CGAffineTransformIdentity)) {
        page.frame = page.identityFrame;
	}
    
}


- (void) setViewMode:(HGPageScrollViewMode)mode animated:(BOOL)animated;
{
//	if (_viewMode == mode) {
//		return;
//	}
	
	_viewMode = mode;
	
	if (_selectedPage) {
        [self preparePage:_selectedPage forMode:mode];
    }
    
	NSInteger selectedIndex = [self indexForSelectedPage];

	void (^SelectBlock)(void) = (mode==HGPageScrollViewModePage)? ^{
		
		// move to HGPageScrollViewModePage
		if([self.delegate respondsToSelector:@selector(pageScrollView:willSelectPageAtIndex:)]) {
			[self.delegate pageScrollView:self willSelectPageAtIndex:selectedIndex];
		}				
		[_scrollView bringSubviewToFront:_selectedPage];
		if ([self.dataSource respondsToSelector:@selector(pageScrollView:headerViewForPageAtIndex:)]) {
            [_pageHeaderView removeFromSuperview]; 
            [_pageHeaderView release]; 
			//use the header view initialized by the dataSource 
			_pageHeaderView = [[self.dataSource pageScrollView:self headerViewForPageAtIndex:selectedIndex] retain];
            [self addSubview : _pageHeaderView];
		}
		else { //use the default header view
			[self initHeaderForPageAtIndex:selectedIndex]; 
		}

		// scale the page up to it 1:1 (identity) scale
		_selectedPage.transform = CGAffineTransformIdentity; 
		        
        // adjust the frame
        CGRect frame = _selectedPage.frame;
		frame.origin.y = _pageHeaderView.frame.size.height - _scrollView.frame.origin.y;
        
        // store this frame for the backward animation
        _selectedPage.identityFrame = frame; 

        // finally crop frame to fit inside new superview (see CompletionBlock) 
		frame.size.height = self.frame.size.height - _pageHeaderView.frame.size.height;
		_selectedPage.frame = frame;


		
		// reveal the page header view
		_pageHeaderView.alpha = 1.0;
		
		//remove unnecessary views
		[_scrollViewTouch removeFromSuperview];
		[_pageSelectorTouch removeFromSuperview];
	} : ^{
		
		// move to HGPageScrollViewModeDeck
		_pageSelector.hidden = NO;
		_pageDeckTitleLabel.hidden = NO;
		_pageDeckSubtitleLabel.hidden = NO;
		[self initDeckTitlesForPageAtIndex:selectedIndex];
		// add the page back to the scrollView and transform it
        [_scrollView addSubview:_selectedPage];
		_selectedPage.transform = CGAffineTransformMakeScale(0.6, 0.6);	
 		CGRect frame = _selectedPage.frame;
        frame.origin.y = 0;
        _selectedPage.frame = frame;
        _pageHeaderView.alpha = 0.0;	
		if ([self.delegate respondsToSelector:@selector(pageScrollView:willDeselectPageAtIndex:)]) {
			[self.delegate pageScrollView:self willDeselectPageAtIndex:selectedIndex];
		}		
	};
	
	void (^CompletionBlock)(BOOL) = (mode==HGPageScrollViewModePage)? ^(BOOL finished){
		// set flags
		_pageDeckTitleLabel.hidden = YES;
		_pageDeckSubtitleLabel.hidden = YES;
		_pageSelector.hidden = YES;
		_scrollView.scrollEnabled = NO;
		_selectedPage.alpha = 1.0;
		// copy _selectedPage up in the view hierarchy, to allow touch events on its entire frame 
		_selectedPage.frame = CGRectMake(0, _pageHeaderView.frame.size.height, self.frame.size.width, _selectedPage.frame.size.height);
		[self addSubview:_selectedPage];
		// notify delegate
		if ([self.delegate respondsToSelector:@selector(pageScrollView:didSelectPageAtIndex:)]) {
			[self.delegate pageScrollView:self didSelectPageAtIndex:selectedIndex];
		}		
	} : ^(BOOL finished){
		_scrollView.scrollEnabled = YES;				
		//_scrollView.frame = CGRectMake(0, _scrollViewTouch.frame.origin.y, self.frame.size.width, _scrollViewTouch.frame.size.height);
		[self addSubview:_scrollViewTouch];
		[self addSubview: _pageSelectorTouch];
		if ([self.delegate respondsToSelector:@selector(pageScrollView:didDeselectPageAtIndex:)]) {
			[self.delegate pageScrollView:self didDeselectPageAtIndex:selectedIndex];
		}		
	};
	
	
	if(animated){
		[UIView animateWithDuration:0.3 animations:SelectBlock completion:CompletionBlock];
	}
	else {
		SelectBlock();
		CompletionBlock(YES);
	}
	
}


#pragma mark -
#pragma mark Page Insertion and Loading



- (void) reloadData; 
{
	if ([self.dataSource respondsToSelector:@selector(numberOfPagesInScrollView:)]) {
		_numberOfPages = [self.dataSource numberOfPagesInScrollView:self];
	}
	
	// reset visible pages array
	[_visiblePages removeAllObjects];
	
	// set pageScroller contentSize
	_scrollView.contentSize = CGSizeMake(_numberOfPages * _scrollView.frame.size.width, _scrollView.frame.size.height);
	
	if (_numberOfPages > 0) {
		
		// reload visible pages
		for (int index=0; index<_visibleIndexes.length; index++) {
			[self loadPageAtIndex:_visibleIndexes.location+index insertIntoVisibleIndex:index];
		}
		
		// this will load any additional views which become visible  
		[self updateVisiblePages];
		
		// set page selector (page control)
		[_pageSelector setNumberOfPages:_numberOfPages];
				
	}
    
    // reloading the data implicitely resets the viewMode to UIPageScrollViewModeDeck. 
    // here we restore the view mode in case this is not the first time reloadData is called (i.e. if there if a _selectedPage).   
    if (_selectedPage && _viewMode==HGPageScrollViewModePage) { 
        [self setViewMode:_viewMode animated:NO];
    }
}



- (void) loadPageAtIndex : (NSInteger) index insertIntoVisibleIndex : (NSInteger) visibleIndex
{
	HGPageView *visiblePage = [self.dataSource pageScrollView:self viewForPageAtIndex:index];
	if (visiblePage.reuseIdentifier) {
		NSMutableArray *reusables = [_reusablePages objectForKey:visiblePage.reuseIdentifier];
		if (!reusables) {
			reusables = [[[NSMutableArray alloc] initWithCapacity : 4] autorelease];
		}
		if (![reusables containsObject:visiblePage]) {
			[reusables addObject:visiblePage];
		}
		[_reusablePages setObject:reusables forKey:visiblePage.reuseIdentifier];
	}
	
	// add the page to the visible pages array
	[_visiblePages insertObject:visiblePage atIndex:visibleIndex];
	
	// add the page to the scroll view (to make it actually visible)
	[self insertPageInScrollView:visiblePage atIndex:index];
	
}


- (void) insertPageInScrollView : (HGPageView *) page atIndex : (NSInteger) index
{
    // inserting a page into the scroll view is in HGPageScrollViewModeDeck by definition (the scroll is the "deck")
    [self preparePage:page forMode:HGPageScrollViewModeDeck];
         
	// configure the page frame
	page.transform = CGAffineTransformMakeScale(0.6, 0.6);;
	CGFloat contentOffset = index * _scrollView.frame.size.width;//_scrollView.contentSize.width;
	CGFloat margin = (_scrollView.frame.size.width - page.frame.size.width) / 2; 
	CGRect frame = page.frame;
	frame.origin.x = contentOffset + margin;
	frame.origin.y = 0.0;
	page.frame = frame;


	// add shadow (use shadowPath to improve rendering performance)
	page.layer.shadowColor = [[UIColor blackColor] CGColor];	
	page.layer.shadowOffset = CGSizeMake(8.0f, 12.0f);
	page.layer.shadowOpacity = 0.3f;
    page.layer.masksToBounds = NO;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:page.bounds];
    page.layer.shadowPath = path.CGPath;	
	
    // add the page to the scroller
	[_scrollView insertSubview:page atIndex:0];
		
	NSLog(@"inserted page 0x%x at index %d offset=%f, frame={%f,%f,%f,%f}", page, index, contentOffset, page.frame.origin.x, page.frame.origin.y, page.frame.size.width, page.frame.size.height);
	

}


- (void) reloadPageInScrollViewAtIndex : (NSInteger) index 
{
	
}



#pragma mark -
#pragma mark UIScrollViewDelegate
/*
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	_userInitiatedScroll = YES;
}
*/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// update the visible pages
	[self updateVisiblePages];
	
	// adjust alpha for all visible pages
	[_visiblePages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self setAlphaForPage : obj];		
	}];
	
	// update _selectedPage if the scroll was triggered by user swipe
	// otherwise, i.e. if scroll was triggered in code, _selectedPage has already been updated.    
//	if (!_userInitiatedScroll) {
//		return;
//	}
	
	CGFloat delta = scrollView.contentOffset.x - _selectedPage.frame.origin.x;
	BOOL toggleNextItem = (fabs(delta) > scrollView.frame.size.width / 2);
	if (toggleNextItem && [_visiblePages count] > 1) {
		
		NSInteger selectedIndex = [_visiblePages indexOfObject:_selectedPage];
		BOOL neighborExists = ((delta < 0 && selectedIndex > 0) || (delta > 0 && selectedIndex < [_visiblePages count]-1));
		
		if (neighborExists) {
			
			NSInteger neighborPageVisibleIndex = [_visiblePages indexOfObject:_selectedPage] + (delta > 0? 1:-1);
			HGPageView *neighborPage = [_visiblePages objectAtIndex:neighborPageVisibleIndex];
			NSInteger neighborIndex = _visibleIndexes.location + neighborPageVisibleIndex;

			[self updateScrolledPage:neighborPage index:neighborIndex];
			
		}
		
	}

}


- (void) updateScrolledPage : (HGPageView*) page index : (NSInteger) index
{
	// notify delegate
	if ([self.delegate respondsToSelector:@selector(pageScrollView:willScrollToPage:atIndex:)]) {
		[self.delegate pageScrollView:self willScrollToPage:page atIndex:index];
	}
	
	// update title and subtitle
	if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
		_pageDeckTitleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
	}
	if ([self.dataSource respondsToSelector:@selector(pageScrollView:subtitleForPageAtIndex:)]) {
		_pageDeckSubtitleLabel.text = [self.dataSource pageScrollView:self subtitleForPageAtIndex:index];
	}
	
	// set the page selector (page control)
	[_pageSelector setCurrentPage:index];
	
	// set selected page
	_selectedPage = page;
	NSLog(@"selectedPage: 0x%x (%d)", page, index );
    
	// notify delegate again
	if ([self.delegate respondsToSelector:@selector(pageScrollView:didScrollToPage:atIndex:)]) {
		[self.delegate pageScrollView:self didScrollToPage:page atIndex:index];
	}		
	
}



- (void) updateVisiblePages
{
	CGFloat pageWidth = _scrollView.frame.size.width;

	//get x origin of left- and right-most pages in _scrollView's superview coordinate space (i.e. self)  
	CGFloat leftViewOriginX = _scrollView.frame.origin.x - _scrollView.contentOffset.x + (_visibleIndexes.location * pageWidth);
	CGFloat rightViewOriginX = _scrollView.frame.origin.x - _scrollView.contentOffset.x + (_visibleIndexes.location+_visibleIndexes.length-1) * pageWidth;
	
	if (leftViewOriginX > 0) {
		//new page is entering the visible range from the left
		if (_visibleIndexes.location > 0) { //is is not the first page?
			_visibleIndexes.length += 1;
			_visibleIndexes.location -= 1;
			[self loadPageAtIndex:_visibleIndexes.location insertIntoVisibleIndex:0];
		}
	}
	else if(leftViewOriginX < -pageWidth){
		//left page is exiting the visible range
		[_visiblePages removeObjectAtIndex:0];
		_visibleIndexes.location += 1;
		_visibleIndexes.length -= 1;
	}
	if (rightViewOriginX > self.frame.size.width) {
		//right page is exiting the visible range
		[_visiblePages removeLastObject];
		_visibleIndexes.length -= 1;
	}
	else if(rightViewOriginX + pageWidth < self.frame.size.width){
		//new page is entering the visible range from the right
		if (_visibleIndexes.location + _visibleIndexes.length < _numberOfPages) { //is is not the last page?
			_visibleIndexes.length += 1;
			[self loadPageAtIndex:_visibleIndexes.location+_visibleIndexes.length-1 insertIntoVisibleIndex:_visibleIndexes.length-1];
		}
	}
}


- (void) setAlphaForPage : (HGPageView*) page
{
	CGFloat delta = _scrollView.contentOffset.x - page.frame.origin.x;
	CGFloat step = self.frame.size.width;
	CGFloat alpha = 1.0 - fabs(delta/step);
	if(alpha > 0.95) alpha = 1.0;
    page.alpha = alpha;

}



- (void) initHeaderForPageAtIndex : (NSInteger) index
{
	if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
		UILabel *titleLabel = (UILabel*)[_pageHeaderView viewWithTag:1];
		titleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
	}
	
	if ([self.dataSource respondsToSelector:@selector(pageScrollView:subtitleForPageAtIndex:)]) {		
		UILabel *subtitleLabel = (UILabel*)[_pageHeaderView viewWithTag:2];
		subtitleLabel.text = [self.dataSource pageScrollView:self subtitleForPageAtIndex:index];
	}
	
}


- (void) initDeckTitlesForPageAtIndex : (NSInteger) index;
{
	if ([self.dataSource respondsToSelector:@selector(pageScrollView:titleForPageAtIndex:)]) {
		_pageDeckTitleLabel.text = [self.dataSource pageScrollView:self titleForPageAtIndex:index];
	}

	if ([self.dataSource respondsToSelector:@selector(pageScrollView:subtitleForPageAtIndex:)]) {
		_pageDeckSubtitleLabel.text = [self.dataSource pageScrollView:self subtitleForPageAtIndex:index];
	}
	
}


- (HGPageView *)dequeueReusablePageWithIdentifier:(NSString *)identifier;  // Used by the delegate to acquire an already allocated page, instead of allocating a new one
{
	HGPageView *reusablePage = nil;
	NSArray *reusables = [_reusablePages objectForKey:identifier];
	if (reusables){
		NSEnumerator *enumerator = [reusables objectEnumerator];
		while ((reusablePage = [enumerator nextObject])) {
			if(![_visiblePages containsObject:reusablePage]){
				[reusablePage prepareForReuse];
				break;
			}
		}
	}
	return reusablePage;
}


#pragma mark -
#pragma mark Handling Touches


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if (_viewMode == HGPageScrollViewModeDeck && !_scrollView.decelerating) {
		return YES;	
	}
	return NO;	
}


- (void)handleTapGestureFrom:(UITapGestureRecognizer *)recognizer 
{
	NSInteger selectedIndex = [self indexForSelectedPage];
	
	[self selectPageAtIndex:selectedIndex animated:YES];
		
}


#pragma mark -
#pragma mark Actions


- (void) didChangePageValue : (id) sender;
{
	NSInteger selectedIndex = [self indexForSelectedPage];
	if(_pageSelector.currentPage != selectedIndex){
		//set pageScroller
		selectedIndex = _pageSelector.currentPage;
		//_userInitiatedScroll = NO;		
		[self scrollToPageAtIndex:selectedIndex animated:YES];			
	}
}



@end
