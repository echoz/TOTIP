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

@interface TOTIPListViewController () <TOTIPQueryBuilderViewControllerDelegate>

@end

@implementation TOTIPListViewController

-(void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.minimumInteritemSpacing = 10.0f;
    self.flowLayout.minimumLineSpacing = 10.0f;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    CGFloat width = (self.view.bounds.size.width - (self.flowLayout.minimumInteritemSpacing * 3)) / 2;
    self.flowLayout.itemSize = CGSizeMake(width, width);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicatorView];
    self.activityIndicatorView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"TOTIP";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(queryBuilderTapped)];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.255 alpha:1.000];
    [self.collectionView registerClass:[TOTIPEntryCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TOTIPEntryCollectionViewCell class])];
    
    void (^fetchApplicationParamters)(NSString *countryCode) = ^(NSString *countryCode) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            TOTIPCountry *currentCountry = [[[TOTIPCountry availableCountries] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"countryCode == %@", countryCode]] lastObject];
            NSString *locale = (currentCountry) ? currentCountry.language : @"en-US";

            dispatch_group_t fetchTranslationGroup = dispatch_group_create();
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
    };
    
    NSString *currentCountryCode = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];
    if ([TOTIPCountry availableCountries]) {
        fetchApplicationParamters(currentCountryCode);
        return;
    }
    
    [TOTIPCountry updateAvailableCountriesWithCompletion:^(NSArray *countries, NSError *error) {
        fetchApplicationParamters(currentCountryCode);
    }];
}

-(void)queryBuilderTapped {
    TOTIPQueryBuilderViewController *queryBuilder = [[TOTIPQueryBuilderViewController alloc] initWithCountries:[TOTIPCountry availableCountries] mediaTypes:[TOTIPMediaType availableMediaTypes] localizationMap:self.localizationMap];
    queryBuilder.delegate = self;
    [self.navigationController presentViewController:queryBuilder animated:YES completion:NULL];
}

-(void)didCompleteQueryBuilder:(TOTIPQueryBuilderViewController *)controller {
    TOTIPQuery *query = [[TOTIPQuery alloc] initWithCountry:controller.selectedCountry type:controller.selectedMediaType feedType:controller.selectedFeedType genre:controller.selectedGenre limit:controller.selectedLimit];
    query.explicitContent = controller.selectedExplicit;
    [query performQueryWithCompletion:^(NSArray *results, NSError *error) {
        NSLog(@"%@", results);
    }];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
