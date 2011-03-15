//
//  MyPageView.m
//  HGPageScrollViewSample
//
//  Created by Rotem Rubnov on 15/3/2011.
//  Copyright 2011 TomTom. All rights reserved.
//

#import "MyPageView.h"


@implementation MyPageView

@synthesize isInitialized;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

@end
