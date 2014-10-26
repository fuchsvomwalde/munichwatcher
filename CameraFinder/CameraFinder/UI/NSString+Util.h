//
//  NSString+Util.h
//  UPNPCameraDetection
//
//  Created by Nikolas Burk on 12/4/13.
//  Copyright (c) 2013 Cameramanager. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)
- (BOOL)containsString:(NSString *)string caseSensitive:(BOOL)caseSensitive;
- (BOOL)startsWith:(NSString *)prefix;
- (BOOL)endsWith:(NSString *)suffix;
- (NSString *)removeCharactersInSet:(NSCharacterSet *)characterSet;
- (BOOL)containsCharactersInSet:(NSCharacterSet *)set;
- (BOOL)endsWithNullCharacter; // unicode = 0
- (NSString *)stripOffTerminatingNullCharacter; // unicode = 0
@end
