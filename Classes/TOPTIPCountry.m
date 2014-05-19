//
//  TOPTIPCountry.m
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOPTIPCountry.h"

@interface TOPTIPCountry ()
@property (nonatomic, copy) NSString *translationKey;
@property (nonatomic, copy) NSString *flagIcon;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *region;

@end

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

@end
