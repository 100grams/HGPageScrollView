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
	
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%d", [_myPageDataArray count]] style:UIBarButtonItemStyleBordered target:self action:@selector(didClickBrowsePages:)];
	//barButton.frame = CGRect();
	[toolbar setItems:[NSArray arrayWithObject:barButton] animated:NO];
	
	// now that we have the data, initialize the page scroll view
	pageScrollView = [[[NSBundle mainBundle] loadNibNamed:@"HGPageScrollView" owner:self options:nil] objectAtIndex:0];
	[self.view addSubview:pageScrollView];
	
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


- (HGPageView *)pageScrollView:(HGPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index;
{
	static NSString *pageId = @"pageId";
	
	HGPageView *pageView = [scrollView dequeueReusablePageWithIdentifier:pageId];
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
	
	UITextView *textView = (UITextView*)[pageView viewWithTag:3];
	//	textView.text = pageData.description;
	//adjust description text box to show all text
	CGFloat margin = 12;
	CGSize size = [textView.text sizeWithFont:textView.font
							constrainedToSize:CGSizeMake(textView.frame.size.width, 2000) //very large height
								lineBreakMode:UILineBreakModeWordWrap];
	CGRect frame = textView.frame;
	frame. size.height = size.height + 4*margin;
	textView.frame = frame;
	
	//adjust content size of scroll view
	UIScrollView *pageContentsScrollView = (UIScrollView*)[pageView viewWithTag:10];
	pageContentsScrollView.contentSize = CGSizeMake(pageContentsScrollView.frame.size.width, frame.origin.y + frame.size.height);
	
	pageContentsScrollView.scrollEnabled = NO; //initially disable scroll
	
	// finally adjust pageView frame
	frame = pageView.frame;
	frame.size.height = 420; 
	pageView.frame = frame; 
	
	return pageView;
}


- (NSString *)pageScrollView:(HGPageScrollView *)scrollView titleForPageAtIndex:(NSInteger)index;  
{
	return ((MyPageData*)[_myPageDataArray objectAtIndex:index]).title;
}

- (NSString *)pageScrollView:(HGPageScrollView *)scrollView subtitleForPageAtIndex:(NSInteger)index;  
{
	return ((MyPageData*)[_myPageDataArray objectAtIndex:index]).subtitle;
}



#pragma mark - 
#pragma mark HGPageScrollViewDelegate

- (void)pageScrollView:(HGPageScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index;
{
	//enable scroll on our MyPageView's scrollView, now that the pageScrollView is not visible
	HGPageView *page = [scrollView pageAtIndex:index];
	UIScrollView *scrollContentView = (UIScrollView*)[page viewWithTag:10];
	scrollContentView.scrollEnabled = YES;
	
}

- (void)pageScrollView:(HGPageScrollView *)scrollView willDeselectPageAtIndex:(NSInteger)index;
{
	//disable scroll of the contents page to avoid conflict with horizonal scroll of the pageScrollView
	HGPageView *page = [scrollView pageAtIndex:index];
	UIScrollView *scrollContentView = (UIScrollView*)[page viewWithTag:10];
	scrollContentView.scrollEnabled = NO;
}



- (IBAction) didClickBrowsePages : (id) sender
{
	if(pageScrollView.viewMode == HGPageScrollViewModePage){  
		[pageScrollView deselectPageAnimated:YES];
	}
	else {
		[pageScrollView selectPageAtIndex:[pageScrollView indexForSelectedPage] animated:YES];
	}
	
	
}



@end

