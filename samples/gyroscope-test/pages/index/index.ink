<script def>
{
    "navigationBarTitleText": "陀螺仪测试"
}
</script>

<script setup>
import wx from 'wx';
import {
    parseRuntimeUserAgent
} from '../../lib/runtime-environment.js';

const TestStatus = Object.freeze({
    INITIALIZING: 'initializing',
    RUNNING: 'running',
    ERROR: 'error'
});

const KeyCode = Object.freeze({
    CONFIRM: 'Enter'
});

const TestConfig = Object.freeze({
    SENSOR_FREQUENCY_HZ: 60,
    UI_REFRESH_INTERVAL_MS: 100,
    CANVAS_REFRESH_INTERVAL_MS: 33,
    SAMPLE_RATE_WINDOW_MS: 1000,
    MIN_QUATERNION_LENGTH: 4,
    DIRECTION_THRESHOLD_DEGREES: 3,
    CENTER_TOLERANCE_DEGREES: 2,
    RADIANS_TO_DEGREES: 180 / Math.PI,
    DEGREES_TO_RADIANS: Math.PI / 180,
    HALF_TURN_DEGREES: 180,
    FULL_TURN_DEGREES: 360,
    DECIMAL_PLACES: 2,
    SCREEN_WIDTH: 480,
    SCREEN_HEIGHT: 352,
    CENTER_X: 240,
    CENTER_Y: 176,
    EDGE_PADDING_PX: 18,
    HORIZONTAL_PIXELS_PER_RADIAN: 260,
    VERTICAL_PIXELS_PER_RADIAN: 220,
    CROSSHAIR_ARM_PX: 13,
    CROSSHAIR_GAP_PX: 4,
    CENTER_RING_RADIUS_PX: 9,
    AXIS_TICK_PX: 5,
    AXIS_TICK_INTERVAL_PX: 40,
    PRIMARY_COLOR: '#00ff66',
    MUTED_COLOR: '#174526',
    SECONDARY_COLOR: '#4da86c',
    BACKGROUND_COLOR: '#000000'
});

/**
 * 将数值限制在指定范围内。
 *
 * @param {number} value 原始数值。
 * @param {number} minimum 最小值。
 * @param {number} maximum 最大值。
 * @returns {number} 限制后的数值。
 */
function clamp(value, minimum, maximum) {
    return Math.min(Math.max(value, minimum), maximum);
}

/**
 * 校验绝对方向传感器返回的四元数。
 *
 * @param {unknown} quaternion 待校验的四元数。
 * @returns {boolean} 是否为有效的 `[x, y, z, w]`。
 */
function isValidQuaternion(quaternion) {
    return Boolean(
        Array.isArray(quaternion)
        && quaternion.length >= TestConfig.MIN_QUATERNION_LENGTH
        && quaternion
            .slice(0, TestConfig.MIN_QUATERNION_LENGTH)
            .every(Number.isFinite)
    );
}

/**
 * 将四元数归一化，避免传感器微小数值误差影响相对旋转。
 *
 * @param {number[]} quaternion 原始四元数。
 * @returns {number[] | null} 归一化四元数，无效时返回 null。
 */
function normalizeQuaternion(quaternion) {
    if (!isValidQuaternion(quaternion)) {
        return null;
    }
    const [x, y, z, w] = quaternion;
    const magnitude = Math.sqrt(x * x + y * y + z * z + w * w);
    if (!Number.isFinite(magnitude) || magnitude === 0) {
        return null;
    }
    return [x / magnitude, y / magnitude, z / magnitude, w / magnitude];
}

/**
 * 计算单位四元数的逆。
 *
 * @param {number[]} quaternion 单位四元数。
 * @returns {number[]} 逆四元数。
 */
function invertQuaternion(quaternion) {
    return [
        -quaternion[0],
        -quaternion[1],
        -quaternion[2],
        quaternion[3]
    ];
}

/**
 * 按 `[x, y, z, w]` 顺序计算两个四元数的 Hamilton 积。
 *
 * @param {number[]} left 左四元数。
 * @param {number[]} right 右四元数。
 * @returns {number[]} 相乘后的四元数。
 */
function multiplyQuaternions(left, right) {
    const [lx, ly, lz, lw] = left;
    const [rx, ry, rz, rw] = right;
    return [
        lw * rx + lx * rw + ly * rz - lz * ry,
        lw * ry - lx * rz + ly * rw + lz * rx,
        lw * rz + lx * ry - ly * rx + lz * rw,
        lw * rw - lx * rx - ly * ry - lz * rz
    ];
}

/**
 * 计算从校准姿态到当前姿态的相对四元数。
 *
 * @param {number[]} baselineQuaternion 校准四元数。
 * @param {number[]} currentQuaternion 当前四元数。
 * @returns {number[] | null} 相对四元数。
 */
function getRelativeQuaternion(baselineQuaternion, currentQuaternion) {
    const baseline = normalizeQuaternion(baselineQuaternion);
    const current = normalizeQuaternion(currentQuaternion);
    if (!baseline || !current) {
        return null;
    }
    return normalizeQuaternion(
        multiplyQuaternions(invertQuaternion(baseline), current)
    );
}

/**
 * 将四元数转换为欧拉角。
 *
 * @param {number[]} quaternion `[x, y, z, w]` 四元数。
 * @returns {{yaw: number, pitch: number, roll: number} | null} 弧度制欧拉角。
 */
function quaternionToEuler(quaternion) {
    const normalized = normalizeQuaternion(quaternion);
    if (!normalized) {
        return null;
    }
    const [x, y, z, w] = normalized;
    const rollNumerator = 2 * (w * x + y * z);
    const rollDenominator = 1 - 2 * (x * x + y * y);
    const pitchValue = clamp(2 * (w * y - z * x), -1, 1);
    const yawNumerator = 2 * (w * z + x * y);
    const yawDenominator = 1 - 2 * (y * y + z * z);
    return {
        yaw: Math.atan2(yawNumerator, yawDenominator),
        pitch: Math.asin(pitchValue),
        roll: Math.atan2(rollNumerator, rollDenominator)
    };
}

/**
 * 将弧度转换为便于真机观察的角度。
 *
 * @param {number} radians 弧度值。
 * @returns {number} 角度值。
 */
function radiansToDegrees(radians) {
    return radians * TestConfig.RADIANS_TO_DEGREES;
}

/**
 * 将角度规范到 `[-180, 180]`。
 *
 * @param {number} degrees 原始角度。
 * @returns {number} 规范后的角度。
 */
function normalizeDegrees(degrees) {
    let normalized = degrees;
    while (normalized > TestConfig.HALF_TURN_DEGREES) {
        normalized -= TestConfig.FULL_TURN_DEGREES;
    }
    while (normalized < -TestConfig.HALF_TURN_DEGREES) {
        normalized += TestConfig.FULL_TURN_DEGREES;
    }
    return normalized;
}

/**
 * 格式化测试页数值。
 *
 * @param {number} value 原始数值。
 * @returns {string} 固定两位小数的文本。
 */
function formatNumber(value) {
    return Number.isFinite(value)
        ? value.toFixed(TestConfig.DECIMAL_PLACES)
        : '--';
}

/**
 * 根据相对角度给出直观的头部方向提示。
 *
 * @param {number} horizontalDegrees Y 轴水平相对角度。
 * @param {number} verticalDegrees X 轴垂直相对角度。
 * @returns {string} 当前主要方向。
 */
function getDirectionLabel(horizontalDegrees, verticalDegrees) {
    const threshold = TestConfig.DIRECTION_THRESHOLD_DEGREES;
    if (Math.abs(horizontalDegrees) >= Math.abs(verticalDegrees)) {
        if (horizontalDegrees > threshold) {
            return '准星向左';
        }
        if (horizontalDegrees < -threshold) {
            return '准星向右';
        }
    }
    if (verticalDegrees > threshold) {
        return '准星向上';
    }
    if (verticalDegrees < -threshold) {
        return '准星向下';
    }
    return '中心范围';
}

/**
 * 将相对四元数转换为绕 X、Y、Z 三轴的旋转向量。
 *
 * 旋转向量用于观察真实动作主要改变哪个设备轴，不预先假设某个轴
 * 一定对应屏幕水平或垂直方向。
 *
 * @param {number[]} quaternion 相对四元数。
 * @returns {{x: number, y: number, z: number} | null} 三轴旋转角度。
 */
