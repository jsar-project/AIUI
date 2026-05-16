import wx from 'wx';

export async function fetch(opts) {
  return new Promise((resolve, reject) => {
    wx.request({
      ...opts,
      success: resolve,
      fail: reject,
    });
  });
}
