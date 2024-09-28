import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import { IconStatus } from '../viewModel/IconListViewModel';
import AdjustContentView from '../view/AdjustContentView';
import { cropIconChangeList, menuIconList } from '../viewModel/IconListViewModel';
import Logger from '../utils/LoggerUtil';
import Constants from '../common/constants/Constants';
import { RotateType, CropType, MainTabId } from '../viewModel/OptionViewModel';
import { EditConstants } from '../common/constants/EditConstants';
import { ImageSelect } from '../view/ImageSelect';
import { ImageSizeItem } from '../viewmodel/ImageSizeItem';
import { CropRatioType } from '../viewmodel/CropType';

const TAG: string = 'imageEdit';

@Entry
@Component
struct EditPage {
  @State @Watch('listenCropChange') currentIndex: number = 0;
  @State currentCropIndex: number = 0;
  @Provide pixelMap: image.PixelMap | undefined = undefined;
  @Provide imageInfo: image.ImageInfo | undefined = undefined;
  @Provide currentAdjustData: Array<number> = EditConstants.ADJUST_SLIDER_VALUE.map((item) => item);
  @Provide resetShow: boolean = true;     // 是否显示重置按钮
  @Provide showCanvas: boolean = false;
  @Provide imageWidth: number = 0;
  @Provide imageHeight: number = 0;
  @Provide cropRatio: CropRatioType = CropRatioType.RATIO_TYPE_FREE;
  @Provide isCrop: boolean = this.currentIndex === 0;
  @Provide screenWidth: number = 0;
  @Provide screenHeight: number = 0;
  @State imageSize: ImageSizeItem = { width: 0, height: 0 };
  @Provide imageOldSize: ImageSizeItem = { width: 0, height: 0 };
  @Provide imageScale: number = 1;
  private menuIconChangeList = menuIconList;
  private cropIconChange = cropIconChangeList;
  private statusBar: number = 0;
  @Provide isPixelMapChange: boolean = false;
  @Provide isSave: boolean = false;
  @Provide isSaveFresh: boolean = false;

  aboutToAppear() {
    this.statusBar = AppStorage.Get('statusBar') as number;
    this.pixelInit();
  }

