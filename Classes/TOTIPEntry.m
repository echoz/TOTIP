//
//  TOTIPEntry.m
//  TOTIP
//
//  Created by Jeremy Foo on 19/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPEntry.h"

@interface TOTIPEntry ()
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSURL *entryURL;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;

@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *categoryID;

@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) NSString *costString;
@property (nonatomic, assign) double price;

@property (nonatomic, copy) NSString *rentalCurrency;
@property (nonatomic, copy) NSString *rentalCostString;
@property (nonatomic, assign) double rentalPrice;

@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSURL *artistURL;
@property (nonatomic, copy) NSString *publisher;
@property (nonatomic, copy) NSString *vendor;
@property (nonatomic, copy) NSString *copyright;

@property (nonatomic, copy) NSDate *releaseDate;

@property (nonatomic, copy) NSString *contentHTML;

@property (nonatomic, strong) NSDictionary *images;

@end

@implementation TOTIPEntry

+(NSDateFormatter *)utcDateStringFormatter {
    static NSDateFormatter *__dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __dateFormatter = [[NSDateFormatter alloc] init];
        [__dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [__dateFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ssZZZ"];
    });
    return __dateFormatter;
}

+(NSDictionary *)mappedProperties {
    return @{@"id.attributes.im:id": @"identifier",
             @"im:name.label": @"name",
             @"title.label": @"title",
             @"summary.label": @"summary",
             @"category.attributes.term": @"category",
             @"category.attributes.im:id": @"categoryID",
             @"im:price.attributes.currency": @"currency",
             @"im:price.label": @"costString",
             @"im:rentalPrice.attributes.currency": @"rentalCurrency",
             @"im:rentalPrice.label": @"rentalCostString",
             @"im:artist.label": @"artist",
             @"im:publisher.label": @"publisher",
             @"im:vendorName.label": @"vendor",
             @"rights.label": @"copyright"};
}

-(void)updateWithJSON:(NSDictionary *)json {
    [super updateWithJSON:json];
    
    _price = [[json valueForKeyPath:@"im:price.attributes.amount"] doubleValue];
    _rentalPrice = [[json valueForKeyPath:@"im:rentalPrice.attributes.amount"] doubleValue];
    _entryURL = [NSURL URLWithString:[json valueForKeyPath:@"id.label"]];
    _artistURL = [NSURL URLWithString:[json valueForKeyPath:@"im:artist.attributes.href"]];

    _releaseDate = [[[self class] utcDateStringFormatter] dateFromString:[json valueForKeyPath:@"im:releaseDate.label"]];
    
    NSMutableDictionary *imageDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    for (NSDictionary *imageDict in [json valueForKeyPath:@"im:image"]) {
        NSString *height = [imageDict valueForKeyPath:@"attributes.height"];
        if (!height) continue;
        
        NSURL *imageURL = [NSURL URLWithString:[imageDict valueForKeyPath:@"label"]];
        if (!imageURL) continue;
        
        [imageDictionary setObject:imageURL forKey:@([height doubleValue])];
    }
    
    _images = imageDictionary;
}

@end
