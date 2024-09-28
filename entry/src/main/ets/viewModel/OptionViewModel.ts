export enum CropType {    // 裁切图片的类型
  ORIGINAL_IMAGE,
  SQUARE,
  BANNER,
  RECTANGLE
}
export enum RotateType {  // 旋转的类型 顺、逆时针
  CLOCKWISE,
  ANTI_CLOCK
}
export enum AdjustId {    // 调节 亮度、透明度、饱和度
  BRIGHTNESS,
  TRANSPARENCY,
  SATURATION
}
export enum MainTabId {   // 下方菜单 三种操作
  CROP,
  ROTATE,
  ADJUST
}

// 色域模型RGB-HSV
export enum RGBIndex {
  RED,
  GREEN,
  BLUE
}
export enum HSVIndex {  // 色相H，饱和度S，明亮度V来描述颜色的变化
  HUE,
  SATURATION,
  VALUE
}
// H：色相H取值范围为0°～360°，从红色开始按逆时针方向计算，红色为0°，绿色为120°，蓝色为240°。
// S：饱和度S越高，颜色则深而艳。光谱色的白光成分为0，饱和度达到最高。通常取值范围为0%～100%，值越大，颜色越饱和。
// V：明度V表示颜色明亮的程度，对于光源色，明度值与发光体的光亮度有关；对于物体色，此值和物体的透射比或反射比有关。通常取值范围为0%（黑）到100%（白）。

export enum AngelRange {
  ANGEL_0_60,
  ANGEL_60_120,
  ANGEL_120_180,
  ANGEL_180_240,
  ANGEL_240_300,
  ANGEL_300_360
}