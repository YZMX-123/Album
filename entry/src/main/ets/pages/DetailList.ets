import display from '@ohos.display';
import router from '@ohos.router';
import Constants from '../common/constants/Constants';
import Logger from '../utils/LoggerUtil';

enum scrollTypeEnum {     // 两种滚动事件 停止滚动和滚动中
  STOP = 'onScrollStop',
  SCROLL = 'onScroll'
};

@Entry
@Component
struct DetailList {
  private smallScroller: Scroller = new Scroller();
  private bigScroller: Scroller = new Scroller();
  // 设备屏幕宽度 下方小图（缩略图）的宽度 现在展示的详细的大图的宽度
  @State deviceWidth: number = Constants.DEFAULT_WIDTH;
  @State smallImgWidth: number = (this.deviceWidth - Constants.LIST_ITEM_SPACE * (Constants.SHOW_COUNT - 1)) / Constants.SHOW_COUNT;
  @State imageWidth: number = this.deviceWidth + this.smallImgWidth;
  // 在滑动时创建一种平滑的过渡效果，允许用户在滑动到屏幕边缘时预览下一张或上一张图片的一部分

  private photoArr: Array<Resource | string> =
    (router.getParams() as Record<string, Array<Resource | string>>)[`${Constants.PARAM_PHOTO_ARR_KEY}`];
  // 小图数组：前后的缓存图片列表、路由参数中的图片列表
  private smallPhotoArr: Array<Resource | string> = [
    ...Constants.CACHE_IMG_LIST,
    ...(router.getParams() as Record<string, Array<Resource | string>>)[`${Constants.PARAM_PHOTO_ARR_KEY}`],
    ...Constants.CACHE_IMG_LIST
  ];
  @StorageLink('selectedIndex') selectedIndex: number = 0;

  @Builder
  SmallImgItemBuilder(img: Resource, index: number) {     // 构建小图列表项
    if (index > (Constants.CACHE_IMG_SIZE - 1) && index < (this.smallPhotoArr.length - Constants.CACHE_IMG_SIZE)) {
      Image(img)
        .onClick(() => this.smallImgClickAction(index))
    }
  }

  // 页面即将显示时，获取屏幕宽度并更新组件状态
  aboutToAppear() {
    // display模块：提供了一组API来获取和监听设备屏幕的显示属性，如屏幕的尺寸、密度和方向。display.Display类：代表设备屏幕的显示信息。
    // getDefaultDisplaySync()：用于同步地获取默认屏幕的显示信息。
    let displayClass: display.Display = display.getDefaultDisplaySync();
    // 从displayClass对象中获取屏幕的宽度（width），除以屏幕的密度（densityPixels）来计算实际的像素宽度
    // ?. ：可选链操作符。允许你安全地访问对象的深层属性，而不必显式地检查每一级是否存在。如果链中的某个部分是null或undefined，表达式将立即停止，并且整个表达式的值为undefined。
    // ?? ：空值合并运算符。允许在左侧表达式的结果为null或undefined时，使用右侧的表达式作为默认值。
    let width = displayClass?.width / displayClass.densityPixels ?? Constants.DEFAULT_WIDTH;
    this.deviceWidth = width;
    this.smallImgWidth = (width - Constants.LIST_ITEM_SPACE * (Constants.SHOW_COUNT - 1)) / Constants.SHOW_COUNT;
    this.imageWidth = this.deviceWidth + this.smallImgWidth;
  }
  // 页面显示时，滚动到选中的位置
  onPageShow() {
    this.smallScroller.scrollToIndex(this.selectedIndex);
    this.bigScroller.scrollToIndex(this.selectedIndex);
  }
  // 跳转到edit页面
  goDetailPage() {
    router.pushUrl({
      // url: Constants.URL_DETAIL_PAGE,
      url: Constants.URL_EDIT_PAGE,
      params: { photoArr: this.photoArr }
    }).catch((error: Error) => {
      Logger.error(Constants.URL_DETAIL_LIST_PAGE, JSON.stringify(error));
    });
  }

