//
//  HGPageScrollViewSampleViewController.m
//  HGPageScrollViewSample
//
//  Created by Rotem Rubnov on 13/3/2011.
//	Copyright (C) 2011 TomTom
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
//

#import "HGPageScrollViewSampleViewController.h"
#import "MyPageData.h"
#import "MyPageView.h"
#import "MyTableViewController.h"


@interface HGPageScrollViewSampleViewController(internal)
- (UIViewController*) headerInfoForPageAtIndex : (NSInteger) index;
- (void) addPagesAtIndexSet : (NSIndexSet *) indexSet;
- (void) removePagesAtIndexSet : (NSIndexSet *) indexSet;
- (void) reloadPagesAtIndexSet : (NSIndexSet*) indexSet; 

@end


#define kPlatformSupportsViewControllerHeirarchy ([self respondsToSelector:@selector(childViewControllers)] && [self.childViewControllers isKindOfClass:[NSArray class]])

@implementation HGPageScrollViewSampleViewController



/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// load pageScrollView data
	_myPageDataArray = [[NSMutableArray alloc] initWithCapacity : kNumPages];
	
	for (int i=0; i<kNumPages; i++) {
		MyPageData *pageData = [[[MyPageData alloc] init] autorelease];
		pageData.title = [NSString stringWithFormat:@"%d: Title text", i];
		pageData.subtitle = [NSString stringWithFormat:@"%d: Subtitle text with some extra information", i];
		pageData.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%d", i]];
		[_myPageDataArray addObject:pageData];
        
        if ( i < 3 ) {
            // Add another image-only page
            MyPageData *imagePageData = [[[MyPageData alloc] init] autorelease];
            imagePageData.title = [NSString stringWithFormat:@"%d im: Title text", i];
            imagePageData.subtitle = [NSString stringWithFormat:@"%d im: Subtitle text", i];
            imagePageData.image = pageData.image;
            imagePageData.isImageOnly = YES;
            [_myPageDataArray addObject:imagePageData];
        }
	}
    
    // create a sample navigationController and insert it's rootViewController's view into the data array
    MyTableViewController *myViewController = [[[MyTableViewController alloc] initWithNibName:@"MyTableViewController" bundle:nil] autorelease];
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:myViewController] autorelease];
    [navController setToolbarHidden:NO];
    MyPageData *pageData = [[[MyPageData alloc] init] autorelease];
    pageData.navController = navController;
    [_myPageDataArray insertObject:pageData atIndex:0];

    if (kPlatformSupportsViewControllerHeirarchy) {
        // set MyTableViewController as our own child as long as we're in deck mode. 
        [self addChildViewController:myViewController];
    }

	
	UIBarButtonItem *deckButton = [[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%d", [_myPageDataArray count]] style:UIBarButtonItemStyleBordered target:self action:@selector(didClickBrowsePages:)] autorelease];

	UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickAddPage:)] autorelease];

    UIBarButtonItem *removeButton = [[[UIBarButtonItem alloc] initWithTitle:@"-" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickRemovePage:)] autorelease];

	[toolbar setItems:[NSArray arrayWithObjects:deckButton, addButton, removeButton, nil] animated:NO];
	
	// now that we have the data, initialize the page scroll view
	_myPageScrollView = [[[NSBundle mainBundle] loadNibNamed:@"HGPageScrollView" owner:self options:nil] objectAtIndex:0];
	[self.view addSubview:_myPageScrollView];
    
    
    // uncomment this line if you want to select a page initially, before HGPageScrollView is shown, 
	//[pageScrollView selectPageAtIndex:0 animated:NO];
        
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[_myPageDataArray release];
    [super dealloc];
}


#pragma mark -
#pragma mark HGPageScrollViewDataSource


- (NSInteger)numberOfPagesInScrollView:(HGPageScrollView *)scrollView;   // Default is 0 if not implemented
{
	return [_myPageDataArray count];
}


- (UIView *)pageScrollView:(HGPageScrollView *)scrollView headerViewForPageAtIndex:(NSInteger)index;  
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (pageData.navController) {
        UIView *navBarCopy = [[[UINavigationBar alloc] initWithFrame:pageData.navController.navigationBar.frame] autorelease];
        return navBarCopy;
    }
        
    return nil;
}


