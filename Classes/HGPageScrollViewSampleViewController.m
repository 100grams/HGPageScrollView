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
@end


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
	}
	
	UIBarButtonItem *buttonItem = [[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%d", [_myPageDataArray count]] style:UIBarButtonItemStyleBordered target:self action:@selector(didClickBrowsePages:)] autorelease];

	[toolbar setItems:[NSArray arrayWithObject:buttonItem] animated:NO];
	
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
    [_myNavController release];
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
    if (index == 0) {
        UIView *navBarCopy = [[[UINavigationBar alloc] initWithFrame:_myNavController.navigationBar.frame] autorelease];
        return navBarCopy;
    }
        
    return nil;
}


- (HGPageView *)pageScrollView:(HGPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index;
{    
    
    if (index == 0) {
        if (!_myNavController) {
            MyTableViewController *myViewController = [[[MyTableViewController alloc] initWithNibName:@"MyTableViewController" bundle:nil] autorelease];
            _myNavController = [[UINavigationController alloc] initWithRootViewController:myViewController];
            [_myNavController setToolbarHidden:NO];
        }
        return (HGPageView*)_myNavController.topViewController.view;
    }
    else{
        static NSString *pageId = @"pageId";
        MyPageView *pageView = (MyPageView*)[scrollView dequeueReusablePageWithIdentifier:pageId];
        if (!pageView) {
            pageView = [[[NSBundle mainBundle] loadNibNamed:@"MyPageView" owner:self options:nil] objectAtIndex:0]; 
            pageView.reuseIdentifier = pageId;
        }
        
        // configure the page
        MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
        
        UILabel *titleLabel = (UILabel*)[pageView viewWithTag:1];
        titleLabel.text = pageData.title;
        
        UIImageView *imageView = (UIImageView*)[pageView viewWithTag:2];
        imageView.image = pageData.image;
        
        //UITextView *textView = (UITextView*)[pageView viewWithTag:3];
        //	textView.text = pageData.description;
        
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
    if (index == 0) {
        // in this sample project, the page at index 0 is a navigation controller. 
        return _myNavController.topViewController;
    }
    else{
        return [_myPageDataArray objectAtIndex:index];        
    }
}

#pragma mark - 
#pragma mark HGPageScrollViewDelegate

- (void)pageScrollView:(HGPageScrollView *)scrollView willSelectPageAtIndex:(NSInteger)index;
{
    if (index > 0) {
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
    
	
}

- (void) pageScrollView:(HGPageScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index
{
    if (index == 0) {
        // copy the toolbar items to the navigation controller
        [_myNavController.topViewController setToolbarItems:toolbar.items];
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:_myNavController animated:NO];
    }
}

- (void)pageScrollView:(HGPageScrollView *)scrollView willDeselectPageAtIndex:(NSInteger)index;
{
    if (index > 0) {
        // disable scroll of the contents page to avoid conflict with horizonal scroll of the pageScrollView
        HGPageView *page = [scrollView pageAtIndex:index];
        UIScrollView *scrollContentView = (UIScrollView*)[page viewWithTag:10];
        scrollContentView.scrollEnabled = NO;
    }

}



- (IBAction) didClickBrowsePages : (id) sender
{
	HGPageScrollView *pageScrollView = [[self.view subviews] lastObject];
	
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:NO];
        // copy the toolbar items back to our own toolbar
        [toolbar setItems:[NSArray arrayWithArray : _myNavController.topViewController.toolbarItems]];
    }
    
	if(pageScrollView.viewMode == HGPageScrollViewModePage){  
		[pageScrollView deselectPageAnimated:YES];
	}
	else {
		[pageScrollView selectPageAtIndex:[pageScrollView indexForSelectedPage] animated:YES];
	}
	
	
}



@end

