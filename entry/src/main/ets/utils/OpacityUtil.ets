import { EditConstants } from '../common/constants/EditConstants';
import Logger from './LoggerUtil';

const TAG = 'Opacity';

export async function adjustOpacity(pixelMap: PixelMap, value: number) {
  if (!pixelMap) {
    return;
  }
  const newPixelMap = pixelMap;
  await newPixelMap.opacity(value / EditConstants.SLIDER_MAX);
  return newPixelMap;
}