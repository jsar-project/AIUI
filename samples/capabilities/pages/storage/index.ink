<script setup>
  import wx from 'wx';

  const DRAFT_KEY = 'storage-demo.daily-brief';
  const OPFS_DIRECTORY = 'drafts';
  const OPFS_FILE_NAME = 'daily-brief.txt';
  const OPFS_FILE_PATH = `${OPFS_DIRECTORY}/${OPFS_FILE_NAME}`;

  export default {
    data: {
      draftTitle: 'Morning briefing',
      draftBody: 'Remember to sync the summary card before the next review.',
      savedAt: 'Not saved yet',
      result: '草稿会保存在本地存储中，适合离线恢复最近一次编辑内容。',
      resultType: 'info',
      opfsPath: OPFS_FILE_PATH,
      opfsSavedAt: 'Not saved yet',
      opfsResult: 'OPFS 适合把草稿当成文件保存，便于后续扩展成多文件或附件工作流。',
      opfsResultType: 'info',
      opfsPreview: 'No file loaded yet.',
    },

    onTitleInput(e) {
      this.setData({ draftTitle: e.currentTarget.value });
    },

    onBodyInput(e) {
      this.setData({ draftBody: e.currentTarget.value });
    },

    onLoad() {
      this.loadDraft();
      this.loadOpfsDraft();
    },

    buildOpfsDraftText() {
      return `${this.data.draftTitle}\n\n${this.data.draftBody}`;
    },

    parseOpfsDraftText(text) {
      const separator = '\n\n';
      const index = text.indexOf(separator);
      if (index === -1) {
        return {
          title: text.trim() || 'Untitled draft',
          body: '',
        };
      }
      return {
        title: text.slice(0, index).trim() || 'Untitled draft',
        body: text.slice(index + separator.length),
      };
    },

    async getOpfsDirectoryHandle(create) {
      const root = await navigator.storage.getDirectory();
      return root.getDirectoryHandle(OPFS_DIRECTORY, { create });
    },

    async getOpfsFileHandle(create) {
      const directory = await this.getOpfsDirectoryHandle(create);
      return directory.getFileHandle(OPFS_FILE_NAME, { create });
    },

    isNotFoundError(error) {
      return Boolean(
        error &&
          (error.name === 'NotFoundError' ||
            String(error).includes('NotFoundError') ||
            String(error).includes('not found'))
      );
    },

    saveDraft() {
      try {
        const payload = {
          title: this.data.draftTitle,
          body: this.data.draftBody,
          savedAt: new Date().toISOString(),
        };
        wx.setStorageSync(DRAFT_KEY, payload);
        this.setData({
          savedAt: payload.savedAt,
          resultType: 'success',
          result: '本地草稿已保存，下次进入页面时可以继续恢复。',
        });
      } catch (error) {
        this.setData({
          resultType: 'error',
          result: `保存失败：${String(error)}`,
        });
      }
    },

    loadDraft() {
      try {
        const payload = wx.getStorageSync(DRAFT_KEY);
        if (!payload || !payload.title) {
          this.setData({
            resultType: 'info',
            result: '当前还没有已保存的草稿。',
          });
          return;
        }
        this.setData({
          draftTitle: payload.title,
          draftBody: payload.body || '',
          savedAt: payload.savedAt || 'Unknown time',
          resultType: 'success',
          result: '最近一次保存的草稿已恢复。',
        });
      } catch (error) {
        this.setData({
          resultType: 'error',
          result: `读取失败：${String(error)}`,
        });
      }
    },

    clearDraft() {
      try {
        wx.removeStorageSync(DRAFT_KEY);
        this.setData({
          savedAt: 'Not saved yet',
          resultType: 'success',
          result: '本地草稿已移除。',
        });
      } catch (error) {
        this.setData({
          resultType: 'error',
          result: `清除失败：${String(error)}`,
        });
      }
    },

    async saveOpfsDraft() {
      try {
        const fileHandle = await this.getOpfsFileHandle(true);
        const writable = await fileHandle.createWritable();
        await writable.write(this.buildOpfsDraftText());
        await writable.close();
        const file = await fileHandle.getFile();
        this.setData({
          opfsSavedAt: new Date(file.lastModified).toISOString(),
          opfsPreview: this.buildOpfsDraftText(),
          opfsResultType: 'success',
          opfsResult: 'OPFS 文件草稿已保存，适合后续扩展成多文件工作区。',
        });
      } catch (error) {
        this.setData({
          opfsResultType: 'error',
          opfsResult: `OPFS 保存失败：${String(error)}`,
        });
      }
    },

    async loadOpfsDraft() {
      try {
        const fileHandle = await this.getOpfsFileHandle(false);
        const file = await fileHandle.getFile();
        const bytes = new Uint8Array(await file.arrayBuffer());
        const text = new TextDecoder().decode(bytes);
        const payload = this.parseOpfsDraftText(text);
        this.setData({
          draftTitle: payload.title,
          draftBody: payload.body,
          opfsSavedAt: new Date(file.lastModified).toISOString(),
          opfsPreview: text,
          opfsResultType: 'success',
          opfsResult: '已从 OPFS 文件恢复草稿内容。',
        });
      } catch (error) {
        if (this.isNotFoundError(error)) {
          this.setData({
            opfsResultType: 'info',
            opfsResult: '当前还没有 OPFS 草稿文件。',
            opfsPreview: 'No file loaded yet.',
          });
          return;
        }
        this.setData({
          opfsResultType: 'error',
          opfsResult: `OPFS 读取失败：${String(error)}`,
        });
      }
    },

    async deleteOpfsDraft() {
      try {
        const directory = await this.getOpfsDirectoryHandle(false);
        await directory.removeEntry(OPFS_FILE_NAME, {});
        this.setData({
          opfsSavedAt: 'Not saved yet',
          opfsPreview: 'No file loaded yet.',
          opfsResultType: 'success',
          opfsResult: 'OPFS 草稿文件已删除。',
        });
      } catch (error) {
        if (this.isNotFoundError(error)) {
          this.setData({
            opfsResultType: 'info',
            opfsResult: '当前没有可删除的 OPFS 草稿文件。',
            opfsPreview: 'No file loaded yet.',
          });
          return;
        }
        this.setData({
          opfsResultType: 'error',
          opfsResult: `OPFS 删除失败：${String(error)}`,
        });
      }
    },
  };
