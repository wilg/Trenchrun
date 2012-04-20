//
//  MocoTimelineHeaderViewController.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoTimelineHeaderViewController.h"
#import "MocoTimelineHeaderView.h"

@interface MocoTimelineHeaderViewController ()

@end

@implementation MocoTimelineHeaderViewController
@synthesize track;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (MocoTimelineHeaderView *)headerView {
    return (MocoTimelineHeaderView *)self.view;
}

- (void)loadView {
    [super loadView];
    
}

- (void)awakeFromNib {
//    if (self.view)
//        [self headerView].controller = self;
    

}


@end