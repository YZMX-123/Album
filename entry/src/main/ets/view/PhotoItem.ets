import Constants from '../common/constants/Constants';

@Component
export default struct PhotoItem {
  photoArr: Array<Resource> = [];     // 图片数组
  @State currentIndex: number = 0;
  private showCount: number = Constants.SHOW_COUNT / Constants.DOUBLE_NUMBER; // 同时显示的图片数量

  @Builder
  albumPicBuilder(img: Resource, index: number) {
    Column() {
      Image(img)
        .width(Constants.FULL_PERCENT)
        .height(Constants.FULL_PERCENT)
        .borderRadius($r('app.float.img_border_radius'))
        .opacity(1 - (this.showCount - index - 1) * Constants.ITEM_OPACITY_OFFSET) // 透明度随着图片的位置变化而变化
    }
    .padding((this.showCount - index - 1) * Constants.PHOTO_ITEM_PADDING)
    .offset({ y: (this.showCount - index - 1) * Constants.PHOTO_ITEM_OFFSET })
    .height(Constants.PHOTO_ITEM_PERCENT)
    .width(Constants.FULL_PERCENT)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {  // 栈布局，顶部对齐
      // 为每个图片调用albumPicBuilder，传入图片和索引
      ForEach(Constants.CACHE_IMG_LIST, (image: string, index?: number) => {
        this.albumPicBuilder(this.photoArr[this.showCount - (index || 0) - 1], index)
      }, (item: string, index: number) => JSON.stringify(item) + index)
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
  }
}