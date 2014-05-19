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
    
}

@end
