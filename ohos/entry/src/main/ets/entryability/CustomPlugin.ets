import  { FlutterPlugin,
  FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import StandardMessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMessageCodec';
import { CustomFactory } from './CustomFactory';

export class CustomPlugin implements FlutterPlugin {
  getUniqueClassName(): string {
    return 'CustomPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    binding.getPlatformViewRegistry()?.
    registerViewFactory('com.rex.custom.ohos/customView', new CustomFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {}
}