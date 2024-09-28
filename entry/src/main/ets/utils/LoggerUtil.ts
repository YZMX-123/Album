import hilog from '@ohos.hilog';

const LOGGER_PREFIX: string = 'Album'; // 日志记录的前缀

// 封装log记录
class Logger {
  private domain: number;   // 服务域
  private prefix: string;   // log标签
  private format: string = '%{public}s, %{public}s'; // log格式 两个字符串

  // 构造函数
  constructor(prefix: string = '', domain: number = 0xFF00) {
    this.prefix = prefix;
    this.domain = domain;
  }

  debug(...args: Object[]): void {
    hilog.debug(this.domain, this.prefix, this.format, args);
  }
  info(...args: Object[]): void {
    hilog.info(this.domain, this.prefix, this.format, args);
  }
  warn(...args: Object[]): void {
    hilog.warn(this.domain, this.prefix, this.format, args);
  }
  error(...args: Object[]): void {
    hilog.error(this.domain, this.prefix, this.format, args);
  }
}

export default new Logger(LOGGER_PREFIX); // 实例