- (HGPageView *)pageScrollView:(HGPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index;
{    
    
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (pageData.navController) {

        if (kPlatformSupportsViewControllerHeirarchy) {
            // on iOS 5 use built-in view controller hierarchy support
            UIViewController *viewController = [self.childViewControllers objectAtIndex:0];
            return (HGPageView*)viewController.view;
        }
        else{
            return (HGPageView*)pageData.navController.topViewController.view;
        }
    } else if (pageData.isImageOnly) {
        CGSize imageSize = [[pageData image] size];
        CGRect frame = CGRectMake(0, 0, 320, 320.0 / imageSize.width * imageSize.height);
        
        HGPageImageView *imageView = [[HGPageImageView alloc]
                                      initWithFrame:frame];
        [imageView setImage:[pageData image]];
        [imageView setReuseIdentifier:@"imageId"];
        
        return imageView;
    }
    else{
        static NSString *pageId = @"pageId";
        MyPageView *pageView = (MyPageView*)[scrollView dequeueReusablePageWithIdentifier:pageId];
        if (!pageView) {
            // load a new page from NIB file
            pageView = [[[NSBundle mainBundle] loadNibNamed:@"MyPageView" owner:self options:nil] objectAtIndex:0]; 
            pageView.reuseIdentifier = pageId;
        }
        
        // configure the page
        
        UILabel *titleLabel = (UILabel*)[pageView viewWithTag:1];
        titleLabel.text = pageData.title;
        
        UIImageView *imageView = (UIImageView*)[pageView viewWithTag:2];
        imageView.image = pageData.image;
        
        //UITextView *textView = (UITextView*)[pageView viewWithTag:3];
        //	textView.text = @"some text here";
        
        //adjust content size of scroll view
        UIScrollView *pageContentsScrollView = (UIScrollView*)[pageView viewWithTag:10];	
        pageContentsScrollView.scrollEnabled = NO; //initially disable scroll
        
        // set the pageView frame height
        CGRect frame = pageView.frame;
        frame.size.height = 420; 
        pageView.frame = frame; 
        return pageView;
        
    }
	
}


- (NSString *)pageScrollView:(HGPageScrollView *)scrollView titleForPageAtIndex:(NSInteger)index;  
{
    id<PageHeaderInfo> headerInfo = (id<PageHeaderInfo>)[self headerInfoForPageAtIndex:index]; 
    return [headerInfo pageTitle];
        
}

- (NSString *)pageScrollView:(HGPageScrollView *)scrollView subtitleForPageAtIndex:(NSInteger)index;  
{
    id<PageHeaderInfo> headerInfo = (id<PageHeaderInfo>)[self headerInfoForPageAtIndex:index]; 
    return [headerInfo pageSubtitle];
}


- (UIViewController*) headerInfoForPageAtIndex : (NSInteger) index
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (pageData.navController) {
        // in this sample project, the page at index 0 is a navigation controller. 
        return pageData.navController.topViewController;
    }
    else{
        return [_myPageDataArray objectAtIndex:index];        
    }
}

#pragma mark - 
#pragma mark HGPageScrollViewDelegate

- (void)pageScrollView:(HGPageScrollView *)scrollView willSelectPageAtIndex:(NSInteger)index;
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    
    if (!pageData.navController) {
        MyPageView *page = (MyPageView*)[scrollView pageAtIndex:index];
        UIScrollView *pageContentsScrollView = (UIScrollView*)[page viewWithTag:10];
        
        if (!page.isInitialized) {
            // prepare the page for interaction. This is a "second step" initialization of the page 
            // which we are deferring to just before the page is selected. While the page is initially
            // requeseted (pageScrollView:viewForPageAtIndex:) this extra step is not required and is preferably 
            // avoided due to performace reasons.  
            
            // asjust text box height to show all text
            UITextView *textView = (UITextView*)[page viewWithTag:3];
            CGFloat margin = 12;
            CGSize size = [textView.text sizeWithFont:textView.font
                                    constrainedToSize:CGSizeMake(textView.frame.size.width, 2000) //very large height
                                        lineBreakMode:UILineBreakModeWordWrap];
            CGRect frame = textView.frame;
            frame. size.height = size.height + 4*margin;
            textView.frame = frame;
            
            // adjust content size of scroll view
            pageContentsScrollView.contentSize = CGSizeMake(pageContentsScrollView.frame.size.width, frame.origin.y + frame.size.height);
            
            // mark the page as initialized, so that we don't have to do all of the above again 
            // the next time this page is selected
            page.isInitialized = YES;  
        }
        
        // enable scroll
        pageContentsScrollView.scrollEnabled = YES;
        
    }
    else{
        if (kPlatformSupportsViewControllerHeirarchy) {

            // this page is presented within UINavigationController navigation stack
            // while in DECK mode, the view controller owning this view is our own child. This is done to be consistent with iOS view-heirarchy rules. 
            // Now that the page is about to be selected (HGPageScroller is switching to PAGE mode), we need to associate the view controller with the UINaivationController in which it belongs.
            UIViewController *childViewController = [self.childViewControllers objectAtIndex:0];
            [pageData.navController pushViewController:childViewController animated:NO]; 
        }
    }
    
	
}

