//
//  TOPTIPCountry.m
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOPTIPCountry.h"
#import "AFNetworking.h"

@interface TOPTIPCountry ()
@property (nonatomic, copy) NSString *translationKey;
@property (nonatomic, copy) NSString *flagIcon;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *region;

@end

#define URL_COUNTRIES       [NSURL URLWithString:@"http://rss.itunes.apple.com/data/countries.json"]
#define JSON_COUNTRIES      @"countries.json"

@implementation TOPTIPCountry

-(void)updateWithJSON:(NSDictionary *)json {
    [super updateWithJSON:json];
    _enabled = [[json valueForKeyPath:@"enabled"] boolValue];
    
    NSMutableSet *stores = [NSMutableSet setWithCapacity:7];
    NSDictionary *storesObject = [json valueForKeyPath:@"stores"];
    for (NSString *store in storesObject) {
        if (![[storesObject objectForKey:stores] boolValue]) continue;
        [stores addObject:store];
    }
    
    _stores = stores;
}

+(NSDictionary *)mappedProperties {
    return @{@"country_code": @"countryCode",
             @"language": @"language",
             @"region": @"region",
             @"flag_icon": @"flagIcon",
             @"translation_key": @"translationKey"};
}

#pragma mark - Static

static NSArray *__countries = nil;
static dispatch_queue_t countriesUpdateQueue;

+(void)load {
    __countries = [TOPTIPCountry objectsWithJSONArray:LoadJSONFile(JSON_COUNTRIES)];
    countriesUpdateQueue = dispatch_queue_create("co.lazylabs.TOTIP.countries", NULL);
}

+(NSArray *)availableCountries {
    return __countries;
}

+(void)updateAvailableCountriesWithCompletion:(void (^)(NSArray *, NSError *))completion {
    AFHTTPRequestOperation *countriesRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:URL_COUNTRIES]];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"application/json", @"text/json", @"text/javascript", nil];
    
    countriesRequestOperation.responseSerializer = responseSerializer;
    [countriesRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        __countries = [TOPTIPCountry objectsWithJSONArray:responseObject];
        WriteJSONFile(responseObject, JSON_COUNTRIES);
        (completion) ? dispatch_async(dispatch_get_main_queue(), ^{ completion(__countries, nil); }) : nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        (completion) ? dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, error); }) : nil;
    }];
    countriesRequestOperation.completionQueue = countriesUpdateQueue;
    [countriesRequestOperation start];
}

@end
