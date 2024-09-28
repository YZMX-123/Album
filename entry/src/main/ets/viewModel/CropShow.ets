import { LineSegment } from './Line';
import { Point } from './Point';
import { RectF } from './Rect';
import { Ratio } from './Ratio';  // 几何相关的类

import { CropAngle, CropRatioType } from './CropType';  // 裁剪角度和比例
import { MathUtils } from '../utils/MathUtils';
import Log from '../utils/LoggerUtil';
import { ScreenManager } from './ScreenManager';
import { EditConstants } from '../common/constants/EditConstants';

const TAG: string = 'editor_CropShow';

// 管理裁剪区域的显示和行为，包括初始化、同步限制区域、处理旋转和翻转等
export class CropShow {
  private limitRect: RectF;   // 表示裁剪区域、图片区域和限制区域
  private cropRect: RectF;
  private imageRect: RectF;
  private ratio: Ratio;       // 裁剪比例

  private screenMaxSide: number = 0;
  private screenMinSide: number = 0;
  private minSideLength: number = EditConstants.DEFAULT_MIN_SIDE_LENGTH;
  private touchBound: number = EditConstants.DEFAULT_TOUCH_BOUND;
  private rotationAngle: number = 0;
  private horizontalAngle: number = 0;
  private maxScaleFactorW: number = EditConstants.BASE_SCALE_VALUE;
  private maxScaleFactorH: number = EditConstants.BASE_SCALE_VALUE;
  private isFlipHorizontal: boolean = false;
  private isFlipVertically: boolean = false;
  private isLeft: boolean = false;
  private isRight: boolean = false;
  private isTop: boolean = false;
  private isBottom: boolean = false;
  private isHorizontalSide: boolean = false;
  private isVerticalSide: boolean = false;

  constructor() {
    this.limitRect = new RectF();
    this.imageRect = new RectF();
    this.cropRect = new RectF();
    this.ratio = new Ratio(EditConstants.DEFAULT_RATIO, EditConstants.DEFAULT_RATIO);

    let screenWidth = Math.ceil(ScreenManager.getInstance().getWinWidth());
    let screenHeight = Math.ceil(ScreenManager.getInstance().getWinHeight());
    this.screenMaxSide = Math.max(screenWidth, screenHeight);
    this.screenMinSide = Math.min(screenWidth, screenHeight);
  }

  init(limit: RectF, imageRatio: number) {
    this.limitRect.set(limit.left, limit.top, limit.right, limit.bottom);
    MathUtils.computeMaxRectWithinLimit(this.imageRect, limit, imageRatio);
    this.cropRect.set(this.imageRect.left, this.imageRect.top, this.imageRect.right, this.imageRect.bottom);
    this.ratio.set(EditConstants.DEFAULT_RATIO, EditConstants.DEFAULT_RATIO);
    this.rotationAngle = 0;
    this.horizontalAngle = 0;
    this.isFlipHorizontal = false;
    this.isFlipVertically = false;
  }

  syncLimitRect(limit: RectF) {   // 同步裁切矩形
    this.limitRect.set(limit.left, limit.top, limit.right, limit.bottom);
    this.enlargeCropArea();
  }

  getCropRect(): RectF {
    let crop = new RectF();
    crop.set(this.cropRect.left, this.cropRect.top, this.cropRect.right, this.cropRect.bottom);
    return crop;
  }
  getImageRect(): RectF {
    let image = new RectF();
    image.set(this.imageRect.left, this.imageRect.top, this.imageRect.right, this.imageRect.bottom);
    return image;
  }

  setImageRect(image: RectF) {
    this.imageRect.set(image.left, image.top, image.right, image.bottom);
  }

  syncRotationAngle(angle: number) {   // 同步旋转角度
    this.rotationAngle = angle;
    MathUtils.swapWidthHeight(this.cropRect);
    this.swapCurrentRatio();
    this.enlargeCropArea();
  }
  syncHorizontalAngle(angle: number) {
    this.horizontalAngle = angle;

    let points = MathUtils.rectToPoints(this.cropRect);
    let origin = this.getDisplayCenter();
    let totalAngle = -(this.rotationAngle + this.horizontalAngle);
    let rotated = MathUtils.rotatePoints(points, totalAngle, origin);
    let scale = MathUtils.findSuitableScale(rotated, this.imageRect, origin);
    MathUtils.scaleRectBasedOnPoint(this.imageRect, origin, scale);
  }

