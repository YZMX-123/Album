import hilog from '@ohos.hilog';
import worker, { ThreadWorkerGlobalScope, MessageEvents, ErrorEvent } from '@ohos.worker';
import { adjustSaturation } from '../utils/AdjustUtil';

// Web Worker 在后台线程上调节图像饱和度
let workerPort: ThreadWorkerGlobalScope = worker.workerPort;

workerPort.onmessage = function (event: MessageEvents) {
  let bufferArray = event.data.buf;
  let last = event.data.last;
  let cur = event.data.cur;
  let buffer = adjustSaturation(bufferArray, last, cur)
  // 调用AdjustUtil工具模块中定义的adjustSaturation函数来处理图像数据
  workerPort.postMessage(buffer);
  workerPort.close();
}
workerPort.onmessageerror = function (event: MessageEvents) {
  hilog.error(0x0000, 'AdjustSaturationWork', 'Failed to load the content. Cause: %{public}s', `on message error ${JSON.stringify(event)}`);
}
workerPort.onerror = function (error: ErrorEvent) {
  hilog.error(0x0000, 'AdjustSaturationWork', 'Failed to load the content. Cause: %{public}s', `on worker error ${JSON.stringify(error)}`);
}