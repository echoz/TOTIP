//
//  TOTIPDetailViewController.m
//  TOTIP
//
//  Created by Jeremy Foo on 20/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPDetailViewController.h"
#import "TOTIPEntryView.h"

@interface TOTIPDetailViewController ()

@end

@implementation TOTIPDetailViewController

-(instancetype)initWithEntry:(TOTIPEntry *)entry {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _entry = entry;
    }
    return self;
}

-(void)loadView {
    self.view = [[TOTIPEntryView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

-(void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.000];
}

@end
