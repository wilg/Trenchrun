#import "MocoDriverStatusValueTransformer.h"
#import "MocoDriver.h"

@implementation MocoDriverStatusValueTransformer


+ (void) initialize
{
    [NSValueTransformer setValueTransformer:[[self alloc] init] forName:@"MocoDriverStatusValueTransformer"];
}

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
    return (value == nil) ? nil : [[MocoDriver statusDescriptionForStatusCode:[value intValue]] uppercaseString];
}


@end
