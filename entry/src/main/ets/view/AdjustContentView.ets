import worker, { MessageEvents } from '@ohos.worker';
import { adjustIconList, IconStatus } from '../viewModel/IconListViewModel';
import { adjustOpacity } from '../utils/OpacityUtil';
import { EditConstants } from '../common/constants/EditConstants';
import { AdjustId } from '../viewModel/OptionViewModel';
import { MessageItem } from '../viewmodel/MessageItem'
import Logger from '../utils/LoggerUtil';

@Component
export default struct AdjustContentView {     // 调节按钮
  @Builder
  TabBuilder(index: number, name: string | Resource) {
    Column() {
      Image(this.currentAdjustIndex === index ? this.AdjustIconList[index]?.chosen : this.AdjustIconList[index]?.normal)
        .width($r('app.float.adjust_icon_width'))
        .height($r('app.float.adjust_icon_height'))

      Text(name)
        .fontColor(this.currentAdjustIndex === index ? Color.Blue : Color.White)  // 选中的是蓝色 其他白色
        .fontSize($r('app.float.adjust_font_size'))
        .margin({ top: $r('app.float.adjust_margin_top') })
    }
    .width(EditConstants.LAYOUT_FULL_SCREEN)
  }

  @State currentAdjustIndex: number = 0;
  @Consume currentAdjustData: Array<number>;
  AdjustIconList: Array<IconStatus> = adjustIconList;

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      // 调节亮度
      TabContent() {
        SliderCustom({    // 滑动条
          currentIndex: AdjustId.BRIGHTNESS.valueOf(),
          min: EditConstants.SLIDER_MIN.valueOf(),
          max: EditConstants.SLIDER_MAX.valueOf(),
          currentAdjustData: $currentAdjustData
        })
      }
      .tabBar(this.TabBuilder(AdjustId.BRIGHTNESS, $r('app.string.brightness')))

      // 调节透明度
      TabContent() {
        SliderCustom({
          currentIndex: AdjustId.TRANSPARENCY.valueOf(),
          min: EditConstants.SLIDER_MIN.valueOf(),
          max: EditConstants.SLIDER_MAX.valueOf(),
          currentAdjustData: $currentAdjustData
        })
      }
      .tabBar(this.TabBuilder(AdjustId.TRANSPARENCY, $r('app.string.transparency')))

      // 调节饱和度
      TabContent() {
        SliderCustom({
          currentIndex: AdjustId.SATURATION.valueOf(),
          min: EditConstants.SLIDER_MIN.valueOf(),
          max: EditConstants.SLIDER_MAX.valueOf(),
          currentAdjustData: $currentAdjustData
        })
      }
      .tabBar(this.TabBuilder(AdjustId.SATURATION, $r('app.string.saturation')))
    }
    .margin({ bottom: $r('app.float.adjust_margin_bottom') })
    .onChange((index: number) => {
      this.currentAdjustIndex = index;
    })
  }
}

@Component
struct SliderCustom {
  @Prop currentIndex: number;
  @Link currentAdjustData: number[];
  @Prop min: number;
  @Prop max: number;
  @Consume pixelMap: PixelMap;
  @Consume isPixelMapChange: boolean;
  private postState: boolean = true;
  saturationLastSlider: number = EditConstants.SLIDER_MAX;
  brightnessLastSlider: number = EditConstants.SLIDER_MAX;
  deviceListDialogController: CustomDialogController = new CustomDialogController({
    builder: Dialog(),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });

  build() {
    Column() {
      Text(`${this.currentAdjustData[this.currentIndex]}`)
        .fontColor(Color.White)
        .margin({ top: $r('app.float.slider_margin_top') })
        .fontSize($r('app.float.slider_font_size'))
      Row() {
        Slider({
          value: this.currentAdjustData[this.currentIndex],
          step: EditConstants.SLIDER_STEP,
          min: this.min,
          max: this.max
        })
          .trackColor(Color.White)
          .width(EditConstants.SLIDER_WIDTH)
          .showSteps(true)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.sliderChange(value, mode);
          })
      }
      .width(EditConstants.LAYOUT_FULL_SCREEN)
      .justifyContent(FlexAlign.Center)
    }
  }

  sliderChange(value: number, mode: SliderChangeMode) {   // 用户滑动
    if (mode === SliderChangeMode.End) {
      this.currentAdjustData[this.currentIndex] = Math.round(value);
      switch (this.currentIndex) {
        case AdjustId.BRIGHTNESS:
          this.postToWorker(AdjustId.BRIGHTNESS, value, EditConstants.BRIGHTNESS_WORKER_FILE);
          break;
        case AdjustId.TRANSPARENCY:
          if (!this.pixelMap) {
            return;
          }
          this.pixelMap.opacity(Math.round(value) / EditConstants.SLIDER_MAX).then(() => {
            this.isPixelMapChange = !this.isPixelMapChange;
          });
          break;
        case AdjustId.SATURATION:
          this.postToWorker(AdjustId.SATURATION, value, EditConstants.SATURATION_WORKER_FILE);
          break;
        default:
          break;
      }
    }
  }

  postToWorker(type: AdjustId, value: number, workerName: string) {
    let sliderValue = type === AdjustId.BRIGHTNESS ? this.brightnessLastSlider : this.saturationLastSlider;
    try {
      let workerInstance = new worker.ThreadWorker(workerName);
      const bufferArray = new ArrayBuffer(this.pixelMap.getPixelBytesNumber());
      this.pixelMap.readPixelsToBuffer(bufferArray).then(() => {
        let message = new MessageItem(bufferArray, sliderValue, value);
        workerInstance.postMessage(message);
        if (this.postState) {
          this.deviceListDialogController.open();
        }
        this.postState = false;
        workerInstance.onmessage = (event: MessageEvents) => {
          this.updatePixelMap(event)
        };
        if (type === AdjustId.BRIGHTNESS) {
          this.brightnessLastSlider = Math.round(value);
        } else {
          this.saturationLastSlider = Math.round(value);
        }
        workerInstance.onexit = () => {
          if (workerInstance !== undefined) {
            workerInstance.terminate();
          }
        }
      });
    } catch (error) {
      Logger.error(`Create work instance fail, error message: ${JSON.stringify(error)}`);
    }
  }

  updatePixelMap(event: MessageEvents) {
    const newPixel = this.pixelMap;
    newPixel.writeBufferToPixels(event.data).then(() => {
      this.pixelMap = newPixel;
      this.isPixelMapChange = !this.isPixelMapChange;
      this.deviceListDialogController.close();
      this.postState = true;
    });
  }
}

@CustomDialog
export struct Dialog {
  controller: CustomDialogController;

  build() {
    Column() {
      LoadingProgress()
        .color(Color.White)
        .width(EditConstants.LOADING_WH)
        .height(EditConstants.LOADING_WH)
    }
  }
}
