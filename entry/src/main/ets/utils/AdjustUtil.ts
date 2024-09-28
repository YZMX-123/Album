import { EditConstants } from '../common/constants/EditConstants';
import { RGBIndex, HSVIndex, AngelRange } from '../viewModel/OptionViewModel';

// 图像处理工具 提供调整图像饱和度和亮度的功能 通过对图像的每个像素应用颜色转换算法来实现（按倍率计算）
export function adjustSaturation(bufferArray: ArrayBuffer, last: number, cur: number) {
  return execColorInfo(bufferArray, last, cur, HSVIndex.SATURATION);
}
export function adjustImageValue(bufferArray: ArrayBuffer, last: number, cur: number) {
  return execColorInfo(bufferArray, last, cur, HSVIndex.VALUE);
}

// 遍历图像的每个像素，将RGB值转换为HSV值，根据hsvIndex参数调整相应的颜色成分（饱和度或亮度），然后将调整后的HSV值转换回RGB值
export function execColorInfo(bufferArray: ArrayBuffer, last: number, cur: number, hsvIndex: number) {
  if (!bufferArray) {
    return;
  }
  const newBufferArr = bufferArray;
  let colorInfo = new Uint8Array(newBufferArr);
  for (let i = 0; i < colorInfo?.length; i += EditConstants.PIXEL_STEP) {
    const hsv = rgb2hsv(colorInfo[i + RGBIndex.RED], colorInfo[i + RGBIndex.GREEN], colorInfo[i + RGBIndex.BLUE]);
    let rate = cur / last;
    hsv[hsvIndex] *= rate;
    const rgb = hsv2rgb(hsv[HSVIndex.HUE], hsv[HSVIndex.SATURATION], hsv[HSVIndex.VALUE]);
    colorInfo[i + RGBIndex.RED] = rgb[RGBIndex.RED];
    colorInfo[i + RGBIndex.GREEN] = rgb[RGBIndex.GREEN];
    colorInfo[i + RGBIndex.BLUE] = rgb[RGBIndex.BLUE];
  }
  return newBufferArr;
}

function colorTransform(rgbValue: number) { // 将RGB值从0-255的范围转换为0-1的范围
  return Number((rgbValue / EditConstants.COLOR_LEVEL_MAX).toFixed(EditConstants.DECIMAL_TWO));
}

// 将RGB颜色模型转换为HSV颜色模型
// red 0- 255 green 0- 255 blue 0- 255
// h (0 - 360) s (0 - 100) v (0 - 100)
// 首先将RGB值归一化到0-1范围内
// 计算HSV的Hue（色调）、Saturation（饱和度）和Value（亮度）
function rgb2hsv(red: number, green: number, blue: number) {
  let hsvH: number = 0, hsvS: number = 0, hsvV: number = 0;
  const rgbR: number = colorTransform(red);
  const rgbG: number = colorTransform(green);
  const rgbB: number = colorTransform(blue);
  const maxValue = Math.max(rgbR, Math.max(rgbG, rgbB));
  const minValue = Math.min(rgbR, Math.min(rgbG, rgbB));
  hsvV = maxValue * EditConstants.CONVERT_INT;
  if (maxValue === 0) {
    hsvS = 0;
  } else {
    hsvS = Number((1 - minValue / maxValue).toFixed(EditConstants.DECIMAL_TWO)) * EditConstants.CONVERT_INT;
  }
  if (maxValue === minValue) {
    hsvH = 0;
  }
  if (maxValue === rgbR && rgbG >= rgbB) {
    hsvH = Math.floor(EditConstants.ANGLE_60 * ((rgbG - rgbB) / (maxValue - minValue)));
  }
  if (maxValue === rgbR && rgbG < rgbB) {
    hsvH = Math.floor(EditConstants.ANGLE_60 * ((rgbG - rgbB) / (maxValue - minValue)) + EditConstants.ANGLE_360);
  }
  if (maxValue === rgbG) {
    hsvH = Math.floor(EditConstants.ANGLE_60 * ((rgbB - rgbR) / (maxValue - minValue)) + EditConstants.ANGLE_120);
  }
  if (maxValue === rgbB) {
    hsvH = Math.floor(EditConstants.ANGLE_60 * ((rgbR - rgbG) / (maxValue - minValue)) + EditConstants.ANGLE_240);
  }
  return [hsvH, hsvS, hsvV];
}

// 将HSV颜色模型转换回RGB颜色模型
// 根据Hue的值，将颜色映射到RGB空间
// 计算RGB值，并将结果转换回0-255的范围
/**
 *  HSV to RGB conversion formula:
 *  When 0 <= H <= 360, 0 <= S <= 1 and 0 <= V <= 1:
 *  C = V * S
 *  X = C * (1 - Math.abs((H / 60) mod 2 - 1))
 *  m = V - C
 *                   | (C, X ,0),  0 <= H < 60
 *                   | (X, C, 0),  60 <= H < 120
 *                   | (0, C, X),  120 <= H < 180
 *  (R', G', B') =   | (0, X, C),  180 <= H < 240
 *                   | (X, 0, C),  240 <= H < 300
 *                   | (C, 0, X),  300 <= H < 360
 *
 *  (R, G, B) = ((R' + m) * 255, (G' + m) * 255, (B' + m) * 255)
 *
 * @param h hue 0 ~ 360.
 * @param s saturation 0 ~ 100.
 * @param v value 0 ~ 100.
 * @return rgb value.
 */
function hsv2rgb(hue: number, saturation: number, value: number) {
  let rgbR: number = 0, rgbG: number = 0, rgbB: number = 0;
  if (saturation === 0) {
    rgbR = rgbG = rgbB = Math.round((value * EditConstants.COLOR_LEVEL_MAX) / EditConstants.CONVERT_INT);
    return { rgbR, rgbG, rgbB };
  }
  const cxmC = (value * saturation) / (EditConstants.CONVERT_INT * EditConstants.CONVERT_INT);
  const cxmX = cxmC * (1 - Math.abs((hue / EditConstants.ANGLE_60) % EditConstants.MOD_2 - 1));
  const cxmM = (value - cxmC * EditConstants.CONVERT_INT) / EditConstants.CONVERT_INT;
  const hsvHRange = Math.floor(hue / EditConstants.ANGLE_60);
  switch (hsvHRange) {
    case AngelRange.ANGEL_0_60:
      rgbR = (cxmC + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      rgbG = (cxmX + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      rgbB = (0 + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      break;
    case AngelRange.ANGEL_60_120:
      rgbR = (cxmX + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      rgbG = (cxmC + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      rgbB = (0 + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      break;
    case AngelRange.ANGEL_120_180:
      rgbR = (0 + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      rgbG = (cxmC + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      rgbB = (cxmX + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      break;
    case AngelRange.ANGEL_180_240:
      rgbR = (0 + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      rgbG = (cxmX + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      rgbB = (cxmC + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      break;
    case AngelRange.ANGEL_240_300:
      rgbR = (cxmX + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      rgbG = (0 + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      rgbB = (cxmC + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      break;
    case AngelRange.ANGEL_300_360:
      rgbR = (cxmC + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      rgbG = (0 + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      rgbB = (cxmX + cxmM) * EditConstants.COLOR_LEVEL_MAX;
      break;
    default:
      break;
  }
  return [
    Math.round(rgbR),
    Math.round(rgbG),
    Math.round(rgbB)
  ];
}