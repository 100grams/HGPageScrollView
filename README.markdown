# Page Scroll View.#

An extension of iOS UIScrollView that allows scrolling of multiple pages, like mobile Safari tab viewer. 

HGPageScrollView uses a similar methodology to UITableView. It defines both a **dataSource** and a **delegate**, which its client can implement. At the very least HGPageScrollView expects its dataSource to provide **HGPageViews** to display. 

Like UITableView, HGPageScrollView provides a way to improve performance by reusing pages. It maintains a queue of pages that the data source has marked for reuse. A page is marked for reuse by assigning a value to its *reuseIdentifier*.             

![](https://github.com/100grams/HGPageScrollView/raw/master/Screenshots/HGPageScrollView_Screen_shot_1.png) 
![](http://github.com/100grams/HGPageScrollView/raw/master/Screenshots/HGPageScrollView_Screen_shot_2.png)



## Requirements ##

- iOS 4.3 or later (Sample project was created with Xcode 3.2.6, iOS SDK 4.3 GM Seed)

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

- Does not support landscape orientation
 

## License ##

HGPageScrollView is released under MIT License.

Please report bugs/issues to help improve this code. 

Any suggestions and/or code to help improve this source will be much appreciated.

Thanks!  