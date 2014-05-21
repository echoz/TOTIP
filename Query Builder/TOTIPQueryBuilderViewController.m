//
//  TOTIPQueryBuilderViewController.m
//  TOTIP
//
//  Created by Jeremy Foo on 19/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPQueryBuilderViewController.h"
#import "TOTIPOptionsViewController.h"
#import "TOTIPOptionsSummaryViewController.h"

@interface TOTIPQueryBuilderViewController () <TOTIPOptionsViewControllerDelegate, TOTIPOptionsSummaryViewControllerDelegate>
@property (nonatomic, strong) TOTIPOptionsViewController *countryOption;
@property (nonatomic, strong) TOTIPOptionsViewController *mediaTypeOption;
@property (nonatomic, strong) TOTIPOptionsViewController *feedTypeOption;
@property (nonatomic, strong) TOTIPOptionsViewController *limitOption;
@property (nonatomic, strong) TOTIPOptionsViewController *genreOption;
@property (nonatomic, strong) TOTIPOptionsViewController *explicitOption;
@end

@implementation TOTIPQueryBuilderViewController

-(instancetype)initWithCountries:(NSArray *)countries mediaTypes:(NSArray *)mediaTypes localizationMap:(NSDictionary *)localizationMap {
    if (([countries count] == 0) || ([mediaTypes count] == 0)) return nil;
    
    // build initial root view controller
    NSMutableDictionary *countriesKeyValueMap = [NSMutableDictionary dictionaryWithCapacity:[countries count]];
    for (TOTIPCountry *country in countries) {
        if (!country.translationKey) continue;
        id key = [localizationMap valueForKeyPath:[NSString stringWithFormat:@"common.feed_country.%@", country.translationKey]];
        if (!key) continue;
        [countriesKeyValueMap setObject:country.countryCode forKey:key];
    }
    
    TOTIPOptionsViewController *countryOption = [[TOTIPOptionsViewController alloc] initWithKeyValueMap:countriesKeyValueMap];
    
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    NSString *localizedCountryCodeKey = [localizationMap valueForKeyPath:[NSString stringWithFormat:@"common.feed_country.%@", [countryCode lowercaseString]]];

    NSUInteger countryIndex = [countryOption.keys indexOfObject:localizedCountryCodeKey];
    countryOption.initialIndexPath = (countryIndex == NSNotFound) ? nil : [NSIndexPath indexPathForRow:countryIndex inSection:0];
    
    if ((self = [super initWithRootViewController:countryOption])) {
        self.countryOption = countryOption;
        self.countryOption.title = [localizationMap valueForKeyPath:@"common.Country"];
        self.countryOption.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeButtonTapped)];
        self.countryOption.delegate = self;

        _countries = countries;
        _mediaTypes = mediaTypes;
        _localizationMap = localizationMap;
    }
    return self;
}

#pragma mark - Button Events

-(void)closeButtonTapped {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)resetButtonTapped {
    [self popToRootViewControllerAnimated:YES];
}

#pragma mark - Options View Controller

