//
//  TOTIPDetailViewController.h
//  TOTIP
//
//  Created by Jeremy Foo on 20/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOTIPEntry.h"

@interface TOTIPDetailViewController : UIViewController

@property (nonatomic, readonly, strong) TOTIPEntry *entry;

-(instancetype)initWithEntry:(TOTIPEntry *)entry;

@end
