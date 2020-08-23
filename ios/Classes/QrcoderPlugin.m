#import "QrcoderPlugin.h"
#if __has_include(<qrcoder/qrcoder-Swift.h>)
#import <qrcoder/qrcoder-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "qrcoder-Swift.h"
#endif

@implementation QrcoderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftQrcoderPlugin registerWithRegistrar:registrar];
}
@end
