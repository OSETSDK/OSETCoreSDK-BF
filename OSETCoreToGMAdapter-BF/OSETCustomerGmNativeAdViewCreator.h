//
//  OSETCustomerGmNativeAdViewCreator.h
//  OSETCoreToGMAdapter
//
//  自渲染信息流 - GroMore 视图层
//  只提供渠道必须自建的 view（视频/媒体承载体），其余元素由 GroMore 用数据自行组装
//

#import <Foundation/Foundation.h>
#import <BUAdSDK/BUAdSDK.h>
#import "OSETSDK/OSETSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSETCustomerGmNativeAdViewCreator : NSObject <BUMMediatedNativeAdViewCreator>

- (instancetype)initWithRenderer:(OSETNativeAdRenderer *)renderer;

@end

NS_ASSUME_NONNULL_END
