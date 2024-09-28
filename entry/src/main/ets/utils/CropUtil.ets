import { RegionItem } from '../viewmodel/RegionItem';
import { EditConstants } from '../common/constants/EditConstants';

/**
 * Crop 1:1.
 *
 * @param pixelMap.
 * @param width.
 * @param height.
 */
export async function square(pixelMap: PixelMap, width: number, height: number) {
  if (width < height) {
    pixelMap.crop({
      size: {
        width: width,
        height: width
      },
      x: 0,
      y: Math.round((height - width) / EditConstants.AVERAGE_WEIGHT_WIDTH)
    });
  } else {
    pixelMap.crop({
      size: {
        width: height,
        height: height
      },
      x: Math.round((width - height) / EditConstants.AVERAGE_WEIGHT_WIDTH),
      y: 0
    });
  }
}

/**
 * Common crop function.
 *
 * @param pixelMap.
 * @param cropWidth.
 * @param cropHeight.
 * @param cropPosition.
 */
export async function cropCommon(pixelMap: PixelMap, cropWidth: number, cropHeight: number, cropPosition: RegionItem) {
  pixelMap.crop({
    size: {
      width: cropWidth,
      height: cropHeight
    },
    x: cropPosition.x,
    y: cropPosition.y
  });
}

/**
 * Crop 4:3.
 *
 * @param pixelMap.
 * @param width.
 * @param height.
 */
export async function banner(pixelMap: PixelMap, width: number, height: number) {
  if (width <= height) {
    const cropWidth = width;
    const cropHeight = Math.floor(width * EditConstants.CROP_RATE_4_3);
    const cropPosition: RegionItem = {
      x: 0,
      y: Math.floor((height - cropHeight) / EditConstants.AVERAGE_WEIGHT_WIDTH)
    };
    cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }
  if (width * EditConstants.CROP_RATE_4_3 >= height) {
    const cropWidth = Math.floor(height / EditConstants.CROP_RATE_4_3);
    const cropHeight = height;
    const cropPosition: RegionItem = {
      x: Math.floor((width - cropWidth) / EditConstants.AVERAGE_WEIGHT_WIDTH),
      y: 0
    };
    cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }

  const cropWidth = width;
  const cropHeight = Math.floor(width * EditConstants.CROP_RATE_4_3);
  const cropPosition: RegionItem = {
    x: 0,
    y: Math.floor((height - cropHeight) / EditConstants.AVERAGE_WEIGHT_WIDTH)
  }
  cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
}

/**
 * Crop 16:9.
 *
 * @param pixelMap.
 * @param width.
 * @param height.
 */
export async function rectangle(pixelMap: PixelMap, width: number, height: number) {
  if (width <= height) {
    const cropWidth = width;
    const cropHeight = Math.floor(width * (EditConstants.CROP_RATE_9_16));
    const cropPosition: RegionItem = {
      x: 0,
      y: Math.floor((height - cropHeight) / EditConstants.AVERAGE_WEIGHT_WIDTH)
    };
    cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }
  if (width * (EditConstants.CROP_RATE_9_16) >= height) {
    const cropWidth = Math.floor(height / (EditConstants.CROP_RATE_9_16));
    const cropHeight = height;
    const cropPosition: RegionItem = {
      x: Math.floor((width - cropWidth) / EditConstants.AVERAGE_WEIGHT_WIDTH),
      y: 0
    };
    cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }

  const cropWidth = width;
  const cropHeight = Math.floor(width * (EditConstants.CROP_RATE_9_16));
  const cropPosition: RegionItem = {
    x: 0,
    y: Math.floor((height - cropHeight) / EditConstants.AVERAGE_WEIGHT_WIDTH)
  };
  cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
}


