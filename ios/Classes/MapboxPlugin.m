#import "MapboxPlugin.h"
#if __has_include(<mapbox/mapbox-Swift.h>)
#import <mapbox/mapbox-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mapbox-Swift.h"
#endif

@implementation MapboxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMapboxPlugin registerWithRegistrar:registrar];
}
@end