  setFlip(isFlipHorizontal: boolean, isFlipVertically: boolean) { // 翻转状态
    this.isFlipHorizontal = isFlipHorizontal;
    this.isFlipVertically = isFlipVertically;
  }

  setRatio(ratio: CropRatioType) {        // 裁切比例
    switch (ratio) {
      case CropRatioType.RATIO_TYPE_FREE:
        this.ratio.set(EditConstants.DEFAULT_RATIO, EditConstants.DEFAULT_RATIO);
        break;
      case CropRatioType.RATIO_TYPE_HORIZONTAL:
        this.ratio.set(this.screenMaxSide, this.screenMinSide);
        break;
      case CropRatioType.RATIO_TYPE_VERTICAL:
        this.ratio.set(this.screenMinSide, this.screenMaxSide);
        break;
      case CropRatioType.RATIO_TYPE_1_1:
        this.ratio.set(EditConstants.RATIO_1_1, EditConstants.RATIO_1_1);
        break;
      case CropRatioType.RATIO_TYPE_16_9:
        this.ratio.set(EditConstants.RATIO_16_9[0], EditConstants.RATIO_16_9[1]);
        break;
      case CropRatioType.RATIO_TYPE_9_16:
        this.ratio.set(EditConstants.RATIO_9_16[0], EditConstants.RATIO_9_16[1]);
        break;
      case CropRatioType.RATIO_TYPE_4_3:
        this.ratio.set(EditConstants.RATIO_4_3[0], EditConstants.RATIO_4_3[1]);
        break;
      case CropRatioType.RATIO_TYPE_3_4:
        this.ratio.set(EditConstants.RATIO_3_4[0], EditConstants.RATIO_3_4[1]);
        break;
      case CropRatioType.RATIO_TYPE_3_2:
        this.ratio.set(EditConstants.RATIO_3_2[0], EditConstants.RATIO_3_2[1]);
        break;
      case CropRatioType.RATIO_TYPE_2_3:
        this.ratio.set(EditConstants.RATIO_2_3[0], EditConstants.RATIO_2_3[1]);
        break;
      default:
        Log.warn(TAG, 'setRatio: unknown ratio');
        break;
    }
    if (this.ratio.isValid()) {
      MathUtils.computeMaxRectWithinLimit(this.cropRect, this.limitRect, this.ratio.getRate());
      let imageLines = this.getCurrentImageLines();
      MathUtils.limitRectInRotated(this.cropRect, imageLines);
      this.imageCropCompare();
      this.enlargeCropArea();
    }
  }

  setMaxScaleFactor(factorW: number, factorH: number) {
    this.maxScaleFactorW = factorW;
    this.maxScaleFactorH = factorH;
  }

  couldEnlargeImage(): boolean {    // 判断是否可以放大
    return (this.couldEnlargeImageW() && this.couldEnlargeImageH());
  }

  enlargeCropArea() {               // 放大裁切区域
    let newCrop = new RectF();
    let cropRatio = this.cropRect.getWidth() / this.cropRect.getHeight();
    MathUtils.computeMaxRectWithinLimit(newCrop, this.limitRect, cropRatio);
    let scale = newCrop.getWidth() / this.cropRect.getWidth();

    let tX = this.isFlipHorizontal ? -1 : 1;
    let tY = this.isFlipVertically ? -1 : 1;
    let origin = this.getDisplayCenter();
    let preCenterX = this.cropRect.getCenterX() * tX + (this.isFlipHorizontal ? 2 * origin.x : 0);
    let preCenterY = this.cropRect.getCenterY() * tY + (this.isFlipVertically ? 2 * origin.y : 0);
    let preCenter = new Point(preCenterX, preCenterY);
    let angle = this.rotationAngle * tX * tY + this.horizontalAngle;
    let rotated = MathUtils.rotatePoints([preCenter], -angle, origin);

    MathUtils.scaleRectBasedOnPoint(this.imageRect, rotated[0], scale);

    let offsetX = newCrop.getCenterX() - preCenter.x;
    let offsetY = newCrop.getCenterY() - preCenter.y;
    let alpha = MathUtils.formulaAngle(angle);
    let x = Math.cos(alpha) * offsetX + Math.sin(alpha) * offsetY;
    let y = -Math.sin(alpha) * offsetX + Math.cos(alpha) * offsetY;
    this.imageRect.move(x, y);

    this.cropRect.set(newCrop.left, newCrop.top, newCrop.right, newCrop.bottom);
  }

