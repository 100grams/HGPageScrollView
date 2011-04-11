//
//  MyTableViewController.h
//  HGPageScrollViewSample
//
//  Created by Rotem Rubnov on 6/4/2011.
//  Copyright 2011 100 grams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageHeaderInfo.h"


@interface MyTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PageHeaderInfo> {
    
    IBOutlet UITableView *_tableView; 

    NSArray     *_days;
    NSArray     *_daysSubtitles;
}

@end
