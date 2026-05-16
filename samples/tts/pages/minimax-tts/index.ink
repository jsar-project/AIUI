<script type="application/json" def>
{
  "navigationBarTitleText": "Minimax TTS Demo"
}
</script>

<script setup>
import wx from 'wx';
import { TTSClient } from '../../lib/tts.js';

export default {
  data: {
    text: 'Hello from the Minimax TTS sample.',
    status: 'IDLE',
    errorMessage: '',
  },

  onLoad() {
    this.ttsClient = new TTSClient({
      onStatusChange: (status) => {
        this.setData({ status });
      },
      onError: (error) => {
        this.setData({
          errorMessage: error?.message || 'TTS playback failed.',
        });
      },
    });
  },

  onUnload() {
    if (this.ttsClient) {
      this.ttsClient.stop();
      this.ttsClient = null;
    }
  },

  onTextInput(event) {
    this.setData({
      text: event.currentTarget.value,
    });
  },

  async playTts() {
    this.setData({
      errorMessage: '',
    });

    try {
      await this.ttsClient.play(this.data.text);
    } catch (error) {
      this.setData({
        status: this.data.status === 'IDLE' ? 'ERROR' : this.data.status,
        errorMessage:
          error?.message ||
          'Minimax TTS sample is sanitized. Provide an authorization provider before enabling playback.',
      });
    }
  },

  stopTts() {
    if (this.ttsClient) {
      this.ttsClient.stop();
    }
  },
};
</script>

<page>
  <view class="page">
    <view class="header">
      <text class="title">Minimax TTS Demo</text>
      <text class="subtitle">This sample keeps the WebSocket and PCM playback flow, but requires you to inject authorization before it can run.</text>
    </view>

    <view class="card">
      <text class="section-title">Input Text</text>
      <textarea
        class="text-input"
        value="{{text}}"
        maxlength="280"
        bindinput="onTextInput"
        placeholder="Type the text you want to synthesize"
      />
    </view>

    <view class="actions">
      <button class="primary-button" bindtap="playTts">Play</button>
      <button class="secondary-button" bindtap="stopTts">Stop</button>
    </view>

    <view class="card">
      <text class="section-title">Status</text>
      <text class="status-line">{{status}}</text>
      <text class="hint-text">No credentials are bundled in this repository. Wire in your own authorization provider before enabling live playback.</text>
      <text class="error-text" ink:if="{{errorMessage}}">{{errorMessage}}</text>
    </view>
  </view>
</page>

<style>
  .page {
    min-height: 100%;
    padding: 24px;
    box-sizing: border-box;
    background: #050505;
    color: #f5f7fa;
  }

  .header {
    display: flex;
    flex-direction: column;
    margin-bottom: 20px;
  }

  .title {
    font-size: 24px;
    font-weight: 600;
    margin-bottom: 6px;
  }

  .subtitle {
    font-size: 13px;
    line-height: 18px;
    color: #b6bcc8;
  }

  .card {
    display: flex;
    flex-direction: column;
    padding: 16px;
    margin-bottom: 16px;
    border: 1px solid #2b2f36;
    border-radius: 16px;
    background: #111418;
  }

  .section-title {
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 12px;
  }

  .text-input {
    width: 100%;
    min-height: 132px;
    padding: 12px;
    box-sizing: border-box;
    border-radius: 12px;
    background: #050505;
    color: #f5f7fa;
    border: 1px solid #303643;
  }

  .actions {
    display: flex;
    flex-direction: row;
    gap: 12px;
    margin-bottom: 16px;
  }

  .primary-button,
  .secondary-button {
    flex: 1;
    font-size: 14px;
    border-radius: 999px;
  }

  .primary-button {
    background: #f2f4f8;
    color: #111418;
  }

  .secondary-button {
    background: #1b2027;
    color: #f5f7fa;
    border: 1px solid #303643;
  }

  .status-line {
    font-size: 14px;
    margin-bottom: 8px;
    color: #dfe5ef;
  }

  .hint-text {
    font-size: 13px;
    line-height: 18px;
    color: #b6bcc8;
  }

  .error-text {
    margin-top: 10px;
    font-size: 13px;
    color: #ff8f8f;
  }
</style>
