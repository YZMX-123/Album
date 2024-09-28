import router from '@ohos.router';
import Constants from '../common/constants/Constants';
import Logger from '../utils/LoggerUtil';

@Entry
@Component
struct ListPage {
  // 通过路由参数获取 图片数组 PARAM_PHOTO_ARR_KEY：路由参数中图片数组的键名
  photoArr: Array<Resource> = (router.getParams() as Record<string, Array<Resource>>)[`${Constants.PARAM_PHOTO_ARR_KEY}`];
  // @StorageLink：用于将组件的属性与本地存储关联起来。使得开发者可以轻松地在应用的不同页面或会话之间持久化数据。
  // 表示selectedIndex 属性与本地存储中的 selectedIndex 键相关联。用于跟踪用户在图片列表中选择的当前图片索引，即使用户离开页面再返回，所选的图片索引也能被保留。
  @StorageLink('selectedIndex') selectedIndex: number = 0;

  build() {
    // 最外层 导航栏组件
    Navigation() {
      // 网格布局
      Grid() {
        ForEach(this.photoArr, (img: Resource, index: number) => {
          GridItem() {
            Image(img)
              .height(Constants.FULL_PERCENT)
              .width(Constants.FULL_PERCENT)
              .objectFit(ImageFit.Cover)  // 图片填充方式 contain黑边，cover剪切，fill拉伸，none不调整大小
              .onClick(() => {      // 设置图片的点击事件，更新selectedIndex，并跳转到detailList页面，传递photoArr参数
                this.selectedIndex = index;
                router.pushUrl({
                  url: Constants.URL_DETAIL_LIST_PAGE,
                  params: {
                    photoArr: this.photoArr,
                  }
                }).catch((error: Error) => {
                  Logger.error(Constants.TAG_LIST_PAGE, JSON.stringify(error));
                });
              })
          }
          .width(Constants.FULL_PERCENT)
          .aspectRatio(1) // 宽高比1 即正方形
        }, (item: Resource) => JSON.stringify(item))
      }
      .columnsTemplate(Constants.GRID_COLUMNS_TEMPLATE)   // list页面网格列模板 等分成四列
      .rowsGap(Constants.LIST_ITEM_SPACE)
      .columnsGap(Constants.LIST_ITEM_SPACE)
      .layoutWeight(1)
    }
    .title(Constants.PAGE_TITLE)
    .hideBackButton(false)      // 显示返回按钮
    .titleMode(NavigationTitleMode.Mini)  // 导航栏标题模式 Mini简洁 Full突出
    .backgroundColor($r('app.color.start_window_background'))
  }
}