function quaternionToRotationVectorDegrees(quaternion) {
    const normalized = normalizeQuaternion(quaternion);
    if (!normalized) {
        return null;
    }
    const sign = normalized[3] < 0 ? -1 : 1;
    const x = normalized[0] * sign;
    const y = normalized[1] * sign;
    const z = normalized[2] * sign;
    const w = clamp(normalized[3] * sign, -1, 1);
    const vectorLength = Math.sqrt(x * x + y * y + z * z);
    if (vectorLength === 0) {
        return {
            x: 0,
            y: 0,
            z: 0
        };
    }
    const angleDegrees = radiansToDegrees(
        2 * Math.atan2(vectorLength, w)
    );
    return {
        x: x / vectorLength * angleDegrees,
        y: y / vectorLength * angleDegrees,
        z: z / vectorLength * angleDegrees
    };
}

/**
 * 获取旋转向量中绝对变化最大的设备轴。
 *
 * @param {{x: number, y: number, z: number}} vector 三轴旋转向量。
 * @returns {string} 主导轴名称。
 */
function getDominantAxis(vector) {
    const entries = [
        { axis: 'X', value: vector.x },
        { axis: 'Y', value: vector.y },
        { axis: 'Z', value: vector.z }
    ];
    const dominant = entries.reduce((largest, entry) => (
        Math.abs(entry.value) > Math.abs(largest.value)
            ? entry
            : largest
    ));
    if (
        Math.abs(dominant.value)
        < TestConfig.DIRECTION_THRESHOLD_DEGREES
    ) {
        return '中心';
    }
    return `${dominant.axis}${dominant.value >= 0 ? '+' : '-'}`;
}

/**
 * 安全读取当前运行环境的 User-Agent。
 *
 * @returns {string} User-Agent 原文，无法读取时返回空字符串。
 */
function readUserAgent() {
    try {
        return typeof navigator !== 'undefined'
            && typeof navigator.userAgent === 'string'
            ? navigator.userAgent
            : '';
    } catch (error) {
        return '';
    }
}

