import wx from 'wx';
import { AudioPlayer } from 'audio';

const MINIMAX_TTS_URL = 'wss://api.minimaxi.com/ws/v1/t2a_v2';
const DEFAULT_MODEL = 'speech-2.8-turbo';
const DEFAULT_VOICE_ID = 'voice_id_placeholder';
const SAMPLE_RATE = 32000;

function parseSocketMessage(message) {
  const raw = typeof message === 'string' ? message : message?.data || message;
  return JSON.parse(raw);
}

function hexToArrayBuffer(hex) {
  const buffer = new ArrayBuffer(hex.length / 2);
  const view = new Uint8Array(buffer);

  for (let i = 0; i < hex.length; i += 2) {
    view[i / 2] = parseInt(hex.slice(i, i + 2), 16);
  }

  return buffer;
}

export class TTSClient {
  constructor(options = {}) {
    this.getAuthorization = options.getAuthorization;
    this.onStatusChange = options.onStatusChange;
    this.onError = options.onError;
    this.model = options.model || DEFAULT_MODEL;
    this.voiceId = options.voiceId || DEFAULT_VOICE_ID;
    this.socket = null;
    this.player = null;
  }

  setStatus(status) {
    if (typeof this.onStatusChange === 'function') {
      this.onStatusChange(status);
    }
  }

  closeSocket() {
    if (this.socket) {
      try {
        this.socket.close();
      } catch (error) {
        console.error('Error closing TTS socket:', error);
      }
      this.socket = null;
    }
  }

  stop() {
    this.closeSocket();

    if (this.player) {
      this.player.stop();
      this.player = null;
    }

    this.setStatus('IDLE');
  }

  async play(text, options = {}) {
    if (!text) {
      throw new Error('Text is required before starting TTS playback.');
    }

    if (typeof this.getAuthorization !== 'function') {
      this.setStatus('SANITIZED');
      throw new Error(
        'Minimax TTS sample is sanitized. Provide a getAuthorization() implementation before enabling playback.'
      );
    }

    let authorization = '';
    try {
      authorization = await this.getAuthorization();
    } catch (error) {
      this.setStatus('ERROR');
      throw error;
    }

    if (!authorization) {
      this.setStatus('SANITIZED');
      throw new Error(
        'Minimax TTS sample is sanitized. The authorization provider must return a header value.'
      );
    }

    this.stop();
    this.player = new AudioPlayer({
      sampleRate: SAMPLE_RATE,
      format: 'pcm',
    });
    this.setStatus('CONNECTING');

    return new Promise((resolve, reject) => {
      let settled = false;
      let hasStartedPlayback = false;

      const finishWithError = (error) => {
        if (settled) {
          return;
        }
        settled = true;
        this.setStatus('ERROR');
        if (typeof this.onError === 'function') {
          this.onError(error);
        }
        this.closeSocket();
        reject(error);
      };

      this.socket = wx.connectSocket({
        url: MINIMAX_TTS_URL,
        header: {
          Authorization: authorization,
        },
      });

      this.socket.onOpen(() => {
        this.setStatus('CONNECTED');
        this.socket.send(
          JSON.stringify({
            event: 'task_start',
            model: this.model,
            voice_setting: {
              voice_id: this.voiceId,
              speed: 1.0,
              vol: 1.0,
              pitch: 0,
            },
            audio_setting: {
              format: 'pcm',
              sample_rate: SAMPLE_RATE,
              channel: 1,
            },
          })
        );
      });

      this.socket.onMessage((message) => {
        try {
          const data = parseSocketMessage(message);

          if (data.base_resp && data.base_resp.status_code !== 0) {
            finishWithError(new Error(data.base_resp.status_msg || 'Minimax TTS request failed.'));
            return;
          }

          if (data.event === 'task_started') {
            this.socket.send(
              JSON.stringify({
                event: 'task_continue',
                text,
              })
            );
            return;
          }

          if (data.data?.audio) {
            this.player.append(hexToArrayBuffer(data.data.audio));

            if (!hasStartedPlayback) {
              this.player.play();
              hasStartedPlayback = true;
              this.setStatus('PLAYING');
            }
          }

          if (data.is_final) {
            this.closeSocket();
            this.player.onEnded(() => {
              if (settled) {
                return;
              }
              settled = true;
              this.setStatus('IDLE');
              if (typeof options.onComplete === 'function') {
                options.onComplete();
              }
              resolve();
            });
            this.player.finish();
          }
        } catch (error) {
          finishWithError(error);
        }
      });

      this.socket.onError((error) => {
        finishWithError(new Error(error?.errMsg || 'Minimax TTS socket error.'));
      });

      this.socket.onClose(() => {
        if (!settled && !hasStartedPlayback) {
          this.setStatus('IDLE');
        }
      });
    });
  }
}