- (void) pageScrollView:(HGPageScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (pageData.navController) {
        // copy the toolbar items to the navigation controller
        [pageData.navController.topViewController setToolbarItems:toolbar.items];
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:pageData.navController animated:NO];
    }
    else{
        // add "edit" button to the toolbar
        UIBarButtonItem *editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didClickEditPage:)] autorelease];
        NSMutableArray *items = [NSMutableArray arrayWithArray:toolbar.items];
        [items addObject:editButton];
        toolbar.items = items;
        
    }

}

- (void)pageScrollView:(HGPageScrollView *)scrollView willDeselectPageAtIndex:(NSInteger)index;
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    
    if (!pageData.navController) {
        // disable scroll of the contents page to avoid conflict with horizonal scroll of the pageScrollView
        HGPageView *page = [scrollView pageAtIndex:index];
        UIScrollView *scrollContentView = (UIScrollView*)[page viewWithTag:10];
        scrollContentView.scrollEnabled = NO;

        // remove "edit" button from toolbar
        NSMutableArray *items = [NSMutableArray arrayWithArray:toolbar.items];
        [items removeLastObject];
        toolbar.items = items;
    }
    else{
        if ([self respondsToSelector:@selector(addChildViewController:)]) {

            // this page is presented within UINavigationController navigation stack
            // while in PAGE mode, the view controller owning this page is a child of UINavigationController. 
            // Before moving back to DECK mode, we need to re-associate this view controller with us (making it our child). After the transition to DECK mode completes, the page is inserted as a subview into HGPageScrollView. Before this happens, the view controller owning this page must be our own child. This is done to be consistent with iOS view-heirarchy rules.
            UIViewController *viewController = pageData.navController.topViewController;
            [self addChildViewController:viewController];
        }
    }

    
}


- (void)pageScrollView:(HGPageScrollView *)scrollView didDeselectPageAtIndex:(NSInteger)index
{
    // Now the page scroller is in DECK mode. 
    // Complete an add/remove pages request if one is pending
    if (indexesToDelete) {
        [self removePagesAtIndexSet:indexesToDelete];
        [indexesToDelete release];
        indexesToDelete = nil;
    }
    if (indexesToInsert) {
        [self addPagesAtIndexSet:indexesToInsert];
        [indexesToInsert release];
        indexesToInsert = nil;
    }
}



#pragma mark - toolbar Actions


- (IBAction) didClickBrowsePages : (id) sender
{
	HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
	

    if (self.modalViewController) {
        MyPageData *pageData = [_myPageDataArray objectAtIndex:[pageScrollView indexForSelectedPage]];
        [self dismissModalViewControllerAnimated:NO];
        // copy the toolbar items back to our own toolbar
        [toolbar setItems:[NSArray arrayWithArray : pageData.navController.topViewController.toolbarItems]];
    }
    
	if(pageScrollView.viewMode == HGPageScrollViewModePage){  
		[pageScrollView deselectPageAnimated:YES];
	}
	else {
		[pageScrollView selectPageAtIndex:[pageScrollView indexForSelectedPage] animated:YES];
	}
	
	
}


- (IBAction) didClickAddPage : (id) sender
{
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    
    // create an index set of the pages we wish to add
    [indexesToInsert release];

    // example 1: inserting one page at the current index  
    NSInteger selectedPageIndex = [pageScrollView indexForSelectedPage];
    indexesToInsert = [[NSMutableIndexSet alloc] initWithIndex:(selectedPageIndex == NSNotFound)? 0 : selectedPageIndex];

    // example 2: appending 2 pages at the end of the page scroller 
    //NSRange range; range.location = [_myPageDataArray count]; range.length = 2;
    //indexesToInsert = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];

    // example 3: inserting 2 pages at the beginning of the page scroller 
    //NSRange range; range.location = 0; range.length = 2;
    //indexesToInsert = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];

    
    // we can only insert pages in DECK mode
    if (pageScrollView.viewMode == HGPageScrollViewModePage) {
        [self didClickBrowsePages:self];
    }
    else{
        [self addPagesAtIndexSet:indexesToInsert];
        [indexesToInsert release];
        indexesToInsert = nil;
    }

}