export default {
    data: {
        status: TestStatus.INITIALIZING,
        statusTitle: '正在连接绝对方向传感器',
        statusDetail: '请正视前方，读取成功后自动建立基准。',
        frequency: 0,
        sampleCount: 0,
        quaternionText: '--',
        yawText: '--',
        pitchText: '--',
        rollText: '--',
        centerErrorText: '--',
        rotationXText: '--',
        rotationYText: '--',
        rotationZText: '--',
        dominantAxis: '等待',
        directionLabel: '等待数据',
        centerState: '尚未校准',
        aiuiVersion: '--',
        inkVersion: '--',
        systemName: '--',
        architecture: '--',
        sensorState: '未提供'
    },

    /**
     * 初始化测试页运行状态。
     *
     * @returns {void}
     */
    onLoad() {
        this.sensor = null;
        this.currentQuaternion = null;
        this.baselineQuaternion = null;
        this.sampleCount = 0;
        this.rateWindowSampleCount = 0;
        this.rateWindowStartedAt = Date.now();
        this.measuredFrequency = 0;
        this.uiRefreshTimer = null;
        this.canvasRefreshTimer = null;
        this.canvasContext = null;
        this.canvasInitializationTimeout = null;
        this.refreshRuntimeEnvironment();
    },

    /**
     * 解析并显示当前 AIUI、Ink、系统架构和方向接口状态。
     *
     * @returns {void}
     */
    refreshRuntimeEnvironment() {
        const userAgent = readUserAgent();
        const environment = parseRuntimeUserAgent(userAgent);
        this.setData({
            aiuiVersion: environment.aiuiVersion,
            inkVersion: environment.inkVersion,
            systemName: environment.systemName,
            architecture: environment.architecture,
            sensorState: typeof AbsoluteOrientationSensor !== 'undefined'
                ? '已提供'
                : '未提供'
        });
        console.log('[gyroscope-test] navigator.userAgent:', userAgent);
    },

    /**
     * 页面显示时启动绝对方向传感器测试。
     *
     * @returns {void}
     */
    onShow() {
        this.startSensor();
        this.scheduleCanvasInitialization();
    },

    /**
     * 页面隐藏时释放传感器和刷新定时器。
     *
     * @returns {void}
     */
    onHide() {
        this.stopSensor();
    },

    /**
     * 页面卸载时释放传感器和刷新定时器。
     *
     * @returns {void}
     */
    onUnload() {
        this.stopSensor();
    },

    /**
     * 按确认键将当前正前方重新设为基准。
     *
     * @param {{code?: string, preventDefault?: Function}} event 按键事件。
     * @returns {void}
     */
    onKeyUp(event) {
        if (!event || event.code !== KeyCode.CONFIRM) {
            return;
        }
        if (typeof event.preventDefault === 'function') {
            event.preventDefault();
        }
        this.recenter();
    },

    /**
     * 启动 AIUI 0.15.0 绝对方向传感器。
     *
     * @returns {void}
     */
    startSensor() {
        this.stopSensor();
        this.setData({
            status: TestStatus.INITIALIZING,
            statusTitle: '正在连接绝对方向传感器',
            statusDetail: '请正视前方，读取成功后自动建立基准。'
        });
        if (typeof AbsoluteOrientationSensor === 'undefined') {
            this.showError('运行环境未提供 AbsoluteOrientationSensor。');
            return;
        }
        try {
            const sensor = new AbsoluteOrientationSensor({
                frequency: TestConfig.SENSOR_FREQUENCY_HZ
            });
            sensor.addEventListener('reading', () => {
                this.handleReading(sensor);
            });
            sensor.addEventListener('error', (event) => {
                const message = event && event.error && event.error.message
                    ? event.error.message
                    : '传感器启动或读取失败。';
                this.showError(message);
            });
            this.sensor = sensor;
            sensor.start();
            this.uiRefreshTimer = setInterval(() => {
                this.refreshDisplay();
            }, TestConfig.UI_REFRESH_INTERVAL_MS);
        } catch (error) {
            this.showError(
                error && error.message
                    ? error.message
                    : '无法创建绝对方向传感器。'
            );
        }
    },

    /**
     * 接收一次绝对方向四元数读数。
     *
     * @param {AbsoluteOrientationSensor} sensor 当前传感器实例。
     * @returns {void}
     */
    handleReading(sensor) {
        const quaternion = sensor && sensor.quaternion
            ? Array.from(sensor.quaternion)
            : null;
        if (!isValidQuaternion(quaternion)) {
            return;
        }
        this.currentQuaternion = quaternion;
        this.sampleCount += 1;
        this.rateWindowSampleCount += 1;
        if (!this.baselineQuaternion) {
            this.baselineQuaternion = [...quaternion];
        }
        const now = Date.now();
        const elapsedMs = now - this.rateWindowStartedAt;
        if (elapsedMs >= TestConfig.SAMPLE_RATE_WINDOW_MS) {
            this.measuredFrequency = Math.round(
                this.rateWindowSampleCount
                * TestConfig.SAMPLE_RATE_WINDOW_MS
                / elapsedMs
            );
            this.rateWindowSampleCount = 0;
            this.rateWindowStartedAt = now;
        }
    },

    /**
     * 以固定低频刷新诊断文字，避免 60Hz setData 影响传感器测试。
     *
     * @returns {void}
     */
    refreshDisplay() {
        if (!this.currentQuaternion || !this.baselineQuaternion) {
            return;
        }
        const relativeQuaternion = getRelativeQuaternion(
            this.baselineQuaternion,
            this.currentQuaternion
        );
        const euler = quaternionToEuler(relativeQuaternion);
        const rotationVector = quaternionToRotationVectorDegrees(
            relativeQuaternion
        );
        if (!euler || !rotationVector) {
            return;
        }
        const yawDegrees = normalizeDegrees(radiansToDegrees(euler.yaw));
        const pitchDegrees = normalizeDegrees(
            radiansToDegrees(euler.pitch)
        );
        const rollDegrees = normalizeDegrees(radiansToDegrees(euler.roll));
        const horizontalDegrees = rotationVector.y;
        const verticalDegrees = rotationVector.x;
        const centerError = Math.sqrt(
            horizontalDegrees * horizontalDegrees
            + verticalDegrees * verticalDegrees
        );
        const isCentered = centerError
            <= TestConfig.CENTER_TOLERANCE_DEGREES;
        this.setData({
            status: TestStatus.RUNNING,
            statusTitle: '绝对方向数据读取正常',
            statusDetail: '左转、右转、抬头、低头后回正，观察方向与回中误差。',
            frequency: this.measuredFrequency,
            sampleCount: this.sampleCount,
            quaternionText: this.currentQuaternion
                .map(formatNumber)
                .join('  '),
            yawText: formatNumber(yawDegrees),
            pitchText: formatNumber(pitchDegrees),
            rollText: formatNumber(rollDegrees),
            centerErrorText: formatNumber(centerError),
            rotationXText: formatNumber(rotationVector.x),
            rotationYText: formatNumber(rotationVector.y),
            rotationZText: formatNumber(rotationVector.z),
            dominantAxis: getDominantAxis(rotationVector),
            directionLabel: getDirectionLabel(
                horizontalDegrees,
                verticalDegrees
            ),
            centerState: isCentered ? '已回到中心' : '偏离中心'
        });
    },

    /**
     * 在页面结构提交后延迟初始化 Canvas。
     *
     * @returns {void}
     */
    scheduleCanvasInitialization() {
        if (this.canvasInitializationTimeout) {
            clearTimeout(this.canvasInitializationTimeout);
        }
        this.canvasInitializationTimeout = setTimeout(() => {
            this.canvasInitializationTimeout = null;
            this.initializeCanvas();
        }, 0);
    },

    /**
     * 使用正式游戏已验证的 API 创建测试画布。
     *
     * @returns {void}
     */
    initializeCanvas() {
        this.canvasContext = wx.createCanvasContext('orientationCanvas');
        if (!this.canvasContext) {
            this.showError('无法创建方向测试 Canvas。');
            return;
        }
        this.drawOrientationCanvas();
        this.startCanvasLoop();
    },

    /**
     * 启动独立的 Canvas 刷新循环。
     *
     * @returns {void}
     */
    startCanvasLoop() {
        if (!this.canvasContext || this.canvasRefreshTimer) {
            return;
        }
        this.canvasRefreshTimer = setInterval(() => {
            this.drawOrientationCanvas();
        }, TestConfig.CANVAS_REFRESH_INTERVAL_MS);
    },

    /**
     * 绘制固定中心坐标轴和当前算法输出的动态十字准星。
     *
     * @returns {void}
     */
    drawOrientationCanvas() {
        const context = this.canvasContext;
        if (!context) {
            return;
        }
        context.fillStyle = TestConfig.BACKGROUND_COLOR;
        context.fillRect(
            0,
            0,
            TestConfig.SCREEN_WIDTH,
            TestConfig.SCREEN_HEIGHT
        );
        this.drawCenterAxes(context);
        if (this.currentQuaternion && this.baselineQuaternion) {
            const relativeQuaternion = getRelativeQuaternion(
                this.baselineQuaternion,
                this.currentQuaternion
            );
            const rotationVector = quaternionToRotationVectorDegrees(
                relativeQuaternion
            );
            if (rotationVector) {
                const aimX = clamp(
                    TestConfig.CENTER_X - rotationVector.y
                        * TestConfig.DEGREES_TO_RADIANS
                        * TestConfig.HORIZONTAL_PIXELS_PER_RADIAN,
                    TestConfig.EDGE_PADDING_PX,
                    TestConfig.SCREEN_WIDTH
                        - TestConfig.EDGE_PADDING_PX
                );
                const aimY = clamp(
                    TestConfig.CENTER_Y - rotationVector.x
                        * TestConfig.DEGREES_TO_RADIANS
                        * TestConfig.VERTICAL_PIXELS_PER_RADIAN,
                    TestConfig.EDGE_PADDING_PX,
                    TestConfig.SCREEN_HEIGHT
                        - TestConfig.EDGE_PADDING_PX
                );
                this.drawDynamicCrosshair(context, aimX, aimY);
            }
        }
        context.flush();
    },

    /**
     * 绘制贯穿屏幕中心的固定坐标轴和回正圆环。
     *
     * @param {CanvasRenderingContext2D} context Canvas 绘图上下文。
     * @returns {void}
     */
    drawCenterAxes(context) {
        const centerX = TestConfig.CENTER_X;
        const centerY = TestConfig.CENTER_Y;
        context.strokeStyle = TestConfig.MUTED_COLOR;
        context.lineWidth = 1;
        context.beginPath();
        context.moveTo(TestConfig.EDGE_PADDING_PX, centerY);
        context.lineTo(
            TestConfig.SCREEN_WIDTH - TestConfig.EDGE_PADDING_PX,
            centerY
        );
        context.moveTo(centerX, TestConfig.EDGE_PADDING_PX);
        context.lineTo(
            centerX,
            TestConfig.SCREEN_HEIGHT - TestConfig.EDGE_PADDING_PX
        );
        for (
            let x = TestConfig.EDGE_PADDING_PX;
            x <= TestConfig.SCREEN_WIDTH - TestConfig.EDGE_PADDING_PX;
            x += TestConfig.AXIS_TICK_INTERVAL_PX
        ) {
            context.moveTo(x, centerY - TestConfig.AXIS_TICK_PX);
            context.lineTo(x, centerY + TestConfig.AXIS_TICK_PX);
        }
        for (
            let y = TestConfig.EDGE_PADDING_PX;
            y <= TestConfig.SCREEN_HEIGHT - TestConfig.EDGE_PADDING_PX;
            y += TestConfig.AXIS_TICK_INTERVAL_PX
        ) {
            context.moveTo(centerX - TestConfig.AXIS_TICK_PX, y);
            context.lineTo(centerX + TestConfig.AXIS_TICK_PX, y);
        }
        context.stroke();
        context.strokeStyle = TestConfig.SECONDARY_COLOR;
        context.beginPath();
        context.arc(
            centerX,
            centerY,
            TestConfig.CENTER_RING_RADIUS_PX,
            0,
            Math.PI * 2
        );
        context.stroke();
    },

    /**
     * 绘制由当前姿态驱动的动态十字准星。
     *
     * @param {CanvasRenderingContext2D} context Canvas 绘图上下文。
     * @param {number} x 准星横坐标。
     * @param {number} y 准星纵坐标。
     * @returns {void}
     */
    drawDynamicCrosshair(context, x, y) {
        const arm = TestConfig.CROSSHAIR_ARM_PX;
        const gap = TestConfig.CROSSHAIR_GAP_PX;
        context.strokeStyle = TestConfig.PRIMARY_COLOR;
        context.lineWidth = 2;
        context.beginPath();
        context.moveTo(x - arm, y);
        context.lineTo(x - gap, y);
        context.moveTo(x + gap, y);
        context.lineTo(x + arm, y);
        context.moveTo(x, y - arm);
        context.lineTo(x, y - gap);
        context.moveTo(x, y + gap);
        context.lineTo(x, y + arm);
        context.stroke();
    },

    /**
     * 使用当前姿态重设测试基准。
     *
     * @returns {void}
     */
    recenter() {
        if (!this.currentQuaternion) {
            return;
        }
        this.baselineQuaternion = [...this.currentQuaternion];
        this.refreshDisplay();
    },

    /**
     * 停止传感器并释放刷新定时器。
     *
     * @returns {void}
     */
    stopSensor() {
        if (this.canvasInitializationTimeout) {
            clearTimeout(this.canvasInitializationTimeout);
            this.canvasInitializationTimeout = null;
        }
        if (this.uiRefreshTimer) {
            clearInterval(this.uiRefreshTimer);
            this.uiRefreshTimer = null;
        }
        if (this.canvasRefreshTimer) {
            clearInterval(this.canvasRefreshTimer);
            this.canvasRefreshTimer = null;
        }
        if (this.sensor && typeof this.sensor.stop === 'function') {
            try {
                this.sensor.stop();
            } catch (error) {
                // 传感器可能已由宿主释放，停止失败不影响页面退出。
            }
        }
        this.sensor = null;
    },

    /**
     * 显示绝对方向传感器错误。
     *
     * @param {string} message 错误信息。
     * @returns {void}
     */
    showError(message) {
        this.stopSensor();
        this.setData({
            status: TestStatus.ERROR,
            statusTitle: '绝对方向传感器不可用',
            statusDetail: message,
            directionLabel: '读取失败',
            centerState: '无法测试'
        });
    }
};
</script>

