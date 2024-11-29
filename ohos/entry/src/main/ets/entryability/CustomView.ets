import MethodChannel, {
  MethodCallHandler,
  MethodResult
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import StandardMethodCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMethodCodec';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { webview } from '@kit.ArkWeb';

@Component
struct ButtonComponent {
  @Prop params: Params
  customView: CustomView = this.params.platformView as CustomView
  @StorageLink('numValue') storageLink: string = "first"
  @State bkColor: Color = Color.Red

  private webviewController: WebviewController = new webview.WebviewController()

  build() {
    Web({src: 'https://baidu.com', controller: this.webviewController})
      .domStorageAccess(true)
      .fileAccess(true)
      .mixedMode(MixedMode.All)
      .databaseAccess(true)
      .userAgent("Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36")
  }
}

@Builder
function ButtonBuilder(params: Params) {
  ButtonComponent({ params: params })
    .backgroundColor(Color.Transparent)
}

AppStorage.setOrCreate('numValue', 'test')

@Observed
export class CustomView extends PlatformView implements MethodCallHandler {
  numValue: string = "test";

  methodChannel: MethodChannel;
  index: number = 1;

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    // 注册消息通道
    this.methodChannel = new MethodChannel(message, `com.rex.custom.ohos/customView${viewId}`, StandardMethodCodec.INSTANCE);
    this.methodChannel.setMethodCallHandler(this);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    // 接受Dart侧发来的消息
    let method: string = call.method;
    let link1: SubscribedAbstractProperty<number> = AppStorage.link('numValue');
    switch (method) {
      case 'getMessageFromFlutterView':
        let value: ESObject = call.args;
        this.numValue = value;
        link1.set(value)
        console.log("nodeController receive message from dart: " + this.numValue);
        result.success(true);
        break;
    }
  }

  public  sendMessage = () => {
    console.log("nodeController sendMessage")
    //向Dart侧发送消息
    this.methodChannel.invokeMethod('getMessageFromOhosView', 'natvie - ' + this.index++);
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(ButtonBuilder);
  }

  dispose(): void {
  }
}