-(void)optionsViewController:(TOTIPOptionsViewController *)optionsViewController didSelectKey:(id<NSCopying>)key value:(id)value {
    if (optionsViewController == self.countryOption) {
        // we got the selected option for the country!
        _selectedCountry = [[self.countries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"countryCode == %@", value]] lastObject];
        
        // setup next option
        NSArray *enabledMediaTypes = [self.mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"store IN %@", self.selectedCountry.stores]];
        NSMutableDictionary *mediaTypesKeyValueMap = [NSMutableDictionary dictionaryWithCapacity:[enabledMediaTypes count]];
        for (TOTIPMediaType *mediaType in enabledMediaTypes) {
            if (!mediaType.translationKey) continue;
            id key = [self.localizationMap valueForKeyPath:[NSString stringWithFormat:@"media-types.%@", mediaType.translationKey]];
            if (!key) continue;
            [mediaTypesKeyValueMap setObject:mediaType.identifier forKey:key];
        }

        self.mediaTypeOption = [[TOTIPOptionsViewController alloc] initWithKeyValueMap:mediaTypesKeyValueMap];
        self.mediaTypeOption.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped)];
        self.mediaTypeOption.title = [self.localizationMap valueForKeyPath:@"common.Media_Type"];
        self.mediaTypeOption.delegate = self;
        
        [self pushViewController:self.mediaTypeOption animated:YES];
    }
    
    if (optionsViewController == self.mediaTypeOption) {
        _selectedMediaType = [[self.mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", value]] lastObject];
        
        NSMutableDictionary *availableFeedTypes = [NSMutableDictionary dictionaryWithCapacity:[self.selectedMediaType.feedTypesURL count]];
        for (NSString *translationKey in self.selectedMediaType.feedTypesURL) {
            id key = [self.localizationMap valueForKeyPath:[NSString stringWithFormat:@"media-types.%@", translationKey]];
            if (!key) continue;
            [availableFeedTypes setObject:translationKey forKey:key];
        }
        
        self.feedTypeOption = [[TOTIPOptionsViewController alloc] initWithKeyValueMap:availableFeedTypes];
        self.feedTypeOption.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped)];
        self.feedTypeOption.title = [self.localizationMap valueForKeyPath:@"common.Feed_Type"];
        self.feedTypeOption.delegate = self;
        
        [self pushViewController:self.feedTypeOption animated:YES];
    }
    
    if (optionsViewController == self.feedTypeOption) {
        _selectedFeedType = value;
        
        self.limitOption = [[TOTIPOptionsViewController alloc] initWithKeyValueMap:@{@(10): @"10", @(25): @"25", @(50): @"50", @(100): @"100", @(300): @"300"}];
        self.limitOption.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped)];
        self.limitOption.title = [self.localizationMap valueForKeyPath:@"common.Size"];
        self.limitOption.delegate = self;
        
        [self pushViewController:self.limitOption animated:YES];
    }
    
    if (optionsViewController == self.limitOption) {
        _selectedLimit = [value integerValue];
        
        NSMutableDictionary *availableGenres = [NSMutableDictionary dictionaryWithCapacity:[self.selectedMediaType.genres count]];
        for (NSString *translationKey in self.selectedMediaType.genres) {
            id key = [self.localizationMap valueForKeyPath:[NSString stringWithFormat:@"media-types.%@", translationKey]];
            if (!key) continue;
            [availableGenres setObject:[self.selectedMediaType.genres objectForKey:translationKey] forKey:key];
        }
        
        self.genreOption = [[TOTIPOptionsViewController alloc] initWithKeyValueMap:availableGenres];
        self.genreOption.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped)];
        self.genreOption.title = [self.localizationMap valueForKeyPath:@"common.Genre"];
        self.genreOption.delegate = self;
        
        [self pushViewController:self.genreOption animated:YES];

    }
    
    if (optionsViewController == self.genreOption) {
        _selectedGenre = value;
        
        if (self.selectedMediaType.canBeExplicit) {
            self.explicitOption = [[TOTIPOptionsViewController alloc] initWithKeyValueMap:@{@"Yes": @(YES), @"No": @(NO)}];
            self.explicitOption.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped)];
            self.explicitOption.title = [self.localizationMap valueForKeyPath:@"media-types.Explicit_Content"];
            self.explicitOption.delegate = self;
            
            [self pushViewController:self.explicitOption animated:YES];
        } else {
            [self showOptionsSummary];
        }
    }
    
    if (optionsViewController == self.explicitOption) {
        _selectedExplicit = [value boolValue];
        [self showOptionsSummary];
    }
}

#pragma mark - Options Summary

-(void)didConfirmSummaryForOptionsSummary:(TOTIPOptionsSummaryViewController *)summaryViewController {
    if (![self.delegate respondsToSelector:@selector(didCompleteQueryBuilder:)]) return;
    [self.delegate didCompleteQueryBuilder:self];
}

-(void)didCancelSummaryForOptionsSummary:(TOTIPOptionsSummaryViewController *)summaryViewController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)showOptionsSummary {
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:@{[self.localizationMap valueForKeyPath:@"common.Country"]: [self.localizationMap valueForKeyPath:[NSString stringWithFormat:@"common.feed_country.%@", self.selectedCountry.translationKey]],
                                                                                   [self.localizationMap valueForKeyPath:@"common.Media_Type"]: [self.localizationMap valueForKeyPath:[NSString stringWithFormat:@"media-types.%@", self.selectedMediaType.translationKey]],
                                                                                   [self.localizationMap valueForKeyPath:@"common.Feed_Type"]: [self.localizationMap valueForKeyPath:[NSString stringWithFormat:@"media-types.%@", self.selectedFeedType]],
                                                                                   [self.localizationMap valueForKeyPath:@"common.Size"]: [NSString stringWithFormat:@"%d", self.selectedLimit]}];
    
    NSString *genreTranslationKey = [[self.selectedMediaType.genres allKeysForObject:self.selectedGenre] lastObject];
    if (genreTranslationKey)
        [options setObject:[self.localizationMap valueForKeyPath:[NSString stringWithFormat:@"media-types.%@", genreTranslationKey]] forKey:[self.localizationMap valueForKeyPath:@"common.Genre"]];
    
    if (self.selectedMediaType.canBeExplicit)
        [options setObject:[self.localizationMap valueForKeyPath:(self.selectedExplicit) ? @"common.Yes" : @"common.No"] forKey:[self.localizationMap valueForKeyPath:@"media-types.Explicit_Content"]];
    
    TOTIPOptionsSummaryViewController *optionsSummary = [[TOTIPOptionsSummaryViewController alloc] initWithTitle:@"Options Summary" optionsSummary:options];
    optionsSummary.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped)];
    optionsSummary.delegate = self;
    
    [self pushViewController:optionsSummary animated:YES];

}

@end
