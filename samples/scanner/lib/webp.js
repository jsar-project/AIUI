import webpjsSource from './vendor/webpjs/webpjs.source.js';

let WebPDecoderClass = null;

function toUint8Array(data) {
  if (data instanceof Uint8Array) {
    return data;
  }

  if (data instanceof ArrayBuffer) {
    return new Uint8Array(data);
  }

  if (ArrayBuffer.isView(data)) {
    return new Uint8Array(data.buffer, data.byteOffset, data.byteLength);
  }

  throw new Error('WebP decoder expects an ArrayBuffer or typed array.');
}

function createSandbox() {
  const sandbox = {
    navigator: { userAgent: 'ink-rquickjs' },
    setTimeout() {
      return 0;
    },
    clearTimeout() {},
  };

  sandbox.window = sandbox;
  sandbox.document = {
    readyState: 'complete',
    createElement() {
      return {
        style: {},
        appendChild() {},
        cloneNode() {
          return {};
        },
        getContext() {
          return null;
        },
      };
    },
    getElementById() {
      return null;
    },
  };

  return sandbox;
}

function readUint32LE(bytes, offset) {
  return (
    bytes[offset] |
    (bytes[offset + 1] << 8) |
    (bytes[offset + 2] << 16) |
    (bytes[offset + 3] << 24)
  ) >>> 0;
}

function writeUint32LE(bytes, offset, value) {
  bytes[offset] = value & 0xff;
  bytes[offset + 1] = (value >>> 8) & 0xff;
  bytes[offset + 2] = (value >>> 16) & 0xff;
  bytes[offset + 3] = (value >>> 24) & 0xff;
}

function isRiffWebP(bytes) {
  return (
    bytes.length >= 12 &&
    bytes[0] === 0x52 &&
    bytes[1] === 0x49 &&
    bytes[2] === 0x46 &&
    bytes[3] === 0x46 &&
    bytes[8] === 0x57 &&
    bytes[9] === 0x45 &&
    bytes[10] === 0x42 &&
    bytes[11] === 0x50
  );
}

function getAsciiTag(bytes, offset) {
  return String.fromCharCode(bytes[offset], bytes[offset + 1], bytes[offset + 2], bytes[offset + 3]);
}

function parseWebPChunks(bytes) {
  if (!isRiffWebP(bytes)) {
    throw new Error('Invalid WebP RIFF container.');
  }

  const chunks = [];
  let offset = 12;

  while (offset + 8 <= bytes.length) {
    const type = getAsciiTag(bytes, offset);
    const size = readUint32LE(bytes, offset + 4);
    const payloadStart = offset + 8;
    const payloadEnd = payloadStart + size;

    if (payloadEnd > bytes.length) {
      throw new Error(`Invalid WebP chunk size for ${type}.`);
    }

    chunks.push({
      type,
      size,
      source: bytes,
      payloadStart,
      payloadEnd,
    });

    offset = payloadEnd + (size % 2);
  }

  return chunks;
}

function getChunkPayload(chunk) {
  return chunk.payload || chunk.source.subarray(chunk.payloadStart, chunk.payloadEnd);
}

function buildWebPChunk(type, payload) {
  const paddedSize = payload.length + (payload.length % 2);
  const chunk = new Uint8Array(8 + paddedSize);
  chunk[0] = type.charCodeAt(0);
  chunk[1] = type.charCodeAt(1);
  chunk[2] = type.charCodeAt(2);
  chunk[3] = type.charCodeAt(3);
  writeUint32LE(chunk, 4, payload.length);
  chunk.set(payload, 8);
  return chunk;
}

function buildSimpleWebP(chunks) {
  const chunkBuffers = chunks.map((chunk) => buildWebPChunk(chunk.type, getChunkPayload(chunk)));
  let chunksLength = 0;

  for (const chunk of chunkBuffers) {
    chunksLength += chunk.length;
  }

  const file = new Uint8Array(12 + chunksLength);
  file[0] = 0x52;
  file[1] = 0x49;
  file[2] = 0x46;
  file[3] = 0x46;
  writeUint32LE(file, 4, 4 + chunksLength);
  file[8] = 0x57;
  file[9] = 0x45;
  file[10] = 0x42;
  file[11] = 0x50;

  let offset = 12;
  for (const chunk of chunkBuffers) {
    file.set(chunk, offset);
    offset += chunk.length;
  }

  return file;
}

function normalizeWebPBytes(bytes) {
  const chunkType = getWebPChunkType(bytes);

  if (chunkType !== 'VP8X') {
    return {
      bytes,
      chunkType,
      normalizedChunkType: chunkType,
    };
  }

  const chunks = parseWebPChunks(bytes);
  const hasAnimation = chunks.some((chunk) => chunk.type === 'ANIM' || chunk.type === 'ANMF');
  if (hasAnimation) {
    throw new Error('Animated WebP is not supported.');
  }

  const alphaChunk = chunks.find((chunk) => chunk.type === 'ALPH');
  const imageChunk = chunks.find((chunk) => chunk.type === 'VP8 ' || chunk.type === 'VP8L');

  if (!imageChunk) {
    throw new Error('VP8X container does not contain a supported image chunk.');
  }

  if (imageChunk.type === 'VP8L') {
    return {
      bytes: buildSimpleWebP([imageChunk]),
      chunkType,
      normalizedChunkType: 'VP8L',
    };
  }

  if (alphaChunk) {
    return {
      bytes: buildSimpleWebP([alphaChunk, imageChunk]),
      chunkType,
      normalizedChunkType: 'ALPH+VP8',
    };
  }

  return {
    bytes: buildSimpleWebP([imageChunk]),
    chunkType,
    normalizedChunkType: 'VP8',
  };
}

