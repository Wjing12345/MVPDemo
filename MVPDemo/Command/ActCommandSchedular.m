//
//  ActCommandSchedular.m
//  coolooknews
//
//  Created by zhoujie on 15/11/24.
//  Copyright © 2015年 coolook. All rights reserved.
//

#import "ActCommandSchedular.h"
#import "ActCommandSchedular+Key.h"

#import "ActCommand.h"
#import "ActCommandCache.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import <CoreFoundation/CoreFoundation.h>

static NSString* const kCommandKey = @"kCommandKey";

typedef void (^RequestSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^RequestFailBlock)(AFHTTPRequestOperation *operation, NSError *error);


@interface ActCommandSchedular : NSObject <ActCommandSchedular>
{
}

@property (nonatomic, strong) RequestSuccessBlock requestSuccess;
@property (nonatomic, strong) RequestFailBlock requestFail;
@property (nonatomic, copy) NSString* key;
@property (nonatomic, strong) AFHTTPRequestOperationManager* httpRequestManager;
@property (nonatomic, strong) dispatch_queue_t commandDispatch;
@property (nonatomic, strong) dispatch_queue_t commandHandler;
@property (nonatomic, strong) NSMutableArray *commandList;
@property (nonatomic, strong) ActCommandCache *commandCache;

- (id)initWithKey:(NSString *)aKey;

@end

#pragma mark ActCommandSchedularCenter

@interface ActCommandSchedularCenter ()

@property (nonatomic, retain) NSMutableDictionary* schedulars;

@end

@implementation ActCommandSchedularCenter

- (id)init
{
	self = [super init];
	self.schedulars = [NSMutableDictionary dictionaryWithCapacity:4];
	
	for (NSInteger start = ActCommandIdNormarlRequest; start < ActCommandIdCount; ++start)
	{
		NSString* key = [self keyForCommandId:start];
		[self registerSchedular:[self createSchedularForKey:key] key:key];
	}
	
	return self;
}

+ (ActCommandSchedularCenter *)shared
{
	static dispatch_once_t onceToken;
	static ActCommandSchedularCenter* sharedCenter = nil;
	dispatch_once(&onceToken, ^{
		sharedCenter = [[ActCommandSchedularCenter alloc] init];
	});
	return sharedCenter;
}

- (void)dealloc
{
	[self.schedulars enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[(id<ActCommandSchedular>)obj stop];
	}];
	self.schedulars = nil;
}

- (void)registerSchedular:(id<ActCommandSchedular>)aSchedular key:(NSString *)aKey
{
	@synchronized (self.schedulars)
	{
		[self.schedulars setObject:aSchedular forKey:aKey];
	}
}

- (void)removeSchedularForKey:(NSString *)aKey
{
	@synchronized(self.schedulars)
	{
		[self.schedulars removeObjectForKey:aKey];
	}
}

- (id<ActCommandSchedular>)schedularForKey:(NSString *)aKey
{
	return [self.schedulars objectForKey:aKey];
}

- (id<ActCommandSchedular>)createSchedularForKey:(NSString *)aKey
{
	return [[ActCommandSchedular alloc] initWithKey:aKey];
}

+ (id<ActCommandSchedular>)schedularWithCommandId:(NSInteger)aCommandId
{
	// CommandSchedular分配器
	
	ActCommandSchedularCenter *schedularCenter = [ActCommandSchedularCenter shared];
	NSString* key = [schedularCenter keyForCommandId:aCommandId];
	
	id<ActCommandSchedular> schedular = [schedularCenter schedularForKey:key];
	
	if (schedular == nil)
	{
		schedular = [schedularCenter createSchedularForKey:key];
		[schedularCenter registerSchedular:schedular key:key];
	}
	
	return schedular;
}

+ (id<ActCommandSchedular>)schedularWithKey:(NSString *)aKey
{
	ActCommandSchedularCenter *schedularCenter = [ActCommandSchedularCenter shared];
	id<ActCommandSchedular> schedular = [schedularCenter schedularForKey:aKey];
	
	if (schedular == nil)
	{
		schedular = [schedularCenter createSchedularForKey:aKey];
		[schedularCenter registerSchedular:schedular key:aKey];
	}
	
	return schedular;
}

@end

@implementation ActCommandSchedular

@synthesize requestSuccess;
@synthesize requestFail;

- (id)initWithKey:(NSString *)aKey
{
	self = [super init];
	if (self)
	{
		self.commandCache = [[ActCommandCache alloc] init];
		self.commandCache.limitNumberOfMinutes = 5; //缓存5分钟
		
		self.commandList = [NSMutableArray array];
		self.key = aKey;
		
		NSURL* url = nil;
		//        NSURL* url = [NSURL URLWithString:[ActGlobalConfig shared].httpHost];
		self.httpRequestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
		if ([aKey isEqualToString:@"SerialSchedularIdentifier"])
		{
			self.httpRequestManager.operationQueue.maxConcurrentOperationCount = 1;
		}
		[self.httpRequestManager.operationQueue setSuspended:NO];
		
		self.commandDispatch = dispatch_queue_create("CommandSchedularCommandDispatch", NULL);
		self.commandHandler = dispatch_queue_create("CommandSchedularCommandHandler", NULL);
		
		dispatch_queue_t cmdDispatch = self.commandHandler;
		
		__weak ActCommandSchedular* weakSelfSuccess = self;
		self.requestSuccess = ^(AFHTTPRequestOperation *operation, id responseObject) {
			dispatch_async(cmdDispatch, ^{
				__strong ActCommandSchedular* mySelf = weakSelfSuccess;
				ActCommand *command = [[operation userInfo] objectForKey:kCommandKey];
				
				
				if ([command checkHeaderError:operation.response.allHeaderFields])
				{
					[mySelf.commandCache cacheRequestWithCommand:command responseData:operation.responseData];
					
					[command requestDidFinish:operation.responseData];
				}
				else
				{
					[command requestDidFailWithError:[NSError errorWithDomain:@"http" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"网络异常", @"NSLocalizedDescription", nil]]];
				}
				
				[mySelf.commandList removeObject:command];
			});
		};
		
		__weak ActCommandSchedular* weakSelfFail = self;
		self.requestFail = ^(AFHTTPRequestOperation *operation, NSError *error) {
			dispatch_async(cmdDispatch, ^{
				
				__strong ActCommandSchedular* mySelf = weakSelfFail;
				ActCommand *command = [[operation userInfo] objectForKey:kCommandKey];
				
				NSLog(@"%@ HttpRequest Fail %@", [command description], error);
				
				if (error.domain && ![error.domain isEqualToString:@"NSURLErrorDomain"]) {
				}
				
				NSInteger errCode = 0;
				if (operation.response.statusCode >= 400)
				{
					errCode = operation.response.statusCode;
				}
				else
				{
					errCode = -1;
				}
				
				[command requestDidFailWithError:[NSError errorWithDomain:@"msb" code:errCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"网络异常", @"NSLocalizedDescription", nil]]];
				[mySelf.commandList removeObject:command];
			});
		};
	}
	return self;
}