  imageCropCompare(): void {        // 比较图片和裁切区域的大小
    let imageRect = this.getImageRect();
    let cropRect = this.getCropRect();
    let imageRectWidth = imageRect.getWidth();
    let imageRectHeight = imageRect.getHeight();
    let cropRectWidth = cropRect.getWidth();
    let cropRectHeight = cropRect.getHeight();
    if (imageRectWidth < cropRectWidth) {
      let scaleRatio = cropRectWidth / imageRectWidth;
      this.imageRect.scale(scaleRatio);
    }
    if (imageRectHeight < cropRectHeight) {
      let scaleRatio = cropRectHeight / imageRectHeight;
      this.imageRect.scale(scaleRatio);
    }

  }

  isCropRectTouch(x: number, y: number): boolean {  // 判断触摸点是否在裁剪区域内
    let w = this.touchBound;
    let h = this.touchBound;
    let crop = this.cropRect;
    let outer = new RectF();
    outer.set(crop.left - w, crop.top - h, crop.right + w, crop.bottom + h);
    let inner = new RectF();
    inner.set(crop.left + w, crop.top + h, crop.right - w, crop.bottom - h);
    if (outer.isInRect(x, y) && !inner.isInRect(x, y)) {
      if (x <= inner.left) {
        this.isLeft = true;
      } else if (x >= inner.right) {
        this.isRight = true;
      }

      if (y <= inner.top) {
        this.isTop = true;
      } else if (y >= inner.bottom) {
        this.isBottom = true;
      }

      // convert side to conner, when fixed crop ratio
      if (this.ratio.isValid()) {
        this.fixSideToConner(x, y);
      }
      Log.debug(TAG, `isCropTouch: l[${this.isLeft}] r[${this.isRight}] t[${this.isTop}] b[${this.isBottom}]`);
    }
    return this.isLeft || this.isRight || this.isTop || this.isBottom;
  }

  getCurrentFlipImage(): RectF {
    let center = this.getDisplayCenter();
    let image = this.imageRect;
    let flipImage = new RectF();
    flipImage.left = this.isFlipHorizontal ? (2 * center.x - image.right) : image.left;
    flipImage.top = this.isFlipVertically ? (2 * center.y - image.bottom) : image.top;
    flipImage.right = this.isFlipHorizontal ? (2 * center.x - image.left) : image.right;
    flipImage.bottom = this.isFlipVertically ? (2 * center.y - image.top) : image.bottom;
    return flipImage;
  }

  moveCropRect(offsetX: number, offsetY: number) {  // 移动裁切区域
    // crop rect in fixed mode
    if (this.ratio.isValid()) {
      this.moveInFixedMode(offsetX, offsetY);
    } else {
      this.moveInFreeMode(offsetX, offsetY);
    }
  }

  endCropRectMove() {
    this.isLeft = false;
    this.isRight = false;
    this.isTop = false;
    this.isBottom = false;
    this.isHorizontalSide = false;
    this.isVerticalSide = false;
  }

  private swapCurrentRatio() {
    let W = this.ratio.getW();
    let H = this.ratio.getH();
    this.ratio.set(H, W);
  }

  private getDisplayCenter(): Point {
    return new Point(this.limitRect.getCenterX(), this.limitRect.getCenterY());
  }

