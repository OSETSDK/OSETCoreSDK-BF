//
//  OSETCustomerGmNativeAdData.m
//  OSETCoreToGMAdapter
//

#import "OSETCustomerGmNativeAdData.h"

@interface OSETCustomerGmNativeAdData ()

@property (nonatomic, strong) OSETNativeDataAdObject *dataObject;

@end

@implementation OSETCustomerGmNativeAdData

- (instancetype)initWithDataObject:(OSETNativeDataAdObject *)dataObject {
    if (self = [super init]) {
        _dataObject = dataObject;
    }
    return self;
}

#pragma mark - BUMMediatedNativeAdData

- (BUMMediatedNativeAdCallToType)callToType {
    return BUMMediatedNativeAdCallToTypeOthers;
}

- (NSArray<BUMImage *> *)imageList {
    NSMutableArray *images = [NSMutableArray array];
    for (id item in self.dataObject.imageList) {
        if (![item isKindOfClass:[NSDictionary class]]) continue;
        NSDictionary *dict = (NSDictionary *)item;
        NSString *url = dict[@"url"];
        if (url.length == 0) continue;
        BUMImage *img = [[BUMImage alloc] init];
        img.imageURL = [NSURL URLWithString:url];
        img.width  = [dict[@"width"] floatValue];
        img.height = [dict[@"height"] floatValue];
        img.scale  = 1;
        [images addObject:img];
    }
    return images;
}

- (BUMImage *)icon {
    NSString *url = self.dataObject.appIconUrl;
    if (url.length == 0) return nil;
    BUMImage *icon = [[BUMImage alloc] init];
    icon.imageURL = [NSURL URLWithString:url];
    return icon;
}

- (BUMImage *)adLogo {
    NSString *url = self.dataObject.adIconUrl;
    if (url.length == 0) return nil;
    BUMImage *logo = [[BUMImage alloc] init];
    logo.imageURL = [NSURL URLWithString:url];
    return logo;
}

- (NSString *)adTitle {
    return self.dataObject.title ?: self.dataObject.appName;
}

- (NSString *)adDescription {
    return self.dataObject.desc;
}

- (NSString *)source {
    return nil;
}

- (NSString *)buttonText {
    return self.dataObject.buttonText;
}

- (NSString *)appPrice {
    return nil;
}

- (NSString *)videoUrl {
    // 自渲染视频由 OSETNativeAdRenderer.mediaView 承载播放，不对外暴露 url
    return nil;
}

- (BUFeedADMode)imageMode {
    if (self.dataObject.isVideoAd) {
        return BUFeedVideoAdModeImage;
    }
    if (self.dataObject.imageList.count > 1) {
        return BUFeedADModeGroupImage;
    }
    return BUFeedADModeLargeImage;
}

- (NSInteger)score {
    return -1;
}

- (NSInteger)commentNum {
    return -1;
}

- (NSInteger)appSize {
    return -1;
}

- (NSInteger)videoDuration {
    return 0;
}

- (CGFloat)videoAspectRatio {
    CGFloat w = [self.dataObject.coverWidth floatValue];
    CGFloat h = [self.dataObject.coverHeight floatValue];
    if (w > 0 && h > 0) {
        return w / h;
    }
    return 0;
}

- (NSDictionary *)mediaExt {
    return nil;
}

- (NSString *)brandName {
    return self.dataObject.appName ?: self.dataObject.title;
}

@end
