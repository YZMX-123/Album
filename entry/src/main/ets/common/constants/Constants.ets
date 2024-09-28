export default class Constants {
// static readonly：静态且不可变；可以在代码的任何地方通过名称直接访问

  // 轮播的图片列表 resources/base/media下的图片名称
  static readonly BANNER_IMG_LIST: Array<Resource> = [
  $r('app.media.cute1'),
  $r('app.media.person1'),
  $r('app.media.sun1'),
  $r('app.media.scene1'),
  ];

  // 四个不同类图片的图片列表
  // 生活图
  static readonly LIFE_LIST: Array<Resource> = [
  $r('app.media.cute1'),
  $r('app.media.cute2'),
  $r('app.media.cute3'),
  $r('app.media.cute4'),
  ];
  // 场景图
  static readonly SCENE_LIST: Array<Resource> = [
  $r('app.media.scene0'),
  $r('app.media.scene1'),
  $r('app.media.scene2'),
  $r('app.media.scene3'),
  ];
  // 人物图
  static readonly PERSON_LIST: Array<Resource> = [
  $r('app.media.person1'),
  $r('app.media.person2'),
  $r('app.media.person3')
  ];
  // 太阳图
  static readonly SUN_LIST: Array<Resource> = [
  $r('app.media.sun1'),
  $r('app.media.sun2'),
  ];

  // 首页图片数组，包括上述列表的各种组合 ...是展开操作符，用于将一个数组中的元素展开到另一个数组中
  static readonly IMG_ARR: Resource[][] = [
    [...Constants.SCENE_LIST, ...Constants.LIFE_LIST, ...Constants.PERSON_LIST, ...Constants.SUN_LIST],
    [...Constants.PERSON_LIST, ...Constants.LIFE_LIST, ...Constants.SCENE_LIST],
    [...Constants.SUN_LIST, ...Constants.SCENE_LIST, ...Constants.LIFE_LIST],
    [...Constants.LIFE_LIST, ...Constants.SUN_LIST, ...Constants.PERSON_LIST]
  ];

  // 一些用到的参数
  static readonly TITLE_FONT_WEIGHT: number = 500;    // 标题字体粗细
  static readonly BANNER_ASPECT_RATIO: number = 1.5;  // 轮播图的宽高比
  static readonly BANNER_ANIMATE_DURATION: number = 300;  // 轮播图动画持续时间
  static readonly SHARE_TRANSITION_DELAY: number = 100;   // 分享的过渡延迟
  static readonly STACK_IMG_RATIO: number = 0.9;      // 堆叠图的宽高比
  static readonly LIST_ITEM_SPACE: number = 5;        // 网格项之间的空隙
  static readonly CACHE_IMG_SIZE: number = 4;         // 缓存图片数量
  static readonly CACHE_IMG_LIST: string[] = ['', '', '', ''];  // 缓存的图片列表
  static readonly PAGE_TITLE: string = '星光';          // 页面标题
  static readonly PARAM_PHOTO_ARR_KEY: string = 'photoArr'; // 路由参数中图片数组的键名
  static readonly GRID_COLUMNS_TEMPLATE: string = '1fr 1fr 1fr 1fr';  // 网格列模板 等分成四列 相对单位fr
  static readonly INDEX_COLUMNS_TEMPLATE: string = '1fr 1fr';         // 首页网格列模板 等分成两列
  static readonly FULL_PERCENT: string = '100%';      // = LAYOUT_FULL_SCREEN
  static readonly PHOTO_ITEM_PERCENT: string = '90%'; // 图片项百分比大小
  static readonly SHOW_COUNT: number = 8;             // detailList页面下方缩略图的显示数量
  static readonly DEFAULT_WIDTH: number = 360;        // 默认宽度
  static readonly PHOTO_ITEM_PADDING: number = 8;     // 图片padding
  static readonly PHOTO_ITEM_OFFSET: number = 13;     // 图片项偏移
  static readonly ITEM_OPACITY_OFFSET: number = 0.2;  // 不透明度偏移
  static readonly DOUBLE_NUMBER: number = 2;

  static readonly URL_LIST_PAGE: string = 'pages/ListPage';     // 列表页面的路由url
  static readonly URL_DETAIL_LIST_PAGE: string = 'pages/DetailList';  // 详细列表页面的路由url
  static readonly URL_EDIT_PAGE: string = 'pages/EditPage';     // 编辑页面的路由url

  static readonly TAG_INDEX_PAGE: string = 'IndexPage push error '; // 首页log tag
  static readonly TAG_LIST_PAGE: string = 'ListPage push error ';   // 列表页面log tag
  static readonly TAG_DETAIL_PAGE: string = 'DetailListPage push error '; // 详细列表页面的log tag

}