</script>

<page>
  <view class="container">
    <view class="page-title">Draft Storage Showcase</view>
    <text class="page-description">
      用同一份草稿内容对照展示 KV Storage 和 OPFS：前者适合结构化小数据，后者适合文件化持久化。
    </text>

    <view class="card section">
      <view class="title">Draft Title</view>
      <input
        class="text-input"
        value="{{draftTitle}}"
        placeholder="输入草稿标题"
        bindinput="onTitleInput"
      />

      <text class="label">Draft Body</text>
      <textarea
        class="text-area"
        value="{{draftBody}}"
        placeholder="输入草稿内容"
        bindinput="onBodyInput"
      />
    </view>

    <view class="card section">
      <view class="title">KV Storage Actions</view>
      <view class="btn-row" role="navigation">
        <button class="btn btn-primary" bindtap="saveDraft">Save Draft</button>
        <button class="btn btn-secondary" bindtap="loadDraft">Load Draft</button>
      </view>
      <view class="btn-row" role="navigation">
        <button class="btn btn-secondary" bindtap="clearDraft">Clear Draft</button>
      </view>
      <text class="hint">Storage Key: storage-demo.daily-brief</text>
      <text class="hint">Last Saved At: {{savedAt}}</text>
      <view class="result-box result-{{resultType}}">
        <text class="result-text">{{result}}</text>
      </view>
    </view>

    <view class="card section">
      <view class="title">OPFS File Draft</view>
      <text class="hint">File Path: {{opfsPath}}</text>
      <text class="hint">Last Saved At: {{opfsSavedAt}}</text>
      <view class="btn-row" role="navigation">
        <button class="btn btn-primary" bindtap="saveOpfsDraft">Save File</button>
        <button class="btn btn-secondary" bindtap="loadOpfsDraft">Load File</button>
      </view>
      <view class="btn-row" role="navigation">
        <button class="btn btn-secondary" bindtap="deleteOpfsDraft">Delete File</button>
      </view>
      <view class="result-box result-{{opfsResultType}}">
        <text class="result-text">{{opfsResult}}</text>
      </view>
      <text class="label preview-label">File Preview</text>
      <view class="preview-box">
        <text class="preview-text">{{opfsPreview}}</text>
      </view>
    </view>
  </view>
