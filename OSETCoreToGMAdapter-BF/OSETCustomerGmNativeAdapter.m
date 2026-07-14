//
//  OSETCustomerGmNativeAdapter.m
//  BUADDemo
//
//  Created by Shens on 5/3/2025.
//  Copyright © 2025 bytedance. All rights reserved.
//

#import "OSETCustomerGmNativeAdapter.h"
#import "OSETSDK/OSETSDK.h"
#import "OSETCustomerGmNativeAdData.h"
#import "OSETCustomerGmNativeAdViewCreator.h"


@interface OSETCustomerGmNativeAdapter()<OSETNativeAdDelegate, OSETNativeDataAdDelegate, OSETNativeAdRendererDelegate>
/// 模板信息流加载器
@property (nonatomic,strong) OSETNativeAd *nativeAd;
/// 自渲染信息流加载器
@property (nonatomic,strong) OSETNativeDataAd *dataAd;
/// 自渲染每条广告的渲染器（delegate 为 weak，须在此强持有，否则收不到曝光/点击事件）
@property (nonatomic,strong) NSMutableArray<OSETNativeAdRenderer *> *renderers;
@property (nonatomic, weak) UIViewController *viewController;
@end

@implementation OSETCustomerGmNativeAdapter

/// 当前加载的广告的状态，native模板广告
- (BUMMediatedAdStatus)mediatedAdStatusWithExpressView:(UIView *)view {
    return BUMMediatedAdStatusUnknown;
}

- (void)loadNativeAdWithSlotID:(nonnull NSString *)slotID andSize:(CGSize)size imageSize:(CGSize)imageSize parameter:(nonnull NSDictionary *)parameter {
    UIViewController * vc = [[UIViewController alloc]init];
    if(self.viewController){
        vc = self.viewController;
    }
    BOOL express = [parameter[BUMAdLoadingParamExpressAdType] integerValue] == 1;
    if (express) {
        // ADN 渲染(模板) / 无需区分
        self.nativeAd = [[OSETNativeAd alloc] initWithSlotId:slotID size:size rootViewController:vc];
        self.nativeAd.delegate = self;
        [self.nativeAd loadAdData];
    } else {
        // 开发者自渲染
        self.renderers = [NSMutableArray array];
        self.dataAd = [[OSETNativeDataAd alloc] initWithSlotId:slotID size:size rootViewController:vc];
        self.dataAd.delegate = self;
        self.dataAd.videoMuted = [parameter[BUMAdLoadingParamNAIsMute] boolValue];
        [self.dataAd loadAdData];
    }
}

- (void)nativeExpressAdLoadSuccessWithNative:(id)native nativeExpressViews:(NSArray *)nativeExpressViews{
    NSMutableArray *list = [[NSMutableArray alloc]init];
    NSMutableArray *exts = [[NSMutableArray alloc] init];
    for (int i = 0; i < nativeExpressViews.count; i++) {
        OSETBaseView * view = [nativeExpressViews objectAtIndex:i];
        [list addObject:view];
        [exts addObject:@{
            BUMMediaAdLoadingExtECPM : @(view.eCPM),
        }];
    }
    [self.bridge nativeAd:self didLoadWithExpressViews:[list copy] exts:exts.copy];
}
- (void)nativeExpressAdRenderSuccess:(id)nativeExpressView{
    [self.bridge nativeAd:self renderSuccessWithExpressView:nativeExpressView];
}
- (void)nativeExpressAdFailedToLoad:(nonnull id)nativeExpressAd error:(nonnull NSError *)error {
    [self.bridge nativeAd:self didLoadFailWithError:error];
}
- (void)nativeExpressAdFailedToRender:(nonnull id)nativeExpressView {
    NSError * error = [[NSError alloc]initWithDomain:@"nativeExpressAdFailedToRender" code:72001 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"OSETBU"]}];
    [self.bridge nativeAd:self renderFailWithExpressView:nativeExpressView andError:error];
}
- (void)nativeExpressAdDidClick:(nonnull id)nativeExpressView {
    [self.bridge nativeAd:self didClickWithMediatedNativeAd:nativeExpressView];
}
- (void)nativeExpressAdDidClose:(nonnull id)nativeExpressView {
    [self.bridge nativeAd:self didCloseWithExpressView:nativeExpressView closeReasons:@[]];


}
-(void)nativeExpressAdDidExposured:(id)nativeExpressView{
    [self.bridge nativeAd:self didVisibleWithMediatedNativeAd:nativeExpressView];
}