- (void)dealloc
{
	self.key = nil;
	
	[[self.httpRequestManager operationQueue] cancelAllOperations];
	self.httpRequestManager = nil;
	
	self.commandDispatch = nil;
	self.commandHandler = nil;
	
	[self.commandList removeAllObjects];
	self.commandList = nil;
}

#pragma mark Public
- (void)start
{
	[_httpRequestManager.operationQueue setSuspended:NO];
}

- (void)stop
{
	ActCommandSchedularCenter *schedularCenter = [ActCommandSchedularCenter shared];
	[schedularCenter removeSchedularForKey:self.key];
}

- (void)addCommand:(ActCommand *)aCommand
{
	if (![self containsCommand:aCommand])
	{
		dispatch_async(self.commandDispatch, ^{
			[self sendCommand:aCommand];
		});
	}
}

- (void)removeCommandWithSeq:(NSInteger)aSeq
{
	dispatch_async(self.commandDispatch, ^{
		
		[[self.httpRequestManager.operationQueue operations] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			AFHTTPRequestOperation *op = (AFHTTPRequestOperation *)obj;
			ActCommand *cmd = [[op userInfo] objectForKey:kCommandKey];
			if (cmd && cmd.seqId == aSeq)
			{
				[op cancel];
				[self.commandList removeObject:cmd];
				*stop = YES;
			}
		}];
		
	});
}

#pragma mark Private
- (BOOL)containsCommand:(ActCommand *)aCommand
{
	return NO;
	
	__block BOOL find = NO;
	
	[self.commandList enumerateObjectsWithOptions:NSEnumerationConcurrent
									   usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
										   ActCommand *cmd = (ActCommand *)obj;
										   if ([cmd isEqual:aCommand])
										   {
											   find = YES;
											   *stop = YES;
										   }
									   }];
	
	return find;
}

- (void)sendCommand:(ActCommand *)aCommand
{
	[aCommand buildRequestHeader];
	[aCommand buildRequest];
	
	NSData *cachedResponseData = [self.commandCache cachedResponseDataWithCommand:aCommand];
	if (cachedResponseData) {
		[aCommand requestDidFinish:cachedResponseData];
		[self.commandList removeObject:aCommand];
		return;
	}
	
	NSMutableURLRequest *request = nil;
	
	if (aCommand.requestType == ActCommandRequestTypeGET)
	{
		NSString* params = [aCommand stringForEncodeURL:aCommand.params];
		NSMutableString* requestURLString = [NSMutableString stringWithString:aCommand.requestURLString];
		if (params.length)
		{
			if ([requestURLString rangeOfString:@"?"].length == 0)
			{
				[requestURLString appendFormat:@"?%@", [params substringToIndex:params.length - 1]];
			}
			else
			{
				[requestURLString appendFormat:@"&%@", [params substringToIndex:params.length - 1]];
			}
		}
		request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURLString]];
		[request setHTTPMethod:@"GET"];
         NSLog(@"GET:[%@]", requestURLString);
	}
	else
	{
		request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:aCommand.requestURLString]];
		[request setHTTPMethod:@"POST"];
		NSData* postData = [aCommand postData];
		if (postData == nil)
		{
			NSString* params = [aCommand stringForEncodeURL:aCommand.params];
			NSLog(@"POST:[%@] params:[%@]", aCommand.requestURLString, params);
			postData = [NSData dataWithBytes:[params UTF8String] length:[params length]];
		}
		[request setHTTPBody:postData];
		NSString* length = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
		[request addValue:length forHTTPHeaderField:@"Content-Length"];
		
	}
	
	request.timeoutInterval = 5;
	[aCommand.requestHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[request addValue:obj forHTTPHeaderField:key];
	}];
	
	if (aCommand.gzip)
	{
		[request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
		[request addValue:@"deflate" forHTTPHeaderField:@"Accept-Encoding"];
	}
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	
	operation.securityPolicy.allowInvalidCertificates = YES;
	operation.securityPolicy.validatesDomainName = NO;
	
	[operation setUserInfo:[NSDictionary dictionaryWithObject:aCommand forKey:kCommandKey]];
	[operation setCompletionBlockWithSuccess:self.requestSuccess
									 failure:self.requestFail];
	[operation setQueuePriority:(NSOperationQueuePriority)aCommand.priority];
	[self.httpRequestManager.operationQueue addOperation:operation];
}

@end