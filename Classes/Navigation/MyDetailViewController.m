//
//  MyDetailViewController.m
//  HGPageScrollViewSample
//
//  Created by Rotem Rubnov on 6/4/2011.
//  Copyright 2011 100 grams. All rights reserved.
//

#import "MyDetailViewController.h"


@implementation MyDetailViewController


@synthesize subtitle, image;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.subtitle = nil;
    self.image = nil; 
    [_titleLabel release];_titleLabel = nil;
    [_imageView release]; _imageView = nil;
    [_textView release]; _textView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLabel.text = subtitle;
    _imageView.image = image; 
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - PageScrollerHeaderInfo

- (NSString*) pageTitle
{
    return self.title;
}


- (NSString*) pageSubtitle
{
    return self.subtitle;
}


@end
