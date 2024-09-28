// 图片裁剪过程中的不同状态和比例
export enum CropTouchState {  // 用户在裁剪图片时可能进行的操作
  NONE,
  CROP_MOVE,    // 移动裁剪框
  IMAGE_DRAG,   // 拖动图片
  IMAGE_SCALE   // 缩放图片
}

export enum CropRatioType {   // 裁剪图片时可以使用的不同比例
  RATIO_TYPE_FREE,            // 自由
  RATIO_TYPE_HORIZONTAL,      // 水平框架
  RATIO_TYPE_VERTICAL,        // 垂直框架
  RATIO_TYPE_1_1,             // 1:1 等比例
  RATIO_TYPE_16_9,
  RATIO_TYPE_9_16,
  RATIO_TYPE_4_3,
  RATIO_TYPE_3_4,
  RATIO_TYPE_3_2,
  RATIO_TYPE_2_3
}

export enum CropAngle {     // 裁剪时图片可能被旋转的角度
  ONE_QUARTER_CIRCLE_ANGLE = 90,
  HALF_CIRCLE_ANGLE = 180,
  THREE_QUARTER_CIRCLE_ANGLE = 270,
  CIRCLE_ANGLE = 360
}