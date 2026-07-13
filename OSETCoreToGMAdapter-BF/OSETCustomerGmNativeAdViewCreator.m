//
//  OSETCustomerGmNativeAdViewCreator.m
//  OSETCoreToGMAdapter
//

#import "OSETCustomerGmNativeAdViewCreator.h"

@interface OSETCustomerGmNativeAdViewCreator ()

@property (nonatomic, weak) OSETNativeAdRenderer *renderer;

@end

@implementation OSETCustomerGmNativeAdViewCreator

- (instancetype)initWithRenderer:(OSETNativeAdRenderer *)renderer {
    if (self = [super init]) {
        _renderer = renderer;
    }
    return self;
}

#pragma mark - BUMMediatedNativeAdViewCreator
// 视频/媒体承载体，绑定 dataObject 后由 renderer 自动生成
- (UIView *)mediaView {
    if(self.renderer.dataObject.isVideoAd){
        return self.renderer.mediaView;
    }else{
        return nil;
    }
}

@end
