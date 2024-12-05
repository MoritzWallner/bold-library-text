// Reexport the native module. On web, it will be resolved to BoldLockModule.web.ts
// and on native platforms to BoldLockModule.ts
export { default } from './src/BoldLockModule';
export { default as BoldLockView } from './src/BoldLockView';
export * from  './src/BoldLock.types';
