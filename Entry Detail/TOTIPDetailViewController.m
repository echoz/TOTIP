//
//  TOTIPDetailViewController.m
//  TOTIP
//
//  Created by Jeremy Foo on 20/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPDetailViewController.h"
#import "TOTIPEntryView.h"

#import "UIImageView+AFNetworking.h"

@interface TOTIPDetailViewController () <UIActionSheetDelegate>
@property (nonatomic, weak, readonly) TOTIPEntryView *entryView;
@end

@implementation TOTIPDetailViewController

-(instancetype)initWithEntry:(TOTIPEntry *)entry {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _entry = entry;
    }
    return self;
}

-(void)loadView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    scrollView.contentSize = [[UIScreen mainScreen] bounds].size;
    scrollView.bounces = YES;
    scrollView.scrollEnabled = YES;
    
    TOTIPEntryView *entryView = [[TOTIPEntryView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [scrollView addSubview:entryView];
    _entryView = entryView;

    self.view = scrollView;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:(([self.entry.rentalCostString length] > 0) ? self.entry.rentalCostString : self.entry.costString) style:UIBarButtonItemStylePlain target:self action:@selector(buyTapped)];
    if ([self.entry.rentalCostString length] > 0) self.navigationItem.rightBarButtonItem.tintColor = [UIColor orangeColor];
    if (self.entry.price == 0) self.navigationItem.rightBarButtonItem.tintColor = [UIColor greenColor];
        
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.000];

    id bestImageKey = [[[self.entry.images allKeys] sortedArrayUsingSelector:@selector(compare:)] lastObject];
    [self.entryView.imageView setImageWithURL:[self.entry.images objectForKey:bestImageKey]];
    
    self.entryView.titleLabel.text = self.entry.name;
    
    NSMutableAttributedString *byLineString = [[NSMutableAttributedString alloc] initWithString:self.entry.artist];
//    if (([byLineString.string length] > 0) && (self.entry.artistURL))
//        [byLineString addAttribute:NSLinkAttributeName value:self.entry.artistURL range:NSMakeRange(0, [byLineString length])];
    
    if ([self.entry.publisher length] > 0)  [byLineString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", ([byLineString length] > 0) ? @"; " : @"", self.entry.publisher]]];
    if ([self.entry.vendor length] > 0)     [byLineString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", ([byLineString length] > 0) ? @"; " : @"", self.entry.vendor]]];
    
    [byLineString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:15.0f] range:NSMakeRange(0, [byLineString length])];
    [byLineString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.802 alpha:1.000] range:NSMakeRange(0, [byLineString length])];
    
    self.entryView.byLineLabel.attributedText = byLineString;
    
    self.entryView.summaryLabel.text = self.entry.summary;
    self.entryView.categoryLabel.text = self.entry.category;
    
    self.entryView.releaseDateLabel.text = [[[self class] dateFormatter] stringFromDate:self.entry.releaseDate];    
    self.entryView.copyrightLabel.text = self.entry.copyright;
}

+(NSDateFormatter *)dateFormatter {
    static NSDateFormatter *__formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __formatter = [[NSDateFormatter alloc] init];
        __formatter.dateStyle = NSDateFormatterShortStyle;
    });
    return __formatter;
}

-(void)buyTapped {
    if (([self.entry.rentalCostString length] > 0) && ([self.entry.costString length] > 0)) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:[NSString stringWithFormat:@"Rent for %@", self.entry.rentalCostString], [NSString stringWithFormat:@"Buy for %@", self.entry.costString] , nil];
        [actionSheet showInView:self.view];
        return;
    }
    
    [[UIApplication sharedApplication] openURL:self.entry.entryURL];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) return;
    
    [[UIApplication sharedApplication] openURL:self.entry.entryURL];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [(UIScrollView *)self.view setContentSize:CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(self.entryView.copyrightLabel.frame) + 10.0f)];
}


@end