function getWebPDecoderClass() {
  if (!WebPDecoderClass) {
    const sandbox = createSandbox();
    const bootstrap = new Function(
      'sandbox',
      `
        with (sandbox) {
          ${webpjsSource}
          return typeof WebPDecoder !== 'undefined' ? WebPDecoder : null;
        }
      `,
    );
    WebPDecoderClass = bootstrap(sandbox);
  }

  if (!WebPDecoderClass) {
    throw new Error('Failed to initialize pure JavaScript WebP decoder.');
  }

  return WebPDecoderClass;
}

function argbToRgba(argb, width, height) {
  const expectedLength = width * height * 4;
  const rgba = new Uint8Array(expectedLength);

  for (let index = 0; index < expectedLength; index += 4) {
    rgba[index] = argb[index + 1];
    rgba[index + 1] = argb[index + 2];
    rgba[index + 2] = argb[index + 3];
    rgba[index + 3] = argb[index];
  }

  return rgba;
}

function argbToGray(argb, width, height) {
  const expectedLength = width * height * 4;
  const gray = new Uint8Array(width * height);

  for (let srcIndex = 0, dstIndex = 0; srcIndex < expectedLength; srcIndex += 4, dstIndex += 1) {
    const red = argb[srcIndex + 1];
    const green = argb[srcIndex + 2];
    const blue = argb[srcIndex + 3];
    gray[dstIndex] = Math.round(red * 0.299 + green * 0.587 + blue * 0.114);
  }

  return gray;
}

function unwrapDimension(value) {
  if (typeof value === 'number') {
    return value;
  }

  if (value && typeof value.value === 'number') {
    return value.value;
  }

  return 0;
}

function getWebPChunkType(bytes) {
  if (
    bytes.length < 16 ||
    bytes[0] !== 0x52 ||
    bytes[1] !== 0x49 ||
    bytes[2] !== 0x46 ||
    bytes[3] !== 0x46 ||
    bytes[8] !== 0x57 ||
    bytes[9] !== 0x45 ||
    bytes[10] !== 0x42 ||
    bytes[11] !== 0x50
  ) {
    return 'unknown';
  }

  return String.fromCharCode(bytes[12], bytes[13], bytes[14], bytes[15]).trim() || 'unknown';
}

function describeVp8Status(status) {
  switch (status) {
    case 0:
      return 'ok';
    case 1:
      return 'out-of-memory';
    case 2:
      return 'invalid-parameter';
    case 3:
      return 'bitstream-error';
    case 4:
      return 'unsupported-feature';
    case 5:
      return 'suspended';
    case 6:
      return 'user-abort';
    case 7:
      return 'not-enough-data';
    default:
      return 'unknown-status';
  }
}

function normalizeDecodeOptions(options) {
  const output = options && options.output === 'gray' ? 'gray' : 'rgba';
  return { output };
}

export async function decodeWebP(data, options) {
  const { output: outputMode } = normalizeDecodeOptions(options);
  const originalBytes = toUint8Array(data);
  const normalized = normalizeWebPBytes(originalBytes);
  const bytes = normalized.bytes;
  const input = Array.from(bytes);
  const chunkType = normalized.chunkType;
  const normalizedChunkType = normalized.normalizedChunkType;
  const Decoder = getWebPDecoderClass();
  const decoder = new Decoder();
  const config = decoder.WebPDecoderConfig;
  const output = config.output;
  const bitstream = config.input;
  const okStatus = decoder.VP8StatusCode.VP8_STATUS_OK;

  if (!decoder.WebPInitDecoderConfig(config)) {
    throw new Error('Failed to initialize pure JavaScript WebP decoder.');
  }

  const featureStatus = decoder.WebPGetFeatures(input, bytes.length, bitstream);
  if (featureStatus !== okStatus) {
    throw new Error(
      `Failed to read WebP features: ${featureStatus} (${describeVp8Status(featureStatus)}). ` +
      `chunk=${chunkType}, normalized=${normalizedChunkType}. ` +
      `This pure JavaScript decoder may not support the current WebP variant.`,
    );
  }

  if (bitstream.has_animation) {
    throw new Error('Animated WebP is not supported.');
  }

  output.colorspace = decoder.WEBP_CSP_MODE.MODE_ARGB;
  const decodeStatus = decoder.WebPDecode(input, bytes.length, config);
  if (decodeStatus !== okStatus) {
    throw new Error(
      `Failed to decode WebP image: ${decodeStatus} (${describeVp8Status(decodeStatus)}). ` +
      `chunk=${chunkType}, normalized=${normalizedChunkType}. ` +
      `This pure JavaScript decoder may not support the current WebP variant.`,
    );
  }

  const width = unwrapDimension(output.width) || unwrapDimension(bitstream.width);
  const height = unwrapDimension(output.height) || unwrapDimension(bitstream.height);
  const expectedLength = width * height * 4;
  const rawArgb = output.u && output.u.RGBA && output.u.RGBA.rgba;

  if (!rawArgb || !expectedLength || rawArgb.length < expectedLength) {
    throw new Error('Decoded WebP pixel buffer is invalid.');
  }

  if (!width || !height) {
    throw new Error('Decoded WebP pixel buffer is invalid.');
  }

  if (outputMode === 'gray') {
    const gray = argbToGray(rawArgb, width, height);

    if (gray.length !== width * height) {
      throw new Error('Decoded WebP pixel buffer is invalid.');
    }

    return {
      width,
      height,
      gray,
    };
  }

  const rgba = argbToRgba(rawArgb, width, height);

  if (rgba.length !== expectedLength) {
    throw new Error('Decoded WebP pixel buffer is invalid.');
  }

  return {
    width,
    height,
    rgba,
  };
}
