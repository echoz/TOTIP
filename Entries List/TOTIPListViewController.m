//
//  TOTIPListViewController.m
//  TOTIP
//
//  Created by Jeremy Foo on 20/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPListViewController.h"
#import "TOTIPQueryBuilderViewController.h"
#import "TOTIPCountry.h"
#import "TOTIPMediaType.h"

@interface TOTIPListViewController ()

@end

@implementation TOTIPListViewController

-(void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor purpleColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"TOTIP";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(queryBuilderTapped)];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_group_t fetchTranslationGroup = dispatch_group_create();
        
        NSString *locale = [[[NSLocale currentLocale] localeIdentifier] stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
        
        dispatch_group_enter(fetchTranslationGroup);
        __block NSDictionary *countryTranslation = nil;
        [TOTIPCountry fetchTranslationDictionaryForLocaleIdentifier:locale completion:^(NSDictionary *translation, NSError *error) {
            dispatch_group_leave(fetchTranslationGroup);
            countryTranslation = translation;
        }];
        
        dispatch_group_enter(fetchTranslationGroup);
        __block NSDictionary *mediaTypeTranslation = nil;
        [TOTIPMediaType fetchTranslationDictionaryForLocaleIdentifier:locale completion:^(NSDictionary *translation, NSError *error) {
            dispatch_group_leave(fetchTranslationGroup);
            mediaTypeTranslation = translation;
        }];
        
        dispatch_group_enter(fetchTranslationGroup);
        [TOTIPCountry updateAvailableCountriesWithCompletion:^(NSArray *countries, NSError *error) {
            dispatch_group_leave(fetchTranslationGroup);
        }];
        
        dispatch_group_enter(fetchTranslationGroup);
        [TOTIPMediaType updateAvailableMediaTypesWithCompletion:^(NSArray *mediaTypes, NSError *error) {
            dispatch_group_leave(fetchTranslationGroup);
        }];
        
        dispatch_group_wait(fetchTranslationGroup, DISPATCH_TIME_FOREVER);
        
        NSMutableDictionary *localizationMap = [NSMutableDictionary dictionary];
        if (mediaTypeTranslation)   [localizationMap addEntriesFromDictionary:@{@"media-types": mediaTypeTranslation}];
        if (countryTranslation)     [localizationMap addEntriesFromDictionary:@{@"common": countryTranslation}];
        
        _localizationMap = localizationMap;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem.enabled = YES;
        });
    });
}

-(void)queryBuilderTapped {
    TOTIPQueryBuilderViewController *queryBuilder = [[TOTIPQueryBuilderViewController alloc] initWithCountries:[TOTIPCountry availableCountries] mediaTypes:[TOTIPMediaType availableMediaTypes] localizationMap:self.localizationMap];
    [self.navigationController presentViewController:queryBuilder animated:YES completion:NULL];
}


@end