<page>
    <view class="test-screen">
        <canvas
            id="orientationCanvas"
            class="orientation-canvas"
            width="480"
            height="352"
        ></canvas>
        <view class="header overlay">
            <view class="heading-row">
                <text class="title">陀螺仪测试</text>
                <text class="meta">1.0.0 · CodeLife</text>
            </view>
            <text class="tag">AIUI {{aiuiVersion}} · {{frequency}}Hz</text>
        </view>
        <view class="divider overlay"></view>
        <view class="status-row overlay">
            <view class="status-dot status-dot-{{status}}"></view>
            <text class="status-title">{{statusTitle}}</text>
        </view>
        <text class="axis-label axis-label-x-negative overlay">−X</text>
        <text class="axis-label axis-label-x-positive overlay">+X</text>
        <text class="axis-label axis-label-y-negative overlay">−Y</text>
        <text class="axis-label axis-label-y-positive overlay">+Y</text>

        <view class="left-panel overlay">
            <text class="panel-label">当前映射</text>
            <text class="panel-value">{{directionLabel}}</text>
            <text class="panel-detail">水平 Y {{rotationYText}}°</text>
            <text class="panel-detail">垂直 X {{rotationXText}}°</text>
            <text class="panel-detail">Z轴 {{rotationZText}}°</text>
        </view>

        <view class="right-panel overlay">
            <text class="panel-label">设备主导轴</text>
            <text class="panel-value">{{dominantAxis}}</text>
            <text class="panel-detail">RX {{rotationXText}}°</text>
            <text class="panel-detail">RY {{rotationYText}}°</text>
            <text class="panel-detail">RZ {{rotationZText}}°</text>
        </view>

        <view class="footer-panel overlay">
            <text class="runtime-value">{{systemName}} · {{architecture}} · Ink {{inkVersion}} · 方向接口{{sensorState}}</text>
            <text class="quaternion-value">Q {{quaternionText}}</text>
            <view class="footer-row">
                <text class="center-state">{{centerState}}</text>
                <text class="center-error">回中误差 {{centerErrorText}}°</text>
                <text class="hint">确认键重新校准中心</text>
            </view>
        </view>
    </view>
