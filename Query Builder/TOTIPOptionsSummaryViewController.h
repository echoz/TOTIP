//
//  TOTIPSummaryViewController.h
//  TOTIP
//
//  Created by Jeremy Foo on 20/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOTIPOptionsSummaryViewController;

@protocol TOTIPOptionsSummaryViewControllerDelegate <NSObject>
@required
-(void)didConfirmSummaryForOptionsSummary:(TOTIPOptionsSummaryViewController *)summaryViewController;
-(void)didCancelSummaryForOptionsSummary:(TOTIPOptionsSummaryViewController *)summaryViewController;
@end

@interface TOTIPOptionsSummaryViewController : UIViewController
@property (nonatomic, weak) id<TOTIPOptionsSummaryViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString *summaryTitle;
@property (nonatomic, copy) NSDictionary *optionsSummaryMap;

-(instancetype)initWithTitle:(NSString *)title optionsSummary:(NSDictionary *)optionsSummary;

@end