  private couldEnlargeImageW(): boolean {         // 判断图片是否可以在宽度和高度上放大
    let scaleFactorW = this.imageRect.getWidth() / this.cropRect.getWidth();
    return (scaleFactorW >= this.maxScaleFactorW ? false : true);
  }
  private couldEnlargeImageH(): boolean {
    let scaleFactorH = this.imageRect.getHeight() / this.cropRect.getHeight();
    return (scaleFactorH >= this.maxScaleFactorH ? false : true);
  }

  private fixSideToConner(x: number, y: number) {   // 确定用户触摸裁剪矩形时的精确意图（是想移动边缘还是调整大小）
    if ((this.isLeft || this.isRight) && !this.isTop && !this.isBottom) {
      if (y < this.cropRect.getCenterY()) {
        this.isTop = true;
      } else {
        this.isBottom = true;
      }
      this.isVerticalSide = true;
    } else if ((this.isTop || this.isBottom) && !this.isLeft && !this.isRight) {
      if (x < this.cropRect.getCenterX()) {
        this.isLeft = true;
      } else {
        this.isRight = true;
      }
      this.isHorizontalSide = true;
    }
  }

  private getCurrentRotatedImage(): RectF {         // 旋转区域
    let flipImage = this.getCurrentFlipImage();
    let points = MathUtils.rectToPoints(flipImage);
    let origin = this.getDisplayCenter();
    let rotated = MathUtils.rotatePoints(points, this.rotationAngle, origin);
    let i = Math.abs(this.rotationAngle / CropAngle.ONE_QUARTER_CIRCLE_ANGLE);
    let j = (i + 2) % rotated.length;
    let image = new RectF();
    image.set(rotated[i].x, rotated[i].y, rotated[j].x, rotated[j].y);
    return image;
  }

  private getCurrentImageLines(): Array<LineSegment> {    // 边缘线
    let flipImage = this.getCurrentFlipImage();
    let imagePoints = MathUtils.rectToPoints(flipImage);
    let origin = this.getDisplayCenter();
    let tX = this.isFlipHorizontal ? -1 : 1;
    let tY = this.isFlipVertically ? -1 : 1;
    let angle = this.rotationAngle * tX * tY + this.horizontalAngle;
    let rotated = MathUtils.rotatePoints(imagePoints, angle, origin);

    let imageLines: LineSegment[] = [];
    for (let i = 0; i < rotated.length; i++) {
      let j = (i + 1) % rotated.length;
      imageLines.push(
        new LineSegment(new Point(rotated[i].x, rotated[i].y), new Point(rotated[j].x, rotated[j].y)));
    }
    return imageLines;
  }

  private moveInFixedMode(offsetX: number, offsetY: number) {   // 固定模式
    let x = offsetX;
    let y = offsetY;
    if (this.isHorizontalSide) {
      x = 0;
    } else if (this.isVerticalSide) {
      y = 0;
    }
    let offsetHypot = Math.hypot(x, y);

    if (this.isLeft && this.isTop) {
      // left top conner move
      let isEnlarge = offsetX < 0 || offsetY < 0;
      if (isEnlarge || this.couldEnlargeImage()) {
        this.fixLeftTopInFixedMode(offsetHypot, isEnlarge);
      }
    } else if (this.isLeft && this.isBottom) {
      // left bottom conner move
      let isEnlarge = offsetX < 0 || offsetY > 0;
      if (isEnlarge || this.couldEnlargeImage()) {
        this.fixLeftBottomInFixedMode(offsetHypot, isEnlarge);
      }
    } else if (this.isRight && this.isTop) {
      // right top conner move
      let isEnlarge = offsetX > 0 || offsetY < 0;
      if (isEnlarge || this.couldEnlargeImage()) {
        this.fixRightTopInFixedMode(offsetHypot, isEnlarge);
      }
    } else if (this.isRight && this.isBottom) {
      // right bottom conner move
      let isEnlarge = offsetX > 0 || offsetY > 0;
      if (isEnlarge || this.couldEnlargeImage()) {
        this.fixRightBottomInFixedMode(offsetHypot, isEnlarge);
      }
    }
  }

