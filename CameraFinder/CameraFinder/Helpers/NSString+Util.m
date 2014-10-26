//
//  NSString+Util.m
//  UPNPCameraDetection
//
//  Created by Nikolas Burk on 12/4/13.
//  Copyright (c) 2013 Cameramanager. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)

- (BOOL)containsString:(NSString *)string caseSensitive:(BOOL)caseSensitive
{
    NSStringCompareOptions options = caseSensitive ? NSLiteralSearch : NSCaseInsensitiveSearch;
    NSRange range = [self rangeOfString:string options:options];
    return range.location != NSNotFound;
}

- (BOOL)startsWith:(NSString *)prefix
{
    if ([self length] > 0)
    {
        NSString *compareString = [self substringToIndex:[prefix length]];
        //NSLog(@"%@ ----- %@", compareString, prefix);
        return [compareString isEqualToString:prefix];
    }
    return NO;
}

- (BOOL)containsCharactersInSet:(NSCharacterSet *)set
{
    NSRange foundRange = [self rangeOfCharacterFromSet:set options:0];
    return foundRange.location != NSNotFound;
}

- (BOOL)endsWith:(NSString *)suffix
{
    if ([self length] > 0)
    {
        NSString *compareString = [self substringFromIndex:[self length]-[suffix length]];
        //NSLog(@"%@ ----- %@", compareString, prefix);
        return [compareString isEqualToString:suffix];
    }
    return NO;
}

- (BOOL)endsWithNullCharacter
{
    unichar lastCharacter = [self characterAtIndex:[self length]-1];
    if (lastCharacter == 0)
    {
        return YES;
    }
    return NO;
}
    
- (NSString *)stripOffTerminatingNullCharacter
{    
    NSRange unicodeNullRange = NSMakeRange(0, 20); // include only the null character
    NSCharacterSet *nullSet = [NSCharacterSet characterSetWithRange:unicodeNullRange];
    
    NSString *newSelf = [self removeCharactersInSet:nullSet];

    return newSelf;
}

- (NSString *)removeCharactersInSet:(NSCharacterSet *)characterSet
{
    NSString *newSelf = [self stringByTrimmingCharactersInSet:characterSet];
    return newSelf;
}

- (NSString *)stringByStrippingHTML
{
//    NSLog(@"RAW: %@", self);
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
//    NSLog(@"STRIPPED: %@", s);
    return s;
}

@end
