const RuntimeUserAgentPattern = Object.freeze({
    AIUI: /(?:^|\s)AIUI\/([0-9]+(?:\.[0-9]+){1,3})(?=\s|\(|$)/,
    PLATFORM: /AIUI\/[0-9]+(?:\.[0-9]+){1,3}\s*\(([^;()]+);\s*([^)]+)\)/,
    INK: /(?:^|\s)Ink\/([0-9]+(?:\.[0-9]+){1,3}(?:-[A-Za-z0-9.-]+)?)(?=\s|$)/
});

const RuntimeRequirement = Object.freeze({
    ABSOLUTE_ORIENTATION_AIUI_VERSION: '0.15.0',
    VERSION_PART_COUNT: 3,
    VERSION_PART_RADIX: 10,
    COMPARISON_EQUAL: 0
});

const RuntimeDisplayValue = Object.freeze({
    UNKNOWN: '--'
});

/**
 * 读取正则表达式的第一个捕获组。
 *
 * @param {string} source 待解析字符串。
 * @param {RegExp} pattern 解析规则。
 * @returns {string} 捕获结果，未匹配时返回占位符。
 */
function readFirstMatch(source, pattern) {
    const match = source.match(pattern);
    return match && match[1]
        ? match[1].trim()
        : RuntimeDisplayValue.UNKNOWN;
}

/**
 * 将版本字符串转换为固定长度的数字数组。
 *
 * @param {string} version 原始版本字符串。
 * @returns {number[] | null} 可比较版本，无法解析时返回 null。
 */
function parseNumericVersion(version) {
    if (
        !version
        || version === RuntimeDisplayValue.UNKNOWN
    ) {
        return null;
    }
    const numericCore = version.split('-')[0];
    const parts = numericCore.split('.').map((part) => (
        Number.parseInt(part, RuntimeRequirement.VERSION_PART_RADIX)
    ));
    if (parts.some((part) => !Number.isFinite(part))) {
        return null;
    }
    while (parts.length < RuntimeRequirement.VERSION_PART_COUNT) {
        parts.push(RuntimeRequirement.COMPARISON_EQUAL);
    }
    return parts.slice(0, RuntimeRequirement.VERSION_PART_COUNT);
}

/**
 * 判断当前版本是否不低于最低版本。
 *
 * @param {string} currentVersion 当前版本。
 * @param {string} minimumVersion 最低版本。
 * @returns {boolean | null} 无法解析当前版本时返回 null。
 */
export function isVersionAtLeast(currentVersion, minimumVersion) {
    const current = parseNumericVersion(currentVersion);
    const minimum = parseNumericVersion(minimumVersion);
    if (!current || !minimum) {
        return null;
    }
    for (
        let index = RuntimeRequirement.COMPARISON_EQUAL;
        index < RuntimeRequirement.VERSION_PART_COUNT;
        index += 1
    ) {
        if (current[index] > minimum[index]) {
            return true;
        }
        if (current[index] < minimum[index]) {
            return false;
        }
    }
    return true;
}

/**
 * 解析 Rokid AIUI 浏览器的 User-Agent。
 *
 * 支持格式：
 * `AIUI/0.15 (YodaOS Sprite; arm64-v8a) Ink/0.15.0-rc-构建号`。
 *
 * @param {string} userAgent Navigator 返回的 User-Agent。
 * @returns {{
 *     aiuiVersion: string,
 *     systemName: string,
 *     architecture: string,
 *     inkVersion: string,
 *     meetsAbsoluteOrientationVersion: boolean | null
 * }} 结构化运行环境信息。
 */
export function parseRuntimeUserAgent(userAgent) {
    const source = typeof userAgent === 'string'
        ? userAgent.trim()
        : '';
    const platformMatch = source.match(RuntimeUserAgentPattern.PLATFORM);
    const aiuiVersion = readFirstMatch(
        source,
        RuntimeUserAgentPattern.AIUI
    );
    return {
        aiuiVersion,
        systemName: platformMatch && platformMatch[1]
            ? platformMatch[1].trim()
            : RuntimeDisplayValue.UNKNOWN,
        architecture: platformMatch && platformMatch[2]
            ? platformMatch[2].trim()
            : RuntimeDisplayValue.UNKNOWN,
        inkVersion: readFirstMatch(source, RuntimeUserAgentPattern.INK),
        meetsAbsoluteOrientationVersion: isVersionAtLeast(
            aiuiVersion,
            RuntimeRequirement.ABSOLUTE_ORIENTATION_AIUI_VERSION
        )
    };
}
