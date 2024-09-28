export interface IconStatus { // 图标的两种状态：normal（正常状态）和chosen（选中状态）
  normal: Resource,           // Resource类型，表示资源标识符，引用应用中的图片资源
  chosen: Resource
}

// 底部菜单，三个操作图标的状态
export const menuIconList: Array<IconStatus> = [
  {
    normal: $r('app.media.ic_crop'),
    chosen: $r('app.media.ic_crop_filled')
  },
  {
    normal: $r('app.media.ic_rotate'),
    chosen: $r('app.media.ic_rotate_filled')
  },
  {
    normal: $r('app.media.ic_adjust'),
    chosen: $r('app.media.ic_adjust_filled')
  }
]

// 裁切功能的四个小图标的状态 随意裁切、1:1、4:3、16:9
export const cropIconChangeList: Array<IconStatus> = [
  {
    normal: $r('app.media.ic_original'),
    chosen: $r('app.media.ic_original_filled'),
  },
  {
    normal: $r('app.media.ic_one2one'),
    chosen: $r('app.media.ic_one2one_filled')
  },
  {
    normal: $r('app.media.ic_four2three'),
    chosen: $r('app.media.ic_four2three_filled')
  },
  {
    normal: $r('app.media.ic_sixteen2nine'),
    chosen: $r('app.media.ic_sixteen2nine_filled')
  }
]
// 调节按钮
export const adjustIconList: Array<IconStatus> = [
  {
    normal: $r('app.media.ic_brightness'),
    chosen: $r('app.media.ic_brightness_filled')
  },
  {
    normal: $r('app.media.ic_transparency'),
    chosen: $r('app.media.ic_transparency_filled')
  },
  {
    normal: $r('app.media.ic_saturation'),
    chosen: $r('app.media.ic_saturation_filled')
  }
]

