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
    for (TOTIPCountry *country in countries)
        [countriesKeyValueMap setObject:country.countryCode forKey:[localizationMap valueForKeyPath:country.translationKey]];
    
    TOTIPOptionsViewController *countryOption = [[TOTIPOptionsViewController alloc] initWithKeyValueMap:countriesKeyValueMap];
    
    if ((self = [super initWithRootViewController:countryOption])) {
        self.countryOption = countryOption;
        self.countryOption.title = [localizationMap objectForKey:@"Country"];
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
        for (TOTIPMediaType *mediaType in enabledMediaTypes)
            [mediaTypesKeyValueMap setObject:mediaType.identifier forKey:[self.localizationMap objectForKey:mediaType.translationKey]];

        self.mediaTypeOption = [[TOTIPOptionsViewController alloc] initWithKeyValueMap:mediaTypesKeyValueMap];
        self.mediaTypeOption.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped)];
        self.mediaTypeOption.title = [self.localizationMap objectForKey:@"Media_Type"];
        self.mediaTypeOption.delegate = self;
        
        [self pushViewController:self.mediaTypeOption animated:YES];
    }
    
    if (optionsViewController == self.mediaTypeOption) {
        _selectedMediaType = [[self.mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", value]] lastObject];
        
        NSMutableDictionary *availableFeedTypes = [NSMutableDictionary dictionaryWithCapacity:[self.selectedMediaType.feedTypesURL count]];
        for (NSString *translationKey in self.selectedMediaType.feedTypesURL)
            [availableFeedTypes setObject:translationKey forKey:[self.localizationMap objectForKey:translationKey]];
        
        self.feedTypeOption = [[TOTIPOptionsViewController alloc] initWithKeyValueMap:availableFeedTypes];
        self.feedTypeOption.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped)];
        self.feedTypeOption.title = [self.localizationMap objectForKey:@"Feed_Type"];
        self.feedTypeOption.delegate = self;
        
        [self pushViewController:self.feedTypeOption animated:YES];
    }
    
    if (optionsViewController == self.feedTypeOption) {
        _selectedFeedType = value;
        
        self.limitOption = [[TOTIPOptionsViewController alloc] initWithKeyValueMap:@{@"10": @"10", @"25": @"25", @"50": @"50", @"100": @"100", @"300": @"300"}];
        self.limitOption.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped)];
        self.limitOption.title = [self.localizationMap objectForKey:@"Size"];
        self.limitOption.delegate = self;
        
        [self pushViewController:self.limitOption animated:YES];
    }
    
    if (optionsViewController == self.limitOption) {
        _selectedLimit = [value unsignedIntegerValue];
        
        NSMutableDictionary *availableGenres = [NSMutableDictionary dictionaryWithCapacity:[self.selectedMediaType.genres count]];
        for (NSString *translationKey in self.selectedMediaType.genres)
            [availableGenres setObject:[self.selectedMediaType.genres objectForKey:translationKey] forKey:[self.localizationMap objectForKey:translationKey]];
        
        self.genreOption = [[TOTIPOptionsViewController alloc] initWithKeyValueMap:availableGenres];
        self.genreOption.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped)];
        self.genreOption.title = [self.localizationMap objectForKey:@"Genre"];
        self.genreOption.delegate = self;
        
        [self pushViewController:self.genreOption animated:YES];

    }
    
    if (optionsViewController == self.genreOption) {
        _selectedGenre = value;
        
        if (self.selectedMediaType.canBeExplicit) {
            self.explicitOption = [[TOTIPOptionsViewController alloc] initWithKeyValueMap:@{@"Yes": @(YES), @"No": @(NO)}];
            self.explicitOption.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped)];
            self.explicitOption.title = [self.localizationMap objectForKey:@"Explicit_Content"];
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
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:@{[self.localizationMap objectForKey:@"Country"]: [self.localizationMap objectForKey:self.selectedCountry.translationKey],
                                                                                   [self.localizationMap objectForKey:@"Media_Type"]: [self.localizationMap objectForKey:self.selectedMediaType.translationKey],
                                                                                   [self.localizationMap objectForKey:@"Feed_Type"]: [self.localizationMap objectForKey:self.selectedFeedType],
                                                                                   [self.localizationMap objectForKey:@"Size"]: [NSString stringWithFormat:@"%d", self.selectedLimit]}];
    
    NSString *genreTranslationKey = [[self.selectedMediaType.genres allKeysForObject:self.selectedGenre] lastObject];
    if (genreTranslationKey)
        [options setObject:[self.localizationMap objectForKey:genreTranslationKey] forKey:[self.localizationMap objectForKey:@"Genre"]];
    
    if (self.selectedMediaType.canBeExplicit)
        [options setObject:[self.localizationMap objectForKey:(self.selectedExplicit) ? @"Yes" : @"No"] forKey:[self.localizationMap objectForKey:@"Explicit_Content"]];
    
    TOTIPOptionsSummaryViewController *optionsSummary = [[TOTIPOptionsSummaryViewController alloc] initWithTitle:@"Query Option Summary" optionsSummary:options];
    optionsSummary.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped)];
    optionsSummary.delegate = self;
    
    [self pushViewController:optionsSummary animated:YES];

}

@end
