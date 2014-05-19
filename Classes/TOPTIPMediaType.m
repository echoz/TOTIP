//
//  TOPTIPMediaType.m
//  TOTIP
//
//  Created by Jeremy Foo on 18/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOPTIPMediaType.h"

@interface TOPTIPMediaType ()
@property (nonatomic, copy) NSString *translationKey;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *store;

@end

@implementation TOPTIPMediaType

-(void)updateWithJSON:(NSDictionary *)json {
    [super updateWithJSON:json];
    
    _canBeExplicit = [[json valueForKeyPath:@"canBeExplicit"] boolValue];
    
    NSArray *feedTypes = [json valueForKeyPath:@"feed_types"];
    NSMutableDictionary *feedTypesMap = [NSMutableDictionary dictionaryWithCapacity:[feedTypes count]];
    for (NSDictionary *feed in feedTypes)
        [feedTypesMap setObject:[feed valueForKeyPath:@"urlPrefix"] forKey:[feed valueForKeyPath:@"translation_key"]];

    _feedTypesURL = feedTypesMap;
    
    NSArray *subgenres = [json valueForKeyPath:@"subgenres"];
    NSMutableDictionary *genres = [NSMutableDictionary dictionaryWithCapacity:[subgenres count]];
    for (NSDictionary *genre in subgenres)
        [genres setObject:[genre valueForKeyPath:@"id"] forKey:[genre valueForKeyPath:@"translation_key"]];
    
    _genres = genres;
}

+(NSDictionary *)mappedProperties {
    return @{@"store": @"store",
             @"id": @"identifier",
             @"translation_key": @"translationKey"};
}

@end
