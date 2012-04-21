/*****************************************************************
 NSColor+M3Extensions.h
 M3Extensions
 
 Created by Martin Pilkington on 20/05/2008.
 
 Copyright (c) 2006-2009 M Cubed Software
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 *****************************************************************/

#import <Cocoa/Cocoa.h>

/**
 @category NSColor(M3Extensions)
 @discussion This category adds methods for dealing with hex strings, converting to strings for saving and lightening/darkening the colour
 */
@interface NSColor (M3Extensions) 

/**
 @abstract Creates and returns a colour from the supplied 3 or 6 character hexadeicmal string
 @discussion Accepts 3 or 6 characters hexadecimal strings, with or without a hash at the beginning
 @param hexCode The hex string
 @result A newly initialised NSColor object
 */
+ (NSColor *)colorWithHexadecimalString:(NSString *)hexCode;

/**
 @abstract Returns the hexidecimal string equivalent for the colour
 @result Returns a 6 character hexadecimal string WITHOUT a hash prefixed
 */
- (NSString *)hexadecimalString;

/**
 @abstract Converts the colour to a string for saving to a plist
 @discussion Pass the result of this string to colorWithString to get the original colour back
 @result Returns a string for the current colour in the format: red/green/blue/alpha
 */
- (NSString *)colorToString;

/**
 @abstract Creates and returns a colour from the supplied string
 @discussion Accepts strings in the format red/green/blue/alpha eg white is 1.0/1.0/1.0/1.0
 @param string The colour string
 @result A newly initialised NSColor object
 */
+ (NSColor *)colorWithString:(NSString *)string;

/**
 @abstract Creates and returns a colour that is lighten units lighter than the receiver
 @param lighten A value between 0 and 1 for how much lighter you want the colour to be
 @result A newly initialised NSColor object that is lighter than the receiver
 */
- (NSColor *)lighterColourBy:(CGFloat)lighten;

/**
 @abstract Creates and returns a colour that is darken units darker than the receiver
 @param darken A value between 0 and 1 for how much lighter you want the colour to be
 @result A newly initialised NSColor object that is darker than the receiver
 */
- (NSColor *)darkerColourBy:(CGFloat)darken;




/**
 @abstract Don't use
 */
+ (int)hexToInt:(NSString *)hex;
- (NSString *)hexForInt:(int)integer;
@end
