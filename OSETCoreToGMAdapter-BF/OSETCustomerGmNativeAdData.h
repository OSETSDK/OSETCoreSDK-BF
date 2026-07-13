//
//  OSETCustomerGmNativeAdData.h
//  OSETCoreToGMAdapter
//
//  自渲染信息流 - GroMore 数据层
//  wrap 一条 OSETNativeDataAdObject，把 OSET 字段翻译成 GroMore 的 BUMMediatedNativeAdData
//

#import <Foundation/Foundation.h>
#import <BUAdSDK/BUAdSDK.h>
#import "OSETSDK/OSETSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSETCustomerGmNativeAdData : NSObject <BUMMediatedNativeAdData>

- (instancetype)initWithDataObject:(OSETNativeDataAdObject *)dataObject;

@end

NS_ASSUME_NONNULL_END