  // 在固定模式下，固定左上、左下、右上、右下角
  private fixLeftTopInFixedMode(offsetHypot: number, isEnlarge: boolean) {
    let crop = this.getCropRect();
    let rate = this.ratio.getRate();
    let rect = new RectF();
    if (isEnlarge) {
      let limit = this.limitRect;
      let size = MathUtils.getMaxFixedRectSize(rate, crop.right - limit.left, crop.bottom - limit.top);
      rect.set(crop.right - size[0], crop.bottom - size[1], crop.right, crop.bottom);
      let imageLines = this.getCurrentImageLines();
      MathUtils.limitRectInRotatedBasedOnPoint(2, rect, imageLines);
    } else {
      let size = MathUtils.getMinFixedRectSize(rate, this.minSideLength);
      rect.set(crop.right - size[0], crop.bottom - size[1], crop.right, crop.bottom);
    }
    let rectHypot = Math.hypot(rect.getWidth(), rect.getHeight());
    let cropHypot = Math.hypot(crop.getWidth(), crop.getHeight());
    let limitHypot = (rectHypot - cropHypot) * (isEnlarge ? 1 : -1);
    let finalOffsetHypot = Math.min(offsetHypot, Math.max(limitHypot, 0));
    let tX = isEnlarge ? -1 : 1;
    let tY = isEnlarge ? -1 : 1;
    let ratioHypot = Math.hypot(this.ratio.getW(), this.ratio.getH());
    this.cropRect.left += finalOffsetHypot * tX * this.ratio.getW() / ratioHypot;
    this.cropRect.top += finalOffsetHypot * tY * this.ratio.getH() / ratioHypot;
  }
  private fixLeftBottomInFixedMode(offsetHypot: number, isEnlarge: boolean) {
    let crop = this.getCropRect();
    let rate = this.ratio.getRate();
    let rect = new RectF();
    if (isEnlarge) {
      let limit = this.limitRect;
      let size = MathUtils.getMaxFixedRectSize(rate, crop.right - limit.left, limit.bottom - crop.top);
      rect.set(crop.right - size[0], crop.top, crop.right, crop.top + size[1]);
      let imageLines = this.getCurrentImageLines();
      MathUtils.limitRectInRotatedBasedOnPoint(1, rect, imageLines);
    } else {
      let size = MathUtils.getMinFixedRectSize(rate, this.minSideLength);
      rect.set(crop.right - size[0], crop.top, crop.right, crop.top + size[1]);
    }
    let rectHypot = Math.hypot(rect.getWidth(), rect.getHeight());
    let cropHypot = Math.hypot(crop.getWidth(), crop.getHeight());
    let limitHypot = (rectHypot - cropHypot) * (isEnlarge ? 1 : -1);
    let finalOffsetHypot = Math.min(offsetHypot, Math.max(limitHypot, 0));
    let tX = isEnlarge ? -1 : 1;
    let tY = isEnlarge ? 1 : -1;
    let ratioHypot = Math.hypot(this.ratio.getW(), this.ratio.getH());
    this.cropRect.left += finalOffsetHypot * tX * this.ratio.getW() / ratioHypot;
    this.cropRect.bottom += finalOffsetHypot * tY * this.ratio.getH() / ratioHypot;
  }
  private fixRightTopInFixedMode(offsetHypot: number, isEnlarge: boolean) {
    let crop = this.getCropRect();
    let rate = this.ratio.getRate();
    let rect = new RectF();
    if (isEnlarge) {
      let limit = this.limitRect;
      let size = MathUtils.getMaxFixedRectSize(rate, limit.right - crop.left, crop.bottom - limit.top);
      rect.set(crop.left, crop.bottom - size[1], crop.left + size[0], crop.bottom);
      let imageLines = this.getCurrentImageLines();
      MathUtils.limitRectInRotatedBasedOnPoint(3, rect, imageLines);
    } else {
      let size = MathUtils.getMinFixedRectSize(rate, this.minSideLength);
      rect.set(crop.left, crop.bottom - size[1], crop.left + size[0], crop.bottom);
    }
    let rectHypot = Math.hypot(rect.getWidth(), rect.getHeight());
    let cropHypot = Math.hypot(crop.getWidth(), crop.getHeight());
    let limitHypot = (rectHypot - cropHypot) * (isEnlarge ? 1 : -1);
    let finalOffsetHypot = Math.min(offsetHypot, Math.max(limitHypot, 0));
    let tX = isEnlarge ? 1 : -1;
    let tY = isEnlarge ? -1 : 1;
    let ratioHypot = Math.hypot(this.ratio.getW(), this.ratio.getH());
    this.cropRect.right += finalOffsetHypot * tX * this.ratio.getW() / ratioHypot;
    this.cropRect.top += finalOffsetHypot * tY * this.ratio.getH() / ratioHypot;
  }
  private fixRightBottomInFixedMode(offsetHypot: number, isEnlarge: boolean) {
    let crop = this.getCropRect();
    let rate = this.ratio.getRate();
    let rect = new RectF();
    if (isEnlarge) {
      let limit = this.limitRect;
      let size = MathUtils.getMaxFixedRectSize(rate, limit.right - crop.left, limit.bottom - crop.top);
      rect.set(crop.left, crop.top, crop.left + size[0], crop.top + size[1]);
      let imageLines = this.getCurrentImageLines();
      MathUtils.limitRectInRotatedBasedOnPoint(0, rect, imageLines);
    } else {
      let size = MathUtils.getMinFixedRectSize(rate, this.minSideLength);
      rect.set(crop.left, crop.top, crop.left + size[0], crop.top + size[1]);
    }
    let rectHypot = Math.hypot(rect.getWidth(), rect.getHeight());
    let cropHypot = Math.hypot(crop.getWidth(), crop.getHeight());
    let limitHypot = (rectHypot - cropHypot) * (isEnlarge ? 1 : -1);
    let finalOffsetHypot = Math.min(offsetHypot, Math.max(limitHypot, 0));
    let tX = isEnlarge ? 1 : -1;
    let tY = isEnlarge ? 1 : -1;
    let ratioHypot = Math.hypot(this.ratio.getW(), this.ratio.getH());
    this.cropRect.right += finalOffsetHypot * tX * this.ratio.getW() / ratioHypot;
    this.cropRect.bottom += finalOffsetHypot * tY * this.ratio.getH() / ratioHypot;
  }

