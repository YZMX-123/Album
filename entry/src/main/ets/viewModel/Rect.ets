export class RectF {
  /**
   * Rect left edge.
   */
  left: number;

  /**
   * Rect top edge.
   */
  top: number;

  /**
   * Rect right edge.
   */
  right: number;

  /**
   * Rect bottom edge.
   */
  bottom: number;

  /**
   * Constructor.
   */
  constructor() {
    this.left = 0;
    this.top = 0;
    this.right = 0;
    this.bottom = 0;
  }

  /**
   * Set value.
   * @param left
   * @param top
   * @param right
   * @param bottom
   */
  set(left: number, top: number, right: number, bottom: number): void {
    this.left = left;
    this.top = top;
    this.right = right;
    this.bottom = bottom;
  }

  /**
   * Get width.
   * @returns
   */
  getWidth(): number {
    return (this.right - this.left);
  }

  /**
   * Get height.
   * @returns
   */
  getHeight(): number {
    return (this.bottom - this.top);
  }

  /**
   * Get diagonal.
   * @returns
   */
  getDiagonal(): number {
    return Math.hypot(this.getWidth(), this.getHeight());
  }

  /**
   * Get the center point of x.
   * @returns
   */
  getCenterX(): number {
    return (this.left + this.getWidth() / 2);
  }

  /**
   * Get the center point of y.
   * @returns
   */
  getCenterY(): number {
    return (this.top + this.getHeight() / 2);
  }

  /**
   * Determine whether it is within the rectangle.
   * @param x
   * @param y
   * @returns
   */
  isInRect(x: number, y: number): boolean {
    return (x >= this.left && x <= this.right && y >= this.top && y <= this.bottom);
  }

  /**
   * Set zoom factor.
   * @param scale
   */
  scale(scale: number): void {
    this.left *= scale;
    this.right *= scale;
    this.top *= scale;
    this.bottom *= scale;
  }

  /**
   * Move by current offset.
   * @param offsetX
   * @param offsetY
   */
  move(offsetX: number, offsetY: number): void {
    this.left += offsetX;
    this.right += offsetX;
    this.top += offsetY;
    this.bottom += offsetY;
  }
}