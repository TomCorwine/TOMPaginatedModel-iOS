//
//  TOMModel.m
//  TOMPaginatedModel
//
//  Created by Tom Corwine on 2/28/13.
//

#import "TOMModel.h"

@implementation TOMModel

+ (NSMutableDictionary *)cache
{
	static NSMutableDictionary *dictionary = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dictionary = @{}.mutableCopy;
	});
	return dictionary;
}

+ (NSTimeInterval)ttlForCachedResults
{
	return 20;
}

+ (NSTimeInterval)ttlForRefreshedResults
{
	return 5;
}

+ (NSUInteger)numberOfItemsPerPage
{
	return 20;
}

+ (void)fetchItemsFromServerForPage:(NSUInteger)page infoDictionary:(NSDictionary *)infoDictionary completionBlock:(TOMPaginatedModelResultsCompletionBlock)completionBlock
{
	NSLog(@"Page: %d", page);
	NSUInteger itemsPerPage = [self numberOfItemsPerPage];
	NSUInteger startingIndex = (page - 1) * itemsPerPage;
	NSUInteger endingIndex = startingIndex + itemsPerPage;
	NSMutableArray *mutableArray = @[].mutableCopy;
	for (NSUInteger index = startingIndex; index < endingIndex; index++)
	{
		[mutableArray addObject:@(index)];
		NSLog(@"Index: %d", index);
	}
	NSArray *array = [NSArray arrayWithArray:mutableArray];
	if (completionBlock)
		completionBlock(array);
}

@end
