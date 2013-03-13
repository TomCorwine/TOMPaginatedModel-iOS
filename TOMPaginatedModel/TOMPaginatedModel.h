//
//  TOMPaginatedModel.h
//  TOMPaginatedModel
//
//  Created by Tom Corwine on 2/21/13.
//

#import <Foundation/Foundation.h>
#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_4_3
	#error TOMJSONAdapter requires iOS 4.3 or later
#endif

typedef void (^TOMPaginatedModelResultsCompletionBlock)(NSArray *array);
typedef void (^TOMPaginatedModelResultCompletionBlock)(id item);

@interface TOMPaginatedModel : NSObject
+ (NSUInteger)numberOfItems;
+ (void)itemsInRange:(NSRange)range forceRefresh:(BOOL)forceRefresh infoDictionary:(NSDictionary *)infoDictionary completionBlock:(TOMPaginatedModelResultsCompletionBlock)completionBlock;
+ (void)itemAtIndex:(NSUInteger)index forceRefresh:(BOOL)forceRefresh infoDictionary:(NSDictionary *)infoDictionary completionBlock:(TOMPaginatedModelResultCompletionBlock)completionBlock;
//+ (void)removeItemAtIndex:(NSUInteger)index;
//+ (void)insertItem:(id)item atIndex:(NSUInteger)index;
+ (void)setItem:(id)item atIndex:(NSUInteger)index;
+ (void)setItems:(NSArray *)items startingAtIndex:(NSUInteger)index;
+ (void)dumpCache;

+ (NSTimeInterval)ttlForCachedResults;
+ (NSTimeInterval)ttlForRefreshedResults;
+ (NSUInteger)numberOfItemsPerPage;
+ (void)fetchItemsFromServerForPage:(NSUInteger)page infoDictionary:(NSDictionary *)infoDictionary completionBlock:(TOMPaginatedModelResultsCompletionBlock)completionBlock;

@end