</page>

<style>
.test-screen {
    position: relative;
    width: 480px;
    height: 352px;
    box-sizing: border-box;
    overflow: hidden;
    background-color: #000000;
    color: #00ff66;
    font-family: monospace;
}

.orientation-canvas {
    position: absolute;
    left: 0;
    top: 0;
    width: 480px;
    height: 352px;
    z-index: 0;
}

.overlay {
    position: absolute;
    z-index: 1;
}

.header,
.heading-row,
.status-row,
.footer-row {
    display: flex;
}

.header {
    left: 18px;
    top: 12px;
    width: 444px;
    height: 26px;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
}

.heading-row {
    flex-direction: row;
    align-items: baseline;
    gap: 9px;
}

.title {
    font-size: 20px;
    line-height: 26px;
    font-weight: bold;
}

.meta,
.tag,
.hint {
    color: #4da86c;
}

.meta,
.tag {
    font-size: 10px;
}

.divider {
    left: 18px;
    top: 43px;
    width: 444px;
    height: 1px;
    background-color: #00ff66;
}

.status-row {
    left: 18px;
    top: 51px;
    height: 18px;
    flex-direction: row;
    align-items: center;
    gap: 9px;
}

.status-dot {
    width: 7px;
    height: 7px;
    border: 1px solid #00ff66;
    border-radius: 50%;
}