  build() {
    Column() {
      Row() {
        Row() {       // 页面标题
          Text($r('app.string.image_edit'))
            .fontSize($r('app.float.edit_page_title_font_size'))
            .fontWeight(Constants.TITLE_FONT_WEIGHT)
            .fontColor($r('app.color.white'))
        }
        .height($r('app.float.navi_bar_height'))
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .margin({ top: $r('app.float.grid_padding') })
        .padding({ left: $r('app.float.title_padding') })
        .width(Constants.FULL_PERCENT)
        Blank()

        // 重置按钮
        Row({ space: EditConstants.TITLE_SPACE }) {
          Button() {
            Image($r("app.media.ic_reset"))
              .width($r('app.float.title_image_width'))
              .height($r('app.float.title_image_height'))
          }
          // .visibility(this.resetShow ? Visibility.Visible : Visibility.Hidden)
          .visibility(Visibility.Visible)
          .height(EditConstants.LAYOUT_FULL_SCREEN)
          .type(ButtonType.Normal)
          .aspectRatio(1)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.pixelInit();     // 点击事件 初始化图片
          })
          .margin({ right: $r('app.float.edit_page_title_margin') })

          // 保存按钮
          Button() {
            Image($r("app.media.ic_save"))
              .width($r('app.float.title_image_width'))
              .height($r('app.float.title_image_height'))
          }
          // .visibility(this.resetShow ? Visibility.Visible : Visibility.Hidden)
          .visibility(Visibility.Visible)
          .height(EditConstants.LAYOUT_FULL_SCREEN)
          .type(ButtonType.Normal)
          .aspectRatio(1)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            AlertDialog.show({      // 点击 弹出询问
              title: $r('app.string.save_image'),
              message: $r('app.string.confirm_save'),
              alignment: DialogAlignment.Center,
              primaryButton: {
                value: $r('app.string.save'),
                action: () => {
                  this.isSave = true;
                }
              },
              secondaryButton: {
                value: $r('app.string.cancel'),
                action: () => {
                  Logger.info(TAG, `cancel`);
                }
              }
            })
          })
          .margin({ right: $r('app.float.edit_page_title_margin') })
        }
      }
      .width(EditConstants.LAYOUT_FULL_SCREEN)
      .height($r('app.float.edit_page_title_height'))
      .margin({ top: $r('app.float.edit_page_title_margin') })

      // 图片
      Column() {
        if (this.isCrop && this.showCanvas && this.statusBar > 0) {
          if (this.isSaveFresh) {
            ImageSelect({
              statusBar: this.statusBar
            })
          } else {
            ImageSelect({
              statusBar: this.statusBar
            })
          }
        } else {
          if (this.isPixelMapChange) {
            Image(this.pixelMap)
              .scale({ x: this.imageScale, y: this.imageScale, z: 1 })
              .objectFit(ImageFit.None)
          } else {
            Image(this.pixelMap)
              .scale({ x: this.imageScale, y: this.imageScale, z: 1 })
              .objectFit(ImageFit.None)
          }
        }
      }
      .clip(true)
      .width(EditConstants.LAYOUT_FULL_SCREEN)
      .height(EditConstants.IMAGE_SHOW_HEIGHT)

      // 下方工具栏
      Column() {
        Tabs({ barPosition: BarPosition.End }) {
          // 裁切按钮
          TabContent() {
            Row() {
              ForEach(this.cropIconChange, (item: IconStatus, index: number) => {
                Image(this.currentCropIndex === index ? item?.chosen : item?.normal)
                  .width($r('app.float.crop_image_width'))
                  .height($r('app.float.crop_image_height'))
                  .onClick(() => {
                    this.cropImage(index);  // 点击事件 裁切图片
                  })
              }, (item: IconStatus) => JSON.stringify(item))
            }
            .width(EditConstants.LAYOUT_FULL_SCREEN)
            .height(EditConstants.LAYOUT_FULL_SCREEN)
            .justifyContent(FlexAlign.SpaceAround)
          }
          .tabBar(this.TabBuilderMenu(MainTabId.CROP, $r('app.string.crop')))

          // 旋转按钮
          TabContent() {
            Row() {
              Image($r('app.media.ic_clockwise'))
                .width($r('app.float.rotate_image_width'))
                .height($r('app.float.rotate_image_height'))
                .margin({ right: EditConstants.EDIT_PAGE_HEIGHT })
                .onClick(() => {
                  this.rotateImage(RotateType.CLOCKWISE);  // 点击事件 向右旋转图片////
                })
              Image($r('app.media.ic_anti_clockwise'))
                .width($r('app.float.rotate_image_width'))
                .height($r('app.float.rotate_image_height'))
                .onClick(async () => {
                  this.rotateImage(RotateType.ANTI_CLOCK);  // 点击事件 向左旋转图片
                })
            }
            .justifyContent(FlexAlign.Center)
            .width(EditConstants.LAYOUT_FULL_SCREEN)
            .height(EditConstants.LAYOUT_FULL_SCREEN)
          }
          .tabBar(this.TabBuilderMenu(MainTabId.ROTATE, $r('app.string.rotate')))

          // 调节按钮 可以调节亮度、透明度、饱和度
          TabContent() {
            AdjustContentView()
          }
          .tabBar(this.TabBuilderMenu(MainTabId.ADJUST, $r('app.string.adjust')))
        }
        .scrollable(false)
        .onChange((index: number) => {    // index//////
          this.currentIndex = index;
        })
      }
      .align(Alignment.End)
      .width(EditConstants.LAYOUT_FULL_SCREEN)
      .height(EditConstants.EDIT_PAGE_HEIGHT)
      .backgroundColor(Color.Black)
    }
    .width(EditConstants.LAYOUT_FULL_SCREEN)
    .height(EditConstants.LAYOUT_FULL_SCREEN)
    .backgroundColor(Color.Black)
  }

  @Builder
  TabBuilderMenu(index: number, name: string | Resource) {
    Column() {
      Image(this.currentIndex === index ? this.menuIconChangeList[index]?.chosen :
        this.menuIconChangeList[index]?.normal)
        .width(EditConstants.TAB_MENU_WIDTH)
        .height(EditConstants.TAB_MENU_WIDTH)

      Text(name)
        .fontColor(this.currentIndex === index ? Color.Blue : Color.White)
        .fontSize($r('app.float.category_font_size'))
        .margin({ top: $r('app.float.category_margin_top') })
    }
    .width(EditConstants.LAYOUT_FULL_SCREEN)
  }

  cropImage(index: CropType) {        // 裁切图片 自由和按比例
    this.currentCropIndex = index;
    switch (this.currentCropIndex) {
      case CropType.ORIGINAL_IMAGE:
        this.cropRatio = CropRatioType.RATIO_TYPE_FREE;
        break;
      case CropType.SQUARE:
        this.cropRatio = CropRatioType.RATIO_TYPE_1_1;
        break;
      case CropType.BANNER:
        this.cropRatio = CropRatioType.RATIO_TYPE_4_3;
        break;
      case CropType.RECTANGLE:
        this.cropRatio = CropRatioType.RATIO_TYPE_16_9;
        break;
      default:
        this.cropRatio = CropRatioType.RATIO_TYPE_FREE;
        break;
    }
  }

  rotateImage(rotateType: RotateType) {   // 旋转图片 两种方向
    if (rotateType === RotateType.CLOCKWISE) {
      try {
        if (this.pixelMap !== undefined) {
          this.pixelMap.rotate(EditConstants.CLOCK_WISE)  // 调用pixelMap的旋转
            .then(() => {
              this.flushPixelMapNew();    // 然后刷新
            })
        }
      } catch (error) {
        Logger.error(TAG, `there is a error in rotate process with ${error?.code}`);
      }
    }
    if (rotateType === RotateType.ANTI_CLOCK) {
      try {
        if (this.pixelMap !== undefined) {
          this.pixelMap.rotate(EditConstants.ANTI_CLOCK)
            .then(() => {
              this.flushPixelMapNew();
            })
        }
      } catch (error) {
        Logger.error(TAG, `there is a error in rotate process with ${error?.code}`);
      }
    }
  }

  flushPixelMap() {
    const temp = this.pixelMap;
    this.pixelMap = undefined;
    this.pixelMap = temp;
    this.updateImageInfo();
  }

  flushPixelMapNew() {
    this.isPixelMapChange = !this.isPixelMapChange;
    this.updateImageInfo();
  }

  async updateImageInfo() {
    if (this.pixelMap !== undefined) {
      await this.pixelMap.getImageInfo().then((imageInfo) => {
        this.imageInfo = imageInfo;
        this.imageWidth = px2vp(this.imageInfo.size.width);
        this.imageHeight = px2vp(this.imageInfo.size.height);
        this.imageOldSize = {
          width: this.imageWidth,
          height: this.imageHeight
        }
        this.showCanvas = true;
        this.calcScale();
      });
    }
  }

  calcScale() {
    let imageWidthScale = (this.screenWidth - EditConstants.DOUBLE * EditConstants.SCREEN_DISPLAY_MARGIN) /
    this.imageOldSize.width;
    let imageHeightScale = (this.screenHeight - EditConstants.DOUBLE * EditConstants.SCREEN_DISPLAY_MARGIN) /
    this.imageOldSize.height;
    this.imageScale = imageWidthScale > imageHeightScale ? imageHeightScale : imageWidthScale;
  }

  pixelInit() {       // 图片初始化 重置按钮的点击事件
    this.showCanvas = false;
    this.getPixelMap(EditConstants.RAW_FILE_NAME).then(pixelMap => {  // 加载示例图片
      this.pixelMap = pixelMap;
      this.currentCropIndex = 0;
      this.currentAdjustData = EditConstants.ADJUST_SLIDER_VALUE.map((item) => item);
      this.updateImageInfo();
      this.cropRatio = CropRatioType.RATIO_TYPE_FREE;
    });
  }

  listenCropChange() {
    this.isCrop = this.currentIndex === 0;
    if (this.isCrop) {
      this.resetShow = true;
    } else {
      this.resetShow = false;
    }
  }

  async getResourceFd(filename: string) {
    const resourceMgr = getContext(this).resourceManager;
    const context = getContext(this);
    if (filename === EditConstants.RAW_FILE_NAME) {
      let imageBuffer = await resourceMgr.getMediaContent($r("app.media.ic_edit"))
      let filePath = context.cacheDir + '/' + filename;
      let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let writeLen = fs.writeSync(file.fd, imageBuffer.buffer);
      fs.copyFileSync(filePath, context.cacheDir + '/' + EditConstants.RAW_FILE_NAME_TEST);
      return file.fd;
    } else {
      let filePath = context.cacheDir + '/' + filename;
      let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      return file.fd;
    }
  }

  async getPixelMap(fileName: string) {
    const fd = await this.getResourceFd(fileName);
    const imageSourceApi = image.createImageSource(fd);
    if (!imageSourceApi) {
      Logger.error(TAG, 'imageSourceAPI created failed!');
      return;
    }
    const pixelMap = await imageSourceApi.createPixelMap({
      editable: true
    });
    return pixelMap;
  }
}

