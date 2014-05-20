//
//  TOTIPQueryBuilderViewController.h
//  TOTIP
//
//  Created by Jeremy Foo on 19/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOTIPCountry.h"
#import "TOTIPMediaType.h"

@class TOTIPQueryBuilderViewController;

@protocol TOTIPQueryBuilderViewControllerDelegate <NSObject>
@required
-(void)didCompleteQueryBuilder:(TOTIPQueryBuilderViewController *)controller;
@end

@interface TOTIPQueryBuilderViewController : UINavigationController
@property (nonatomic, weak) id<TOTIPQueryBuilderViewControllerDelegate> delegate;

@property (nonatomic, copy, readonly) NSArray *countries;
@property (nonatomic, copy, readonly) NSArray *mediaTypes;
@property (nonatomic, copy, readonly) NSDictionary *localizationMap;

@property (nonatomic, strong, readonly) TOTIPCountry *selectedCountry;
@property (nonatomic, strong, readonly) TOTIPMediaType *selectedMediaType;
@property (nonatomic, copy, readonly) NSString *selectedFeedType;
@property (nonatomic, copy, readonly) NSString *selectedGenre;
@property (nonatomic, assign, readonly) BOOL selectedExplicit;
@property (nonatomic, assign, readonly) NSUInteger selectedLimit;

-(instancetype)initWithCountries:(NSArray *)countries mediaTypes:(NSArray *)mediaTypes localizationMap:(NSDictionary *)localizationMap;

@end