.status-dot-running {
    background-color: #00ff66;
}

.status-dot-error {
    border-color: #4da86c;
    background-color: #4da86c;
}

.status-title {
    font-size: 14px;
    font-weight: bold;
}

.left-panel,
.right-panel {
    display: flex;
    top: 82px;
    width: 116px;
    height: 80px;
    box-sizing: border-box;
    flex-direction: column;
    gap: 4px;
    padding: 7px 9px;
    border: 1px solid #174526;
    background-color: #000000;
}

.left-panel {
    left: 18px;
}

.right-panel {
    right: 18px;
}

.panel-label,
.panel-detail {
    color: #4da86c;
    font-size: 9px;
    line-height: 11px;
}

.panel-value {
    font-size: 12px;
    font-weight: bold;
}

.axis-label {
    color: #4da86c;
    font-size: 9px;
}

.axis-label-x-negative {
    left: 20px;
    top: 179px;
}

.axis-label-x-positive {
    right: 20px;
    top: 179px;
}

.axis-label-y-negative {
    left: 245px;
    top: 72px;
}

.axis-label-y-positive {
    left: 245px;
    bottom: 72px;
}

.footer-panel {
    display: flex;
    left: 18px;
    bottom: 8px;
    width: 444px;
    height: 56px;
    box-sizing: border-box;
    flex-direction: column;
    justify-content: center;
    gap: 3px;
    padding: 4px 8px;
    border: 1px solid #174526;
    background-color: #000000;
}

.quaternion-value {
    font-size: 9px;
}

.runtime-value {
    color: #4da86c;
    font-size: 8px;
    line-height: 10px;
}

.footer-row {
    flex-direction: row;
    justify-content: space-between;
}

.center-state {
    font-size: 11px;
    font-weight: bold;
}

.center-error,
.hint {
    color: #4da86c;
    font-size: 9px;
}
</style>
