import { NativeModule, requireNativeModule } from 'expo';

import { BoldLockModuleEvents } from './BoldLock.types';

declare class BoldLockModule extends NativeModule<BoldLockModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<BoldLockModule>('BoldLock');
