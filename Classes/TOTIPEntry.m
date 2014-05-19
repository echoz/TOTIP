//
//  TOTIPEntry.m
//  TOTIP
//
//  Created by Jeremy Foo on 19/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPEntry.h"

@implementation TOTIPEntry

+(instancetype)entryWithXMLEntry:(ONOXMLElement *)xmlEntry {
    TOTIPEntry *instance = [[[self class] alloc] init];
    [instance updateWithXMLEntry:xmlEntry];
    return instance;
}

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

-(void)updateWithXMLEntry:(ONOXMLElement *)xmlEntry {
    _identifier = [[[xmlEntry firstChildWithTag:@"id"] attributes] objectForKey:@"imd:id"];
    _entryURL = [NSURL URLWithString:[[xmlEntry firstChildWithTag:@"id"] stringValue]];

    _name = [[xmlEntry firstChildWithTag:@"im:name"] stringValue];
    _title = [[xmlEntry firstChildWithTag:@"title"] stringValue];
    _summary = [[xmlEntry firstChildWithTag:@"summary"] stringValue];
    
    _category = [[[xmlEntry firstChildWithTag:@"category"] attributes] objectForKey:@"term"];
    _categoryID = [[[xmlEntry firstChildWithTag:@"category"] attributes] objectForKey:@"im:id"];
    
    _currency = [[[xmlEntry firstChildWithTag:@"im:price"] attributes] objectForKey:@"currency"];
    _costString = [[xmlEntry firstChildWithTag:@"im:price"] stringValue];
    _price = [[[[xmlEntry firstChildWithTag:@"im:price"] attributes] objectForKey:@"amount"] doubleValue];

    _rentalCurrency = [[[xmlEntry firstChildWithTag:@"im:rentalPrice"] attributes] objectForKey:@"currency"];
    _rentalCostString = [[xmlEntry firstChildWithTag:@"im:rentalPrice"] stringValue];
    _rentalPrice = [[[[xmlEntry firstChildWithTag:@"im:rentalPrice"] attributes] objectForKey:@"amount"] doubleValue];
    
    _artist = [[xmlEntry firstChildWithTag:@"im:artist"] stringValue];
    _artistURL = [NSURL URLWithString:[[[xmlEntry firstChildWithTag:@"im:artist"] attributes] objectForKey:@"href"]];
    _publisher = [[xmlEntry firstChildWithTag:@"im:publisher"] stringValue];
    _vendor = [[xmlEntry firstChildWithTag:@"im:vendorName"] stringValue];
    _copyright = [[xmlEntry firstChildWithTag:@"rights"] stringValue];

    _releaseDate = [[xmlEntry firstChildWithTag:@"im:releaseDate"] dateValue];
    _lastUpdated = [[xmlEntry firstChildWithTag:@"updated"] dateValue];
    
    for (ONOXMLElement *node in [xmlEntry XPath:@"//content[@type='HTML']"]) {
        _contentHTML = [node stringValue];
        break;
    }
    
    NSMutableDictionary *imageDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    for (ONOXMLElement *imageNode in [xmlEntry XPath:@"//im:image"]) {
        NSString *height = [[imageNode attributes] objectForKey:@"height"];
        if (!height) continue;
        
        NSURL *imageURL = [NSURL URLWithString:[imageNode stringValue]];
        if (!imageURL) continue;
        
        [imageDictionary setObject:imageURL forKey:height];
    }
    
    _images = imageDictionary;
}

@end
