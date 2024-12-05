import * as React from 'react';

import { BoldLockViewProps } from './BoldLock.types';

export default function BoldLockView(props: BoldLockViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
