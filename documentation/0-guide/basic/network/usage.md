# 网络使用说明

在 AIUI 中，网络能力是构建智能体（Agent）的基础。由于智能体通常需要与云端 AI 服务进行实时交互，AIUI 提供了一套高性能、低延迟的网络 API。

## 1. 支持的 API

AIUI 同时支持现代 Web 标准的 `fetch` API 以及微信小程序兼容的 `wx.request` API。

下面是同一个 POST 请求在两种 API 风格下的写法。推荐使用符合现代 Web 开发习惯的 Web API；迁移已有小程序代码时可以使用 `wx`。

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
const response = await fetch('https://api.rokid.com/v1/chat', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    query: '你好'
  })
});

if (!response.ok) {
  throw new Error(`Request failed: ${response.status}`);
}

console.log(await response.json());
```

**wx**

```javascript api-style=wx
wx.request({
  url: 'https://api.rokid.com/v1/chat',
  method: 'POST',
  header: {
    'Content-Type': 'application/json'
  },
  data: {
    query: '你好'
  },
  success(res) {
    console.log(res.data);
  },
  fail(err) {
    console.error('请求失败:', err);
  }
});
```

<!-- /aiui-api-style -->

## 2. AI 眼镜上的网络通信机制

这是一个开发者经常关心的问题：**在 AI 眼镜上，如果没有开启 Wi-Fi，智能体是如何上网的？**

### 移动 App 代理模式 (Mobile Proxy)

当 Rokid 眼镜通过蓝牙连接到手机端 App（如 Rokid AI App / Hi Rokid）时，眼镜会利用手机的数据连接进行上网。

1.  **自动路由**：当眼镜系统检测到 Wi-Fi 未连接但手机 App 在线时，所有的网络请求（`fetch`/`wx.request`）会自动通过眼镜与手机之间的链路进行转发。
2.  **无需额外配置**：对于开发者而言，这一过程是透明的。你只需要像平时一样调用 `fetch` 即可，系统底层会处理复杂的代理逻辑。
3.  **优势**：
    *   **省电**：关闭眼镜端的 Wi-Fi 芯片可以显著延长续航时间。
    *   **便捷**：利用手机已经登录好的网络环境（如 5G/4G），无需在眼镜上繁琐地输入 Wi-Fi 密码。

## 3. 注意事项

*   **HTTPS 强制要求**：为了安全起见，所有线上环境的网络请求必须使用 HTTPS 协议。
*   **域名白名单**：在发布到智能体商店前，请确保你的请求域名已在开发者后台进行报备（类似于小程序开发流程）。
*   **超时控制**：由于空间网络环境可能不稳定，建议为所有请求设置合理的超时时间。

## 4. 局域网通信 (LAN)

> [!NOTE]
> 目前局域网直连通信功能正在开发中。未来将支持眼镜直接发现并访问局域网内的其他智能设备（如 NAS 或智能家居控制台）。
