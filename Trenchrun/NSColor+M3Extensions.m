/*****************************************************************
 NSColor+M3Extensions.m
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

#import "NSColor+M3Extensions.h"

@implementation NSColor (M3Extensions)

+ (NSColor *)colorWithHexadecimalString:(NSString *)hexCode {
	if ([hexCode rangeOfString:@"#"].location == 0) {
		hexCode = [hexCode substringFromIndex:1];
	}
	if ([hexCode length] == 3) {
		hexCode = [NSString stringWithFormat:@"%c%c%c%c%c%c", [hexCode characterAtIndex:0], [hexCode characterAtIndex:0], [hexCode characterAtIndex:1], [hexCode characterAtIndex:1], [hexCode characterAtIndex:2], [hexCode characterAtIndex:2]];
	}
	if ([hexCode length] == 6) {
		int red = [NSColor hexToInt:[hexCode substringWithRange:NSMakeRange(0, 2)]];
		int green = [NSColor hexToInt:[hexCode substringWithRange:NSMakeRange(2, 2)]];
		int blue = [NSColor hexToInt:[hexCode substringWithRange:NSMakeRange(4, 2)]];
		if (red == -1 || blue == -1 || green == -1)
			return nil;
		return [NSColor colorWithCalibratedRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
	} 
	return nil;
}

+ (int)hexToInt:(NSString *)hex {
	int returnValue = 0;
	int i;
	for (i = 0; i < [hex length]; i++) {
		NSString *letter = [[hex uppercaseString] substringWithRange:NSMakeRange(i, 1)];
		int value = [letter intValue];
		if ([letter isEqualToString:@"A"]) {
			value = 10;
		} else if ([letter isEqualToString:@"B"]) {
			value = 11;
		} else if ([letter isEqualToString:@"C"]) {
			value = 12;
		} else if ([letter isEqualToString:@"D"]) {
			value = 13;
		} else if ([letter isEqualToString:@"E"]) {
			value = 14;
		} else if ([letter isEqualToString:@"F"]) {
			value = 15;
		}
		
		//If we have an invalid character then abort
		if (value == 0 && ![letter isEqualToString:@"0"])
			return -1;
		
		returnValue += value * pow(16, ([hex length] - i) - 1);
	}
	return returnValue;
}

- (NSString *)hexadecimalString {
	int red = 0;
	int green = 0;
	int blue =  0;
	if ([[self colorSpace] isEqual:[NSColorSpace genericGrayColorSpace]]) {
		red = (int)(255 * [self whiteComponent]);
		green = (int)(255 * [self whiteComponent]);
		blue = (int)(255 * [self whiteComponent]);
	} else {
		red = (int)(255 * [self redComponent]);
		green = (int)(255 * [self greenComponent]);
		blue = (int)(255 * [self blueComponent]);
	}
	int count = 0;
	while (red > 16) {
		count++;
		red -= 16;
	}
	
	NSString *redstr = [NSString stringWithFormat:@"%@%@", [self hexForInt:count], [self hexForInt:red]];
	count = 0;
	while (green > 16) {
		count++;
		green -= 16;
	}
	
	NSString *greenstr = [NSString stringWithFormat:@"%@%@", [self hexForInt:count], [self hexForInt:green]];
	
	count = 0;
	while (blue > 16) {
		count++;
		blue -= 16;
	}
	
	NSString *bluestr = [NSString stringWithFormat:@"%@%@", [self hexForInt:count], [self hexForInt:blue]];
	return [NSString stringWithFormat:@"%@%@%@", redstr, greenstr, bluestr];;
}

- (NSString *)hexForInt:(int)integer {
	if (integer < 10) {
		return [NSString stringWithFormat:@"%d", integer];
	}
	switch (integer) {
		case 10:
			return @"A";
			break;
		case 11:
			return @"B";
			break;
		case 12:
			return @"C";
			break;
		case 13:
			return @"D";
			break;
		case 14:
			return @"E";
			break;
		case 15:
			return @"F";
			break;
	}
	return nil;
}

- (NSString *)colorToString {
	return [NSString stringWithFormat:@"%f/%f/%f/%f", [self redComponent], [self greenComponent], [self blueComponent], [self alphaComponent]];
}

+ (NSColor *)colorWithString:(NSString *)string {
	NSArray *components = [string componentsSeparatedByString:@"/"];
	return [NSColor colorWithCalibratedRed:[[components objectAtIndex:0] floatValue]
									 green:[[components objectAtIndex:1] floatValue]
									  blue:[[components objectAtIndex:2] floatValue]
									 alpha:[[components objectAtIndex:3] floatValue]];
}

- (NSColor *)lighterColourBy:(CGFloat)lighten {
	if (lighten < 0)
		return 0;
	
	CGFloat red = [self redComponent] + lighten;
	CGFloat green = [self greenComponent] + lighten;
	CGFloat blue = [self blueComponent] + lighten;
	if (red > 1) {
		green += (red-1)/2;
		blue += (red-1)/2;
	}
	if (green > 1) {
		red += (green-1)/2;
		blue += (green-1)/2;
	}
	if (blue > 1) {
		green += (blue-1)/2;
		red += (blue-1)/2;
	}
	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:[self alphaComponent]];
}

- (NSColor *)darkerColourBy:(CGFloat)darken {
	if (darken < 0)
		return 0;
	
	CGFloat red = [self redComponent] - darken;
	CGFloat green = [self greenComponent] - darken;
	CGFloat blue = [self blueComponent] - darken;
	if (red < 0) {
		green += red/2;
		blue += red/2;
	}
	if (green < 0) {
		red += green/2;
		blue += green/2;
	}
	if (blue < 0) {
		green += blue/2;
		red += blue/2;
	}
	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:[self alphaComponent]];
}

@end