  private moveInFreeMode(offsetX: number, offsetY: number) {    // 自由模式
    let crop = this.getCropRect();
    let limit = this.limitRect;
    let image = this.getCurrentRotatedImage();
    let minLength = this.minSideLength;
    let imageLines = this.getCurrentImageLines();
    if (this.isLeft) {
      if (offsetX < 0 || this.couldEnlargeImageW()) {
        let left = Math.min(crop.left + offsetX, crop.right - minLength);
        left = Math.max(left, image.left, limit.left);
        this.cropRect.left = this.fixLeftInFreeMode(left, crop, imageLines);
        crop.left = this.cropRect.left;
      }
    } else if (this.isRight) {
      if (offsetX > 0 || this.couldEnlargeImageW()) {
        let right = Math.max(crop.right + offsetX, crop.left + minLength);
        right = Math.min(right, image.right, limit.right);
        this.cropRect.right = this.fixRightInFreeMode(right, crop, imageLines);
        crop.right = this.cropRect.right;
      }
    }
    if (this.isTop) {
      if (offsetY < 0 || this.couldEnlargeImageH()) {
        let top = Math.min(crop.top + offsetY, crop.bottom - minLength);
        top = Math.max(top, image.top, limit.top);
        this.cropRect.top = this.fixTopInFreeMode(top, crop, imageLines);
      }
    } else if (this.isBottom) {
      if (offsetY > 0 || this.couldEnlargeImageH()) {
        let bottom = Math.max(crop.bottom + offsetY, crop.top + minLength);
        bottom = Math.min(bottom, image.bottom, limit.bottom);
        this.cropRect.bottom = this.fixBottomInFreeMode(bottom, crop, imageLines);
      }
    }
  }

