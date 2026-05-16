<script type="application/json" def>
{
  "navigationBarTitleText": "Barcode Scanner"
}
</script>

<script setup>
import wx from 'wx';
import BarcodeDetector from 'barcode';
import { decodeWebP } from '../../lib/webp.js';

function isWebPMimeType(mimeType) {
  return String(mimeType || '').toLowerCase().includes('webp');
}

async function toBarcodeInput(photo) {
  if (!photo?.data) {
    throw new Error('Camera did not return image data.');
  }

  const mimeType = String(photo?.mimeType || '').toLowerCase();

  if (isWebPMimeType(mimeType)) {
    const decoded = await decodeWebP(photo.data, { output: 'gray' });
    return {
      data: decoded.gray,
      width: decoded.width,
      height: decoded.height,
    };
  }

  throw new Error(`Unsupported photo mimeType for barcode scanning: ${mimeType || 'unknown'}.`);
}

function toResultText(results) {
  if (!results || results.length === 0) {
    return 'No barcode detected.';
  }

  const first = results[0];
  const rawValue = String(first?.rawValue || '').trim();
  const format = String(first?.format || '').trim();

  if (rawValue && format) {
    return results.length > 1 ? `${rawValue} (${format}, +${results.length - 1} more)` : `${rawValue} (${format})`;
  }

  if (rawValue) {
    return results.length > 1 ? `${rawValue} (+${results.length - 1} more)` : rawValue;
  }

  if (format) {
    return results.length > 1 ? `${format} (+${results.length - 1} more)` : format;
  }

  return 'Barcode detected.';
}

export default {
  data: {
    status: 'READY',
    errorMessage: '',
    scanResultText: '',
    isScanning: false,
  },

  onShow() {
    this.cameraCtx = wx.media.createCameraContext();
  },

  onHide() {
    this.cameraCtx = null;
  },

  onKeyDown(event) {
    if (event?.code === 'Backspace') {
      wx.exitMiniProgram();
      return;
    }

    if (event?.code !== 'Enter' || this.data.isScanning) {
      return;
    }

    this.scanBarcode();
  },

  async capturePhoto() {
    if (!this.cameraCtx) {
      this.cameraCtx = wx.media.createCameraContext();
    }

    if (!this.cameraCtx) {
      throw new Error('Camera is unavailable.');
    }

    const photo = await this.cameraCtx.takePhoto({ quality: 'high' });
    return { photo };
  },

  async scanBarcode() {
    this.setData({
      status: 'DECODING',
      errorMessage: '',
      scanResultText: '',
      isScanning: true,
    });

    try {
      const { photo } = await this.capturePhoto();
      const barcodeInput = await toBarcodeInput(photo);
      const detector = new BarcodeDetector();
      const results = await detector.detect(barcodeInput);

      this.setData({
        status: 'DONE',
        scanResultText: toResultText(results),
        errorMessage: '',
      });
    } catch (error) {
      this.setData({
        status: 'ERROR',
        scanResultText: '',
        errorMessage: error?.message || 'Failed to scan barcode.',
      });
    } finally {
      this.setData({
        isScanning: false,
      });
    }
  },
};
</script>

<page>
  <view class="page">
    <view class="header">
      <text class="title">Barcode Scanner</text>
      <text class="subtitle">Press the glasses button to scan. Press Back to exit.</text>
    </view>

    <camera class="camera-preview"></camera>

    <view class="feedback">
      <text class="status-text" ink:if="{{status === 'DECODING'}}">Decoding...</text>
      <text class="error-text" ink:if="{{errorMessage}}">{{errorMessage}}</text>

      <view class="result-block" ink:if="{{scanResultText}}">
        <text class="result-label">Result</text>
        <text class="result-text">{{scanResultText}}</text>
      </view>
    </view>
  </view>
</page>

<style>
  .page {
    min-height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    gap: 20px;
    padding: 24px;
    box-sizing: border-box;
    background: #050505;
    color: #f5f7fa;
  }

  .header {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
    max-width: 420px;
  }

  .title {
    font-size: 22px;
    font-weight: 600;
    margin-bottom: 4px;
    text-align: center;
  }

  .subtitle {
    font-size: 14px;
    line-height: 20px;
    color: #b6bcc8;
    text-align: center;
  }

  .camera-preview {
    width: 100%;
    max-width: 420px;
    height: 260px;
    border-radius: 16px;
    overflow: hidden;
    background: #000000;
    border: 1px solid #2b2f36;
  }

  .feedback {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
    max-width: 420px;
  }

  .status-text {
    font-size: 14px;
    color: #8ca0c2;
  }

  .error-text {
    font-size: 14px;
    color: #ff8f8f;
    line-height: 20px;
    width: 100%;
    text-align: center;
  }

  .result-block {
    display: flex;
    flex-direction: column;
    width: 100%;
    margin-top: 16px;
    padding: 14px 16px;
    border-radius: 16px;
    background: #111418;
    border: 1px solid #2b2f36;
  }

  .result-label {
    font-size: 12px;
    text-transform: uppercase;
    color: #8ca0c2;
    margin-bottom: 8px;
  }

  .result-text {
    font-size: 18px;
    line-height: 24px;
    color: #f5f7fa;
    word-break: break-all;
  }
</style>
