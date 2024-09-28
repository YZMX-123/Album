import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { ScreenManager } from '../viewModel/ScreenManager';

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    window.getLastWindow(this.context, (err, window) => { ///////
      if (err) {
        hilog.error(0x0000, 'testTag', '%{public}s', `window loading has error: ${JSON.stringify(err)}`);
      }
      // AppStorage.SetOrCreate('statusBar', window.getWindowProperties().windowRect?.top);
      // AppStorage.SetOrCreate('statusBar', 72);
      AppStorage.SetOrCreate('statusBar', 56);
    });
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    const permissions: Array<Permissions> = [
      'ohos.permission.READ_MEDIA',
      'ohos.permission.WRITE_MEDIA',
      'ohos.permission.MEDIA_LOCATION'
    ];
    const atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(this.context, permissions, (err, data) => {
      if (!err) {
        hilog.error(0x0000, 'testTag', 'Failed to requestPermission. Cause: %{public}s',
          JSON.stringify(err) ?? '');
      } else {
        hilog.info(0x0000, 'testTag', 'Succeeded in requestPermission. Data: %{public}s',
          JSON.stringify(data) ?? '');
      }
    })

    windowStage.getMainWindow().then((win) => {
      AppStorage.SetOrCreate('mainWindow', win);
      ScreenManager.getInstance().getAvoidArea();
      ScreenManager.getInstance().initializationSize(win).then(() => {
        ScreenManager.getInstance().initWindowMode();
      }).catch(() => {
        hilog.error(0x0000,'testTag', `get device screen info failed.`);
      });
    });

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
