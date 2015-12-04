//
//   ______     _   _                 _          _____ _____  _  __
//  |  ____|   | | (_)               | |        / ____|  __ \| |/ /
//  | |__   ___| |_ _ _ __ ___   ___ | |_ ___  | (___ | |  | | ' /
//  |  __| / __| __| | '_ ` _ \ / _ \| __/ _ \  \___ \| |  | |  <
//  | |____\__ \ |_| | | | | | | (_) | ||  __/  ____) | |__| | . \
//  |______|___/\__|_|_| |_| |_|\___/ \__\___| |_____/|_____/|_|\_\
//
//  Copyright (c) 2015 Estimote. All rights reserved.

#import <Foundation/Foundation.h>

#define ESTRequestBaseErrorDomain @"ESTRequestBaseErrorDomain"

typedef NS_ENUM(NSInteger, ESTRequestBaseError)
{
    ESTRequestBaseErrorConnectionFail
};


typedef void(^ESTRequestBlock)(id result, NSError *error);
typedef void(^ESTRequestSuccessBlock)(id result, NSError *error);
typedef void(^ESTRequestFailureBlock)(NSError *error);

@class ESTRequestBase;


@protocol ESTRequestBaseDelegate <NSObject>

- (void)request:(ESTRequestBase *)request didFinishLoadingWithResposne:(id)response;

- (void)request:(ESTRequestBase *)request didFailLoadingWithError:(NSError *)error;

@end


@interface ESTRequestBase : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<ESTRequestBaseDelegate> delegate;

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *receivedData;

- (NSMutableURLRequest *)createRequestWithCloudUrl:(NSString *)url;
- (NSMutableURLRequest *)createRequestWithUrl:(NSString *)url;

- (void)fireRequest:(NSMutableURLRequest *)request;
- (void)parseRespondedData:(id)data;
- (void)parseError:(NSError *)error;

- (void)sendRequest;
- (void)sendRequestWithCompletion:(ESTRequestBlock)completion;
- (void)cancelRequest;

#pragma mark - Helper methods

- (id)objectForKey:(NSString *)aKey inDictionary:(NSDictionary *)dict;

#pragma mark - Equality

- (BOOL)isEqualToRequest:(ESTRequestBase *)request;

@end
