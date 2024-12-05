import { registerWebModule, NativeModule } from 'expo';

import { ChangeEventPayload } from './BoldLock.types';

type BoldLockModuleEvents = {
  onChange: (params: ChangeEventPayload) => void;
}

class BoldLockModule extends NativeModule<BoldLockModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
};

export default registerWebModule(BoldLockModule);
