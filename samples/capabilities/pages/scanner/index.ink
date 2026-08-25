<script type="application/json" def>
{
  "navigationBarTitleText": "Scanner"
}
</script>

<script setup>
import { BarcodeDetector } from 'barcode';

export default {
  data: {
    enabled: false,
    previewReady: false,
    previewSrc: '',
    results: [],
    error: '',
    buttonLabel: 'Enable',
    resultDialogVisible: false,
    resultDialogTitle: '',
    resultDialogMessage: '',
  },

  onLoad() {
    this.stream = null;
    this.previewUrl = '';
    this.imageCapture = null;
    this.detector = null;
    this.captureBusy = false;
    this.nextCaptureAt = 0;
    this.scannerSession = 0;
    this.init();
  },

  onUnload() {
    this.stopScanner(true);
  },

  onHide() {
    this.stopScanner(true);
  },

  async init() {
    try {
      this.detector = new BarcodeDetector();
    } catch (error) {
      this.setData({ error: String(error) });
    }
  },

  async toggleScanner() {
    if (this.data.enabled) {
      this.stopScanner(false);
      return;
    }
    const mediaDevices = typeof navigator !== 'undefined' ? navigator.mediaDevices : null;
    if (!mediaDevices || typeof mediaDevices.getUserMedia !== 'function') {
      this.setData({ error: 'Camera is unavailable' });
      return;
    }
    try {
      this.setData({ error: '' });
      const session = ++this.scannerSession;
      const stream = await mediaDevices.getUserMedia({
        audio: false,
        video: { facingMode: 'environment', width: 640, height: 360 },
      });
      if (session !== this.scannerSession) {
        stream.getTracks().forEach((track) => track && track.stop && track.stop());
        return;
      }
      if (typeof URL === 'undefined' || typeof URL.createObjectURL !== 'function') {
        throw new Error('MediaStream preview is unavailable');
      }
      const videoTrack = stream.getVideoTracks()[0];
      if (!videoTrack) throw new Error('Camera returned no video track');
      this.stream = stream;
      this.imageCapture = new ImageCapture(videoTrack);
      this.previewUrl = URL.createObjectURL(stream);
      this.setData({ enabled: true, previewReady: true, previewSrc: this.previewUrl, buttonLabel: 'Disable', results: [], resultDialogVisible: false });
    } catch (error) {
      this.setData({ enabled: false, previewReady: false, previewSrc: '', buttonLabel: 'Enable', error: String(error) });
    }
  },

  stopScanner(silent = false) {
    this.scannerSession += 1;
    if (this.stream && typeof this.stream.getTracks === 'function') {
      this.stream.getTracks().forEach((track) => track && track.stop && track.stop());
    }
    this.stream = null;
    this.imageCapture = null;
    if (this.previewUrl && typeof URL !== 'undefined' && typeof URL.revokeObjectURL === 'function') {
      URL.revokeObjectURL(this.previewUrl);
    }
    this.previewUrl = '';
    this.setData({ enabled: false, previewReady: false, previewSrc: '', buttonLabel: 'Enable' });
    if (!silent) this.setData({ error: '' });
  },

  async captureAndDetect() {
    if (!this.data.enabled || !this.data.previewReady || this.captureBusy) return;
    if (Date.now() < this.nextCaptureAt) return;
    this.nextCaptureAt = Date.now() + 1200;
    if (!this.imageCapture || typeof this.imageCapture.grabFrame !== 'function') {
      this.setData({ error: 'Camera capture is unavailable' });
      return;
    }
    if (!this.detector || typeof this.detector.detect !== 'function') {
      this.setData({ error: 'Barcode detection is unavailable' });
      return;
    }
    this.captureBusy = true;
    try {
      this.setData({ error: '' });
      const frame = await this.imageCapture.grabFrame();
      let detections;
      try {
        detections = await this.detector.detect(frame);
      } finally {
        frame.close();
      }
      const detected = detections.length > 0;
      this.setData({
        results: detections.map((item) => ({ format: item.format || 'unknown', value: item.rawValue || '' })),
        error: detected ? '' : 'No code detected',
        resultDialogVisible: true,
        resultDialogTitle: detected ? 'Recognition result' : 'Recognition failed',
        resultDialogMessage: detected
          ? detections.map((item) => `${item.format || 'unknown'}: ${item.rawValue || ''}`).join('\n')
          : 'No code detected',
      });
    } catch (error) {
      const message = String(error);
      this.setData({ error: message, resultDialogVisible: true, resultDialogTitle: 'Recognition failed', resultDialogMessage: message });
    } finally {
      this.captureBusy = false;
    }
  },

  onKeyDown(event) {
    if (event && event.code === 'Enter') this.captureAndDetect();
  },

  closeResultDialog() {
    this.setData({ resultDialogVisible: false });
  },

};
</script>

<page>
  <view class="container" bindkeydown="onKeyDown">
    <view class="preview-frame" bindtap="captureAndDetect">
      <video
        class="preview-video {{previewReady ? 'preview-visible' : 'preview-hidden'}}"
        src="{{previewSrc}}"
        autoplay
        muted
        object-fit="cover"
        render-mode="wireframe"
        wireframe-quality="low"
      />
    </view>
    <button class="toggle-button" bindtap="toggleScanner">{{buttonLabel}}</button>
    <text class="error" ink:if="{{error}}">{{error}}</text>
    <view class="dialog-backdrop" ink:if="{{resultDialogVisible}}">
      <view class="result-dialog">
        <text class="dialog-title">{{resultDialogTitle}}</text>
        <text class="dialog-message">{{resultDialogMessage}}</text>
        <button class="dialog-close" bindtap="closeResultDialog">Close</button>
      </view>
    </view>
  </view>
</page>

<style>
  .container { position: relative; display: flex; flex-direction: column; gap: 16px; padding: 24px; background-color: var(--color-background, #f5f7fa); }
  .preview-frame { width: 100%; max-width: 420px; height: 220px; align-self: center; display: flex; align-items: center; justify-content: center; }
  .preview-video { width: 210px; height: 110px; overflow: hidden; border-radius: 6px; background-color: #0f172a; }
  .preview-hidden { visibility: hidden; }
  .preview-visible { visibility: visible; }
  .toggle-button { min-height: 48px; color: var(--color-primary, #2563eb); background-color: transparent; border: 2px solid var(--color-primary, #2563eb); }
  .results { display: flex; flex-direction: column; gap: 8px; }
  .result { padding: 10px 12px; color: var(--color-text-primary, #0f172a); background-color: var(--color-surface, #ffffff); }
  .error { color: var(--color-danger, #dc2626); font-size: 13px; }
  .dialog-backdrop { position: absolute; top: 0; right: 0; bottom: 0; left: 0; display: flex; align-items: center; justify-content: center; background-color: rgba(15, 23, 42, 0.45); }
  .result-dialog { display: flex; flex-direction: column; gap: 14px; width: 80%; max-width: 360px; padding: 20px; border: 1px solid var(--color-primary, #2563eb); background-color: var(--color-background, #f5f7fa); }
  .dialog-title { font-size: 18px; font-weight: 700; color: var(--color-text-primary, #0f172a); }
  .dialog-message { white-space: pre-wrap; color: var(--color-text-primary, #0f172a); }
  .dialog-close { color: var(--color-primary, #2563eb); background-color: transparent; border: 1px solid var(--color-primary, #2563eb); }
</style>
