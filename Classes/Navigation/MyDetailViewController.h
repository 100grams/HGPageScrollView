//
//  MyDetailViewController.h
//  HGPageScrollViewSample
//
//  Created by Rotem Rubnov on 6/4/2011.
//  Copyright 2011 100 grams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageHeaderInfo.h"

@class HGPageView; 

@interface MyDetailViewController : UIViewController <PageHeaderInfo>{
    
    IBOutlet UILabel     *_titleLabel;
    IBOutlet UITextView  *_textView; 
    IBOutlet UIImageView *_imageView;  
}

@property (nonatomic, retain) NSString *subtitle; 
@property (nonatomic, retain) UIImage  *image; 


@end