#pragma mark - OSETNativeDataAdDelegate（自渲染加载回调）
- (void)nativeDataAdLoadSuccessWithNative:(id)nativeDataAd nativeDataObjects:(NSArray<OSETNativeDataAdObject *> *)nativeDataObjects {
    NSMutableArray *list = [NSMutableArray array];
    NSMutableArray *exts = [NSMutableArray array];
    for (OSETNativeDataAdObject *obj in nativeDataObjects) {
        // 每条广告配一个 renderer，负责生成 mediaView、注册点击、回调事件
        OSETNativeAdRenderer *renderer = [[OSETNativeAdRenderer alloc] init];
        renderer.dataObject = obj;
        renderer.delegate = self;
        if (self.viewController) {
            renderer.viewController = self.viewController;
        }
        [self.renderers addObject:renderer];
        BUMMediatedNativeAd *ad = [[BUMMediatedNativeAd alloc] init];
        ad.data = [[OSETCustomerGmNativeAdData alloc] initWithDataObject:obj];
        ad.viewCreator = [[OSETCustomerGmNativeAdViewCreator alloc] initWithRenderer:renderer];
        ad.view = [[UIView alloc] init];
        ad.originMediatedNativeAd = renderer;  // 后续 GroMore 回调 forNativeAd: 给的就是它
        [list addObject:ad];

        [exts addObject:@{ BUMMediaAdLoadingExtECPM : @(obj.eCPM) }];
    }
    [self.bridge nativeAd:self didLoadWithNativeAds:[list copy] exts:[exts copy]];
}

- (void)nativeDataAdFailedToLoad:(id)nativeDataAd error:(NSError *)error {
    [self.bridge nativeAd:self didLoadFailWithError:error];
}

#pragma mark - OSETNativeAdRendererDelegate（自渲染展示事件）
- (void)OSETNativeAdRendererWillExpose:(OSETNativeAdRenderer *)renderer {
    [self.bridge nativeAd:self didVisibleWithMediatedNativeAd:renderer];
}

- (void)OSETNativeAdRendererDidClick:(OSETNativeAdRenderer *)renderer {
    [self.bridge nativeAd:self didClickWithMediatedNativeAd:renderer];
}

- (void)OSETNativeAdRendererDidClose:(OSETNativeAdRenderer *)renderer {
    [self.bridge nativeAd:self dislikeWithMediatedNativeAd:renderer closeReasons:@[]];
    [renderer unregisterDataObject];
    [self.renderers removeObject:renderer];
}

- (void)OSETNativeAdRendererDetailViewClosed:(OSETNativeAdRenderer *)renderer {
    [self.bridge nativeAd:self didDismissFullScreenModalWithMediatedNativeAd:renderer];
}

- (void)registerContainerView:(nonnull __kindof UIView *)containerView andClickableViews:(nonnull NSArray<__kindof UIView *> *)views forNativeAd:(nonnull id)nativeAd {
    // 自渲染点击注册：先容器后可点击区域，顺序不可反
    if ([nativeAd isKindOfClass:[OSETNativeAdRenderer class]]) {
        OSETNativeAdRenderer *renderer = (OSETNativeAdRenderer *)nativeAd;
        if(views && views.count>0){
            [renderer registerContainerView:views.firstObject withDataObject:renderer.dataObject];
        }else{
            [renderer registerContainerView:containerView withDataObject:renderer.dataObject];
        }
        [renderer registerClickableViews:views];

    }
}

- (void)renderForExpressAdView:(nonnull UIView *)expressAdView {
    // 如不adn广告不需要render，请尽量模拟回调renderSuccess
    [self.bridge nativeAd:self renderSuccessWithExpressView:expressAdView];
}

- (void)setRootViewController:(nonnull UIViewController *)viewController forExpressAdView:(nonnull UIView *)expressAdView {
    self.viewController = viewController;
    self.nativeAd.viewController = viewController;
}

- (void)setRootViewController:(nonnull UIViewController *)viewController forNativeAd:(nonnull id)nativeAd {
    self.viewController = viewController;
    // 自渲染：nativeAd 即 originMediatedNativeAd = renderer
    if ([nativeAd isKindOfClass:[OSETNativeAdRenderer class]]) {
        ((OSETNativeAdRenderer *)nativeAd).viewController = viewController;
    }
}

- (void)didReceiveBidResult:(BUMMediaBidResult *)result {
    // 在此处理Client Bidding的结果回调
//    NSLog(@"didReceiveBidResult = %@,%ld,%@,%@",result,(long)result.win,result.winnerPrice,result.winnerAdnID);

}

@end