- (void) addPagesAtIndexSet : (NSIndexSet *) indexSet 
{
    // create new pages and add them to the data set 
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        MyPageData *pageData = [[[MyPageData alloc] init] autorelease];
        pageData.title = [NSString stringWithFormat:@"New Page %d", idx];
        pageData.subtitle = [NSString stringWithFormat:@"Subtitle of my new page: %d", idx];
        pageData.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%d", idx%9]]; //there are only 9 images in this sample project...
        [_myPageDataArray insertObject:pageData atIndex:idx];
    }];
    
    // update the page scroller 
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    [pageScrollView insertPagesAtIndexes:indexSet animated:YES];

    // update the toolbar
    UIBarButtonItem *deckButton = [toolbar.items objectAtIndex:0];
    [deckButton setTitle:[NSString stringWithFormat:@"%d", [_myPageDataArray count]]]; 
    
    if ([toolbar.items count] == 2) {
        //Add the "delete page" button.
        UIBarButtonItem *removeButton = [[[UIBarButtonItem alloc] initWithTitle:@"-" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickRemovePage:)] autorelease];

        NSArray *items = [NSArray arrayWithObjects:[toolbar.items objectAtIndex:0], [toolbar.items objectAtIndex:1], removeButton, nil];
        [toolbar setItems:items];
    }
    
}


- (IBAction) didClickRemovePage : (id) sender
{
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    
    // create an index set of the pages we wish to delete
    [indexesToDelete release];
    
    // example 1: deleting the page at the current index
    indexesToDelete = [[NSMutableIndexSet alloc] initWithIndex:[pageScrollView indexForSelectedPage]];
    
    // example 2: deleting the last 2 pages from the page scroller
    //NSRange range; range.location = [_myPageDataArray count] - 2; range.length = 2;
    //indexesToDelete = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
        
    // example 3: deleting the first 2 pages from the page scroller
    //NSRange range; range.location = 0; range.length = 2;
    //indexesToDelete = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    
    // we can only delete pages in DECK mode
    if (pageScrollView.viewMode == HGPageScrollViewModePage) {
        [pageScrollView deselectPageAnimated:YES];
    }
    else{
        [self removePagesAtIndexSet:indexesToDelete];
        [indexesToDelete release];
        indexesToDelete = nil;
    }
    
}


- (void) removePagesAtIndexSet : (NSIndexSet *) indexSet 
{
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];

    // remove from the data set
    [_myPageDataArray removeObjectsAtIndexes:indexSet];

    // update the page scroller
    [pageScrollView deletePagesAtIndexes:indexSet animated : YES];
    
    // update toolbar
    UIBarButtonItem *deckButton = [toolbar.items objectAtIndex:0];
    [deckButton setTitle:[NSString stringWithFormat:@"%d", [_myPageDataArray count]]]; 
  
    if ([_myPageDataArray count] == 0) {
        //no more pages to remove. Remove the "delete page" button.
        NSArray *items = [NSArray arrayWithObjects:[toolbar.items objectAtIndex:0], [toolbar.items objectAtIndex:1], nil];
        [toolbar setItems:items];
    }
    
}



- (IBAction) didClickEditPage : (id) sender
{
    
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];

    NSInteger selectedIndex = [pageScrollView indexForSelectedPage];
    MyPageData *pageData = [_myPageDataArray objectAtIndex:selectedIndex]; 
    if (!pageData.navController) {
        MyPageView *page = (MyPageView*)[pageScrollView pageAtIndex:selectedIndex];
        UITextField *textField = (UITextField*)[page viewWithTag:4];
        textField.hidden = NO;
        textField.text = pageData.title;
        textField.delegate = self;
        [textField becomeFirstResponder];
    }
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;            
{
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    NSInteger selectedIndex = [pageScrollView indexForSelectedPage];
    MyPageData *pageData = [_myPageDataArray objectAtIndex:selectedIndex]; 
    
    pageData.title = textField.text;   

    [textField resignFirstResponder];
    textField.hidden = YES;
    textField.delegate = nil;
    
    [indexesToReload release];
    indexesToReload = [[NSMutableIndexSet alloc] initWithIndex:selectedIndex];
    
    if (pageScrollView.viewMode == HGPageScrollViewModePage) {
        [pageScrollView deselectPageAnimated:YES];
    }
    else{
        [self reloadPagesAtIndexSet : indexesToReload];
    }
    
    return YES;
}

- (void) reloadPagesAtIndexSet : (NSIndexSet*) indexSet 
{
    HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
    [pageScrollView reloadPagesAtIndexes:indexesToReload];
}


@end

