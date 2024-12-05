import { requireNativeView } from 'expo';
import * as React from 'react';

import { BoldLockViewProps } from './BoldLock.types';

const NativeView: React.ComponentType<BoldLockViewProps> =
  requireNativeView('BoldLock');

export default function BoldLockView(props: BoldLockViewProps) {
  return <NativeView {...props} />;
}
