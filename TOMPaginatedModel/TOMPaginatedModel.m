//
//  TOMPaginatedModel.m
//  TOMPaginatedModel
//
//  Created by Tom Corwine on 2/21/13.
//

#import "TOMPaginatedModel.h"

#define NSAssertMainThread NSAssert([NSThread isMainThread], @"%s must be called on main thread.", __PRETTY_FUNCTION__)

@implementation TOMPaginatedModel

+ (NSMutableDictionary *)cache
{
	NSAssert(NO, @"[%@ cache] must be overridden in child classes.", NSStringFromClass([self class]));
	return nil;
}

+ (NSUInteger)numberOfItems
{
	NSAssertMainThread;
	NSUInteger count = 0;
	for (NSNumber *key in [self cache].allKeys)
		count = (key.integerValue > count ? key.integerValue : count);
	return (count ? count + 1 : 0); // If count has some value, return that value plus one since items are zero indexed. Otherwise, return zero.
}

+ (void)itemsInRange:(NSRange)range forceRefresh:(BOOL)forceRefresh infoDictionary:(NSDictionary *)infoDictionary completionBlock:(TOMPaginatedModelResultsCompletionBlock)completionBlock
{
	NSAssertMainThread;
	static NSDate *lastFetch = nil;
	NSTimeInterval ttlForCachedResults = [self ttlForCachedResults];
	NSTimeInterval ttlForRefreshedResults = [self ttlForRefreshedResults];
	NSArray *array = [self itemsInRange:range];
	if (array.count && lastFetch && lastFetch.timeIntervalSinceNow < (forceRefresh ? ttlForRefreshedResults : ttlForCachedResults))
	{
		if (NO == [array containsObject:[NSNull null]])
		{
			if (completionBlock)
				completionBlock(array);
			// The array in cache contained all the items asked for so quit here. Otherwise, continue with network call.
			if (array.count == range.length)
			return;
		}
	}
	NSUInteger itemsPerPage = [self numberOfItemsPerPage];
	NSUInteger firstPage = (range.location / itemsPerPage) + 1;
	NSUInteger lastPage = firstPage + (range.length / itemsPerPage);
	lastFetch = [NSDate date];
	for (NSUInteger page = firstPage; page <= lastPage; page++)
	{
		[self fetchItemsFromServerForPage:page infoDictionary:infoDictionary completionBlock:^(NSArray *array){
			if (array)
			{
				NSUInteger index = (page - 1) * itemsPerPage;
				//NSLog(@"StartingIndex: %d", index);
				[self setItems:array startingAtIndex:index];
				NSArray *allItemsArray = [self itemsInRange:range];
				if (allItemsArray.count == range.length && NO == [allItemsArray containsObject:[NSNull null]] && completionBlock)
					completionBlock(allItemsArray);
			}
			else
			{
				if (completionBlock)
					completionBlock(nil);
			}
		}];
	}
}

+ (void)itemAtIndex:(NSUInteger)index forceRefresh:(BOOL)forceRefresh infoDictionary:(NSDictionary *)infoDictionary completionBlock:(TOMPaginatedModelResultCompletionBlock)completionBlock
{
	[self itemsInRange:NSMakeRange(index, 1) forceRefresh:forceRefresh infoDictionary:(NSDictionary *)infoDictionary completionBlock:^(NSArray *array){
		id item = (array.count ? array[0] : nil);
		if (completionBlock)
			completionBlock([item isKindOfClass:[NSNull class]] ? nil : item);
	}];
}

/*
+ (void)removeItemAtIndex:(NSUInteger)index
{
	NSAssertMainThread;
	if (index < kTOMPaginatedModelItemsArray.count)
	{
		NSMutableArray *mutableArray = kTOMPaginatedModelItemsArray.mutableCopy;
		[mutableArray removeObjectAtIndex:index];
		kTOMPaginatedModelItemsArray = [NSArray arrayWithArray:mutableArray];
	}
}

+ (void)insertItem:(id)item atIndex:(NSUInteger)index
{
	NSAssertMainThread;
	if (index < kTOMPaginatedModelItemsArray.count)
	{
		NSMutableArray *mutableArray = kTOMPaginatedModelItemsArray.mutableCopy;
		[mutableArray insertObject:item atIndex:index];
		kTOMPaginatedModelItemsArray = [NSArray arrayWithArray:mutableArray];
	}
	else
	{
		[self setItem:item atIndex:index];
	}
}
*/

+ (void)setItem:(id)item atIndex:(NSUInteger)index
{
	NSAssertMainThread;
	[self setItems:@[item] startingAtIndex:index];
}

+ (void)setItems:(NSArray *)items startingAtIndex:(NSUInteger)startingIndex
{
	NSAssertMainThread;
	for (NSUInteger index = 0; index < items.count; index++)
	{
		//NSLog(@"Putting %@ at index %d", items[index], startingIndex + index);
		[self cache][@(startingIndex + index)] = items[index];
	}
}

+ (void)dumpCache
{
	NSAssertMainThread;
	[[self cache] removeAllObjects];
}

#pragma mark - Helpers

+ (NSArray *)itemsInRange:(NSRange)range
{
	NSAssertMainThread;
	NSMutableArray *mutableArray = @[].mutableCopy;
	for (NSUInteger index = range.location; index < range.location + range.length; index++)
	{
		id object = [self cache][@(index)];
		[mutableArray addObject:(object ? object : [NSNull null])];
	}
	//NSLog(@"Range: %d:%d Array: %@", range.location, range.length, mutableArray);
	return [NSArray arrayWithArray:mutableArray];
}

#pragma mark - Overrides

+ (NSTimeInterval)ttlForCachedResults
{
	return 120;
}

+ (NSTimeInterval)ttlForRefreshedResults
{
	return 10;
}

+ (NSUInteger)numberOfItemsPerPage
{
	NSAssert(NO, @"[%@ numberOfItemsPerPage] must be overridden in child class.", NSStringFromClass([self class]));
	return 0;
}

+ (void)fetchItemsFromServerForPage:(NSUInteger)page infoDictionary:(NSDictionary *)infoDictionary completionBlock:(TOMPaginatedModelResultsCompletionBlock)completionBlock
{
	NSAssert(NO, @"[%@ fetchItemsFromServerForPage:completionBlock:] must be overridden in child class.", NSStringFromClass([self class]));
}

@end
