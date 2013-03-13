//
//  TOMPaginatedModelTests.m
//  TOMPaginatedModelTests
//
//  Created by Tom Corwine on 2/21/13.
//

#import "TOMPaginatedModelTests.h"

#import "TOMModel.h"

@implementation TOMPaginatedModelTests

- (void)setUp
{
    [super setUp];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void)testIndividualItem
{
	[TOMModel itemAtIndex:45 forceRefresh:NO infoDictionary:nil completionBlock:^(id item){
		NSNumber *number = item;
		STAssertTrue([number isKindOfClass:[NSNumber class]], @"Array does not contain a NSNumber object.");
		STAssertTrue(number.integerValue == 45, @"Incorrect item returned. Expecting 45, got %d", number.integerValue);
	}];
}

- (void)testPage1
{
	[self range:NSMakeRange(0, 20)];
}

- (void)testPage2
{
	[self range:NSMakeRange(20, 20)];
}

- (void)testPage3
{
	[self range:NSMakeRange(100, 100)];
}

- (void)testQuantity
{
	// There should be 219 items after testPage3 was run.
	NSUInteger numberOfItems = [TOMModel numberOfItems];
	STAssertTrue(numberOfItems == 220, @"Incorrect number of items. Expecting 220, got %d", numberOfItems);
}

#pragma mark - Helpers

- (void)range:(NSRange)range
{
	NSLog(@"TestRange: %d:%d", range.location, range.length);
	[TOMModel itemsInRange:range forceRefresh:NO infoDictionary:nil completionBlock:^(NSArray *array){
		for (NSInteger index = range.location; index < range.length; index++)
		{
			NSNumber *number = array[index];
			STAssertTrue([number isKindOfClass:[NSNumber class]], @"Array does not contain a NSNumber object.");
			STAssertTrue(number.integerValue == index, @"Incorrect item returned. Expecting %d, got %d", index, number.integerValue);
			STAssertTrue(array.count == range.length, @"Incorrect number of items. Expecting %d, get %d.", range.length, array.count);
		}
	}];
}

@end