  // 小图的点击 跳转到点击的图，作为大图显示
  smallImgClickAction(index: number) {
    this.selectedIndex = index - Constants.CACHE_IMG_SIZE;
    this.smallScroller.scrollToIndex(this.selectedIndex);
    this.bigScroller.scrollToIndex(this.selectedIndex);
  }
  // 小图的滑动
  smallScrollAction(type: scrollTypeEnum) {
    // 计算当前滚动偏移加上小图宽度的一半，除以小图和间隔的总宽度，四舍五入得到当前选中的index
    this.selectedIndex = Math.round((this.smallScroller.currentOffset().xOffset + this.smallImgWidth / Constants.DOUBLE_NUMBER) / (this.smallImgWidth + Constants.LIST_ITEM_SPACE));
    if (type === scrollTypeEnum.SCROLL) {     // 滚动中 同步滚动大图到对应的位置
      this.bigScroller.scrollTo({ xOffset: this.selectedIndex * this.imageWidth, yOffset: 0 });
    } else {                                  // 停止 同步滚动小图到对应的位置
      this.smallScroller.scrollTo({ xOffset: this.selectedIndex * this.smallImgWidth, yOffset: 0 });
    }
  }
  // 大图的滑动（左右切换）
  bigScrollAction(type: scrollTypeEnum) {
    // 计算当前滚动偏移加上小图宽度加间隔的一半，除以大图的宽度，四舍五入得到当前选中的index
    let smallWidth = this.smallImgWidth + Constants.LIST_ITEM_SPACE;
    this.selectedIndex = Math.round((this.bigScroller.currentOffset().xOffset + smallWidth / Constants.DOUBLE_NUMBER) / this.imageWidth);
    if (type === scrollTypeEnum.SCROLL) {     // 滚动中 同步滚动小图到对应的位置
      this.smallScroller.scrollTo({ xOffset: this.selectedIndex * smallWidth, yOffset: 0 });
    } else {                                  // 停止 同步滚动大图到对应的位置
      this.bigScroller.scrollTo({ xOffset: this.selectedIndex * this.imageWidth, yOffset: 0 });
    }
  }

  build() {
    // 最外层 导航栏组件
    Navigation() {
      // stack 堆叠布局 子组件对齐到交叉轴（与 Stack 的主轴垂直的轴）的底部
      Stack({ alignContent: Alignment.Bottom }) {
        // 大图 可左右滑动
        List({ scroller: this.bigScroller, initialIndex: this.selectedIndex }) {
          ForEach(this.photoArr, (img: Resource) => {
            ListItem() {
              Image(img)
                .height(Constants.FULL_PERCENT)
                .width(Constants.FULL_PERCENT)
                .objectFit(ImageFit.Contain)
                .gesture(PinchGesture({ fingers: Constants.DOUBLE_NUMBER })
                  .onActionStart(() => this.goDetailPage()))
                .onClick(() => this.goDetailPage())
            }
            .padding({
              left: this.smallImgWidth / Constants.DOUBLE_NUMBER,
              right: this.smallImgWidth / Constants.DOUBLE_NUMBER
            })
            .width(this.imageWidth)
          }, (item: Resource) => JSON.stringify(item))
        }
        .onScroll((scrollOffset, scrollState) => {
          if (scrollState === ScrollState.Fling) {
            this.bigScrollAction(scrollTypeEnum.SCROLL);
          }
        })
        .onScrollStop(() => this.bigScrollAction(scrollTypeEnum.STOP))
        .width(Constants.FULL_PERCENT)
        .height(Constants.FULL_PERCENT)
        .padding({ bottom: this.smallImgWidth * Constants.DOUBLE_NUMBER })
        .listDirection(Axis.Horizontal)   // list方向 水平

        // 底部小图列表
        List({
          scroller: this.smallScroller,
          space: Constants.LIST_ITEM_SPACE,
          initialIndex: this.selectedIndex
        }) {
          ForEach(this.smallPhotoArr, (img: Resource, index: number) => {
            ListItem() {
              this.SmallImgItemBuilder(img, index)
            }
            .width(this.smallImgWidth)
            .aspectRatio(1)
          }, (item: Resource, index: number) => JSON.stringify(item) + index)
        }
        .listDirection(Axis.Horizontal)
        .onScroll((scrollOffset, scrollState) => {
          if (scrollState === ScrollState.Fling) {
            this.smallScrollAction(scrollTypeEnum.SCROLL);
          }
        })
        .onScrollStop(() => this.smallScrollAction(scrollTypeEnum.STOP))
        .margin({ top: $r('app.float.detail_list_margin'), bottom: $r('app.float.detail_list_margin') })
        .height(this.smallImgWidth)
        .width(Constants.FULL_PERCENT)
      }
      .width(this.imageWidth)
      .height(Constants.FULL_PERCENT)
    }
    .title(Constants.PAGE_TITLE)
    .hideBackButton(false)
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor($r('app.color.start_window_background'))
  }
}