//
//  TOTIPListViewController.m
//  TOTIP
//
//  Created by Jeremy Foo on 20/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPListViewController.h"
#import "TOTIPDetailViewController.h"
#import "TOTIPQueryBuilderViewController.h"
#import "TOTIPCountry.h"
#import "TOTIPMediaType.h"

#import "TOTIPEntryCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface TOTIPListViewController () <TOTIPQueryBuilderViewControllerDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) UILabel *emptyResultMessageLabel;
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
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicatorView];
    activityIndicatorView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    _activityIndicatorView = activityIndicatorView;
    
    UILabel *emptyResultMessageLabel = [[UILabel alloc] init];
    emptyResultMessageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f];
    emptyResultMessageLabel.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
    [self.view addSubview:emptyResultMessageLabel];
    _emptyResultMessageLabel = emptyResultMessageLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"TOTIP";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(queryBuilderTapped)];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.000];
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
                [self.activityIndicatorView stopAnimating];
                self.navigationItem.leftBarButtonItem.enabled = YES;
                if (!self.currentQuery) [self queryBuilderTapped];
            });
        });
    };
    
    [self.activityIndicatorView startAnimating];
    
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
    self.currentQuery = nil;
    [self.collectionView reloadData];
    [self.activityIndicatorView startAnimating];
    
    self.currentQuery = [[TOTIPQuery alloc] initWithCountry:controller.selectedCountry type:controller.selectedMediaType feedType:controller.selectedFeedType genre:controller.selectedGenre limit:controller.selectedLimit];
    self.currentQuery.explicitContent = controller.selectedExplicit;
    [self.currentQuery performQueryWithCompletion:^(NSArray *results, NSError *error) {
        [self.activityIndicatorView stopAnimating];
        self.title = ([self.localizationMap valueForKeyPath:[NSString stringWithFormat:@"media-types.%@", controller.selectedFeedType]]) ?: controller.selectedFeedType;
        [self.collectionView reloadData];
        
        self.emptyResultMessageLabel.hidden = ([results count] > 0);

        if ([results count] == 0) {
            self.emptyResultMessageLabel.text = [NSString stringWithFormat:@"Nothing in %@ :(", self.title];
            CGSize textSize = [self.emptyResultMessageLabel.text boundingRectWithSize:CGSizeMake(self.view.bounds.size.width * 0.6f, CGFLOAT_MAX)
                                                                              options:0
                                                                           attributes:@{NSFontAttributeName: self.emptyResultMessageLabel.font}
                                                                              context:nil].size;
            self.emptyResultMessageLabel.bounds = (CGRect){CGPointZero, textSize};
            self.emptyResultMessageLabel.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Collection View

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.currentQuery.results count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TOTIPEntry *entry = [self.currentQuery.results objectAtIndex:indexPath.row];
    
    TOTIPEntryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOTIPEntryCollectionViewCell class])
                                                                                   forIndexPath:indexPath];
    UIImageView *entryImageView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, self.flowLayout.itemSize}];
    entryImageView.contentMode = UIViewContentModeScaleAspectFill;
    entryImageView.clipsToBounds = YES;
    
    id bestImageKey = [[[entry.images allKeys] sortedArrayUsingSelector:@selector(compare:)] lastObject];
    [entryImageView setImageWithURL:[entry.images objectForKey:bestImageKey]];

    cell.backgroundView = entryImageView;
    
    cell.titleLabel.text = entry.title;
    cell.detailLabel.text = ([entry.artist length] > 0) ? entry.artist : entry.publisher;
    
    cell.contentInset = UIEdgeInsetsMake(self.flowLayout.itemSize.height * 0.7f, 10.0f, 5.0f, 10.0f);
    
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TOTIPEntry *entry = [self.currentQuery.results objectAtIndex:indexPath.row];
    TOTIPDetailViewController *detail = [[TOTIPDetailViewController alloc] initWithEntry:entry];
    [self.navigationController pushViewController:detail animated:YES];
}

@end
