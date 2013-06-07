# Page Scroll View.#

An extension of iOS UIScrollView that allows scrolling of multiple pages, like mobile Safari tab viewer. 

HGPageScrollView uses a similar methodology to UITableView. It defines both a **dataSource** and a **delegate**, which its client can implement. At the very least HGPageScrollView expects its dataSource to provide **HGPageViews** to display. 

Like UITableView, HGPageScrollView provides a way to improve performance by reusing pages. It maintains a queue of pages that the data source has marked for reuse. A page is marked for reuse by assigning a value to its *reuseIdentifier*.             
 
![](https://github.com/100grams/HGPageScrollView/raw/master/Screenshots/HGPageScrollView_Screen_shot_1.png) 
![](https://github.com/100grams/HGPageScrollView/raw/master/Screenshots/HGPageScrollView_Screen_shot_2.png)

## Features ##

### Scrolling horizontally through multiple views 
In its basic form, HGPageScrollView shows a stack of pages, horizontally scrollable when in DECK mode (see *Selection / Deselection* below), where each page is a single view derived from HGPageView. The view itself is created by the data source and must be provided to HGPageScrollView in *pageScrollView:viewForPageAtIndex:*. 

### Selection / Deselection of views (aka View Modes)  
HGPageScrollView has two distinct view modes: 

1. *HGPageScrollViewModePage*, in which  the (selected) page is shown in full screen, along with its title header view. 
2. *HGPageScrollViewModeDeck*, in which pages can be scrolled horizontally. In this mode each page is scaled down to 60% of its original size.

Moving between the two view modes is implicit and occurs after calling *selectPageAtIndex:animated:* and *deselectPageAnimated:*.     

### Custom Page Headers
HGPageScrollView data source can provide custom header views to replace the default ones (seen in the exaple). A Header view is expected to have a title and a subtitle labels. The customization refers to the look and feel (size, colors etc.) of the header view.  

### Events 
HGPageScrollView provides events to its delegate on scrolling, dragging selection and deselection of pages. 

### Advanced View Hierarchy (in combination with UINavigationController)
A more advanced use case, also demonstrated in this sample project, is when the page added to the page scroller actually belongs to a viewController which is part of a UINavigationController navigation stack.  Doing so allows to create a rich and powerful view-hierarchy.

### Inserting / Deleting / Reloading pages  
HGPageScrollView supports insertion, deletion and reloading of one or more pages:

- (void)insertPagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated;

- (void)deletePagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated; 

- (void)reloadPagesAtIndexes:(NSIndexSet *)indexes;
 
Animating page insertion/deletion will only take effect if it is done within the visible page range.     

  
## Requirements ##

- iOS 4.3 or later (Original sample project was created with Xcode 3.2.6, iOS SDK 4.3 GM Seed)
EDIT 9 May 2012: added compatibility with iOS 5.1.  

## Usage ##

Import HGPageScrollView folder into your project. 
 
In your ViewController's initialization code, e.g. in <code>viewDidLoad</code>, instantiate HGPageScrollView from its associated NIB file, as follows:  

<blockquote><code>
<p> HGPageScrollView *pageScrollView = [[[NSBundle mainBundle] loadNibNamed:@"HGPageScrollView" owner:self options:nil] objectAtIndex:0];</p>
<p>[self.view addSubview:pageScrollView];</p></code> 
</blockquote>


Declare your view controller as <code>HGPageScrollViewDataSource</code> and optionally as <code>HGPageScrollViewDelegate</code> implement at the very least the required method in this protocol: <code>pageScrollView:viewForPageAtIndex:</code>    

You can extend HGPageView by deriving from it, or as shown in the sample project, define your custom view.xib and set it's top level item to be HGPageView class. Then simply load your view using NSBundle's <code>loadFromNib:owner:options</code>. Make sure to define a **reuseIdentifier** for your view in order to improve performance.   


## Known limitations ##

- Does not support landscape orientation. If you're up for the challenge of adding this support, let me know... 
 

## License ##

HGPageScrollView is released under MIT License.

Please report bugs/issues to help improve this code. 

Any suggestions and/or code to help improve this source will be much appreciated.

Thanks!

[![endorse](https://api.coderwall.com/rubnov/endorsecount.png)](https://coderwall.com/rubnov)

Did you find this project helpful? Please endorse me... (It's free)