</page>

<style>
  .container {
    display: flex;
    flex-direction: column;
    padding: var(--theme-padding, 20px);
  }

  .page-title {
    font-size: 24px;
    font-weight: bold;
    margin-bottom: 8px;
  }

  .page-description {
    font-size: 14px;
    margin-bottom: var(--spacing-lg, 20px);
  }

  .card {
    border: var(--theme-border);
    border-radius: var(--theme-radius, 12px);
    padding: var(--card-padding, 16px);
    margin-bottom: var(--spacing-lg, 20px);
  }

  .section {
    flex-direction: column;
  }

  .title {
    font-size: 16px;
    font-weight: bold;
    margin-bottom: var(--spacing-md, 12px);
    padding-bottom: 8px;
    border-bottom: var(--border-width-default, 2px) solid var(--border-color-accent, var(--theme-color, #1989fa));
  }

  .label {
    font-size: 13px;
    font-weight: bold;
    margin-bottom: 6px;
  }

  .text-input {
    width: 100%;
    border: var(--input-border-width, var(--border-width-thin, 1px)) solid var(--input-border-color, var(--border-color-default, #d0d0d0));
    border-radius: var(--input-radius, 8px);
    box-sizing: border-box;
    padding: var(--input-padding-y, 10px) var(--input-padding-x, 14px);
    font-size: 15px;
    margin-bottom: var(--spacing-md, 12px);
  }

  .text-area {
    width: 100%;
    min-height: 88px;
    border: var(--input-border-width, var(--border-width-thin, 1px)) solid var(--input-border-color, var(--border-color-default, #d0d0d0));
    border-radius: var(--input-radius, 8px);
    box-sizing: border-box;
    padding: var(--input-padding-y, 10px) var(--input-padding-x, 14px);
    font-size: 15px;
  }

  .btn-row {
    flex-direction: row;
    margin-top: 8px;
    margin-bottom: 4px;
  }

  .btn {
    padding: 10px var(--spacing-lg, 20px);
    font-size: 14px;
    font-weight: bold;
    margin-right: 10px;
    text-align: center;
  }

  .hint {
    font-size: 13px;
    margin-bottom: 6px;
  }

  .result-box {
    border-radius: var(--radius-sm, 8px);
    padding: var(--theme-padding, 12px);
  }

  .result-info {
    border: var(--border-width-thin, 1px) solid var(--border-color-default, #d0d0d0);
  }

  .result-success {
    border: var(--border-width-thin, 1px) solid var(--border-color-success, var(--theme-color, #34c759));
  }

  .result-error {
    border: var(--border-width-thin, 1px) solid var(--border-color-danger, #ff3b30);
  }

  .result-text {
    font-size: 14px;
  }

  .preview-label {
    margin-top: 12px;
  }

  .preview-box {
    border: var(--input-border-width, var(--border-width-thin, 1px)) solid var(--input-border-color, var(--border-color-default, #d0d0d0));
    border-radius: var(--input-radius, 8px);
    padding: var(--theme-padding, 12px);
    min-height: 72px;
  }

  .preview-text {
    font-size: 13px;
    white-space: pre-wrap;
  }

</style>