  // 在自由模式下，固定左边、右边、顶部、底部
  private fixLeftInFreeMode(left: number, crop: RectF, imageLines: Array<LineSegment>): number {
    let leftLine = new LineSegment(new Point(left, crop.top), new Point(left, crop.bottom));
    let adjacentLines: LineSegment[] = [];
    adjacentLines.push(new LineSegment(new Point(left, crop.top), new Point(crop.right, crop.top)));
    adjacentLines.push(new LineSegment(new Point(left, crop.bottom), new Point(crop.right, crop.bottom)));
    let fixedLeft = left;
    for (let imageLine of imageLines) {
      if (MathUtils.hasIntersection(imageLine, leftLine)) {
        let result = this.tryToFindFixedSide(adjacentLines, imageLine, left, true, true);
        fixedLeft = Math.max(fixedLeft, result);
      }
    }
    return fixedLeft;
  }
  private fixRightInFreeMode(right: number, crop: RectF, imageLines: Array<LineSegment>): number {
    let rightLine = new LineSegment(new Point(right, crop.top), new Point(right, crop.bottom));
    let adjacentLines: LineSegment[] = [];
    adjacentLines.push(new LineSegment(new Point(crop.left, crop.top), new Point(right, crop.top)));
    adjacentLines.push(new LineSegment(new Point(crop.left, crop.bottom), new Point(right, crop.bottom)));
    let fixedRight = right;
    for (let imageLine of imageLines) {
      if (MathUtils.hasIntersection(imageLine, rightLine)) {
        let result = this.tryToFindFixedSide(adjacentLines, imageLine, right, true, false);
        fixedRight = Math.min(fixedRight, result);
      }
    }
    return fixedRight;
  }
  private fixTopInFreeMode(top: number, crop: RectF, imageLines: Array<LineSegment>): number {
    let topLine = new LineSegment(new Point(crop.left, top), new Point(crop.right, top));
    let adjacentLines: LineSegment[] = [];
    adjacentLines.push(new LineSegment(new Point(crop.left, top), new Point(crop.left, crop.bottom)));
    adjacentLines.push(new LineSegment(new Point(crop.right, top), new Point(crop.right, crop.bottom)));
    let fixedTop = top;
    for (let imageLine of imageLines) {
      if (MathUtils.hasIntersection(imageLine, topLine)) {
        let result = this.tryToFindFixedSide(adjacentLines, imageLine, top, false, true);
        fixedTop = Math.max(fixedTop, result);
      }
    }
    return fixedTop;
  }
  private fixBottomInFreeMode(bottom: number, crop: RectF, imageLines: Array<LineSegment>): number {
    let bottomLine = new LineSegment(new Point(crop.left, bottom), new Point(crop.right, bottom));
    let adjacentLines: LineSegment[] = [];
    adjacentLines.push(new LineSegment(new Point(crop.left, crop.top), new Point(crop.left, bottom)));
    adjacentLines.push(new LineSegment(new Point(crop.right, crop.top), new Point(crop.right, bottom)));
    let fixedBottom = bottom;
    for (let imageLine of imageLines) {
      if (MathUtils.hasIntersection(imageLine, bottomLine)) {
        let result = this.tryToFindFixedSide(adjacentLines, imageLine, bottom, false, false);
        fixedBottom = Math.min(fixedBottom, result);
      }
    }
    return fixedBottom;
  }

  // 尝试找到固定的边缘
  private tryToFindFixedSide(adjacentLines: Array<LineSegment>, imageLine: LineSegment, side: number, isCompareX: boolean, isCompareMax: boolean): number {
    let fixedSide = side;
    let compareFunc = isCompareMax ? Math.max : Math.min;
    for (let adjacentLine of adjacentLines) {
      if (MathUtils.hasIntersection(imageLine, adjacentLine)) {
        let intersection = MathUtils.getIntersection(imageLine, adjacentLine);
        if (intersection == undefined) {
          continue;
        }
        let compare = isCompareX ? intersection.x : intersection.y;
        fixedSide = compareFunc(side, compare);
      }
    }
    return fixedSide;
  }
}