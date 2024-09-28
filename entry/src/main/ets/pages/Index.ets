import router from '@ohos.router';                      // 页面路由
import Constants from '../common/constants/Constants';  // 常量
import Logger from '../utils/LoggerUtil';               // 日志
import PhotoItem from '../view/PhotoItem';              // 显示照片

@Entry
@Component
struct Index {
  // @State message: string = 'Hello World'
  swiperController: SwiperController = new SwiperController();  // 轮播控制
  scroller: Scroller = new Scroller();  // 滚动
  @State currentIndex: number = 0;      // 状态变量
  @State angle: number = 0;

  build() {
    Column() {
      // 顶部标题文本
      Row() {
        Text($r('app.string.EntryAbility_label'))
          .fontSize($r('app.float.title_font_size'))
          .fontWeight(Constants.TITLE_FONT_WEIGHT)
          .fontColor($r('app.color.white'))
      }
      .height($r('app.float.navi_bar_height'))
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)  // 从行首起始位置开始排列
      .margin({ top: $r('app.float.grid_padding') })
      .padding({ left: $r('app.float.title_padding') })
      .width(Constants.FULL_PERCENT)
      .backgroundColor($r('app.color.title_background'))

      // 轮播组件
      Swiper(this.swiperController) {
        // 轮播的图片列表：Constants.BANNER_IMG_LIST
        ForEach(Constants.BANNER_IMG_LIST, (item: Resource) => {
          Row() {
            Image(item)
              .width(Constants.FULL_PERCENT)
              .height(Constants.FULL_PERCENT)
          }
          .width(Constants.FULL_PERCENT)
          .aspectRatio(Constants.BANNER_ASPECT_RATIO) // 宽高比
        }, (item: Resource, index: number) => JSON.stringify(item) + index)
        // ForeEach的第二个参数，回调函数，用于生成唯一的key，帮助框架识别数组中的每个元素，从而优化渲染性能。
        // JSON.stringify(item)将当前元素转换为JSON字符串，index是当前元素在数组中的位置
      }
      .autoPlay(true)
      .loop(true)
      .margin($r('app.float.grid_padding'))
      .borderRadius($r('app.float.img_border_radius'))
      .clip(true)
      .duration(Constants.BANNER_ANIMATE_DURATION)
      .indicator(false)

      // 相册主体 网格布局
      Grid() {
        // 每组图片：Constants.IMG_ARR
        ForEach(Constants.IMG_ARR, (photoArr: Array<Resource>) => {
          GridItem() {
            PhotoItem({ photoArr })
          }
          .width(Constants.FULL_PERCENT)
          .aspectRatio(Constants.STACK_IMG_RATIO)
          .onClick(() => {      // 设置图片的点击事件，跳转到list页面，并且传递photoArr参数
            Logger.info(Constants.TAG_INDEX_PAGE, "Click");
            router.pushUrl({
              url: Constants.URL_LIST_PAGE,
              params: { photoArr: photoArr }
            }).catch((error: Error) => {
              Logger.error(Constants.TAG_INDEX_PAGE, JSON.stringify(error));
            });
          })
        }, (item: Array<Resource>, index: number) => JSON.stringify(item) + index)
      }
      .columnsTemplate(Constants.INDEX_COLUMNS_TEMPLATE)  // 首页网格列模板 等分成两列
      .columnsGap($r('app.float.grid_padding'))     // 网格的行列间距 相等
      .rowsGap($r('app.float.grid_padding'))
      .padding({ left: $r('app.float.grid_padding'), right: $r('app.float.grid_padding') })
      .width(Constants.FULL_PERCENT)
      .layoutWeight(1)
    }
    .width(Constants.FULL_PERCENT)  // = .width('100%')
    .height(Constants.FULL_PERCENT)
    .backgroundColor($r('app.color.start_window_background'))   // 背景色
  }
}
//   build() {
//     Row() {
//       Column() {
//         Text(this.message)
//           .fontSize(50)
//           .fontWeight(FontWeight.Bold)
//       }
//       .width('100%')
//     }
//     .height('100%')
//   }
// }