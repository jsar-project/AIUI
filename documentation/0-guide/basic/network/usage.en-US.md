# Network Usage Guide

In AIUI, network capability is the foundation for building agents. Since agents usually need to interact with cloud AI services in real time, AIUI provides a set of high-performance, low-latency network APIs.

## 1. Supported APIs

AIUI supports both the modern Web-standard `fetch` API and the WeChat Mini Program-compatible `wx.request` API.

The following example sends the same POST request in both API styles. The Web API is recommended for modern development; use `wx` when migrating existing mini-program code.

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
const response = await fetch('https://api.rokid.com/v1/chat', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    query: 'Hello'
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
    query: 'Hello'
  },
  success(res) {
    console.log(res.data);
  },
  fail(err) {
    console.error('Request failed:', err);
  }
});
```

<!-- /aiui-api-style -->

## 2. Network Communication on AI Glasses

This is a question developers often ask: **on AI glasses, if Wi-Fi is not enabled, how does the agent get online?**

### Mobile App Proxy Mode

When Rokid glasses are connected to a mobile app such as Rokid AI App or Hi Rokid through Bluetooth, the glasses can use the phone's data connection to access the internet.

1.  **Automatic routing**: When the glasses detect that Wi-Fi is disconnected but the mobile app is online, all network requests (`fetch` / `wx.request`) are automatically forwarded through the link between the glasses and the phone.
2.  **No extra configuration required**: This process is transparent to developers. You can simply call `fetch` as usual, and the system handles the underlying proxy logic.
3.  **Advantages**:
    *   **Power saving**: Turning off the Wi-Fi chip on the glasses can significantly extend battery life.
    *   **Convenience**: You can use the phone's existing network connection, such as 5G or 4G, without entering Wi-Fi passwords on the glasses.

## 3. Notes

*   **HTTPS is required**: For security reasons, all network requests in production environments must use HTTPS.
*   **Domain allowlist**: Before publishing to the agent store, make sure your request domains are registered in the developer console, similar to the mini-program workflow.
*   **Timeout control**: Because network conditions in spatial computing scenarios may be unstable, it is recommended to set reasonable timeouts for all requests.

## 4. LAN Communication

> [!NOTE]
> Direct LAN communication is currently under development. In the future, the glasses will support discovering and accessing other smart devices on the local network, such as a NAS or a smart home controller.
