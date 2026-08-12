# aix-cli 工具

`aix` 是用于管理、打包和查看 AIX 文件的官方命令行工具。

## 安装

如果你已经获取了源码，可以通过 npm 或 cargo 进行安装：

```bash
npm install -g @yodaos-pkg/aix-cli
```

```bash
cargo install --path packages/aix-cli
```

## 核心命令

### 1. 打包 (Pack)
将开发目录打包成 `.aix` 文件：

```bash
# 基础打包
aix pack <源码目录>

# 指定输出文件名
aix pack <源码目录> -o my-agent.aix

# 开启资源优化 (压缩图片和 JSON)
aix pack <源码目录> --optimize

# 指定优化等级 (1-3)
aix pack <源码目录> -O --opt-level 3
```

### 2. 查看内容 (List)
在不解压的情况下查看 AIX 包内的文件列表和大小：

```bash
aix list <AIX文件>
# 或者使用别名
aix ls <AIX文件>
```

## 忽略文件 (.aixignore)

打包工具会识别源码根目录下的 `.aixignore` 文件。你可以使用类似于 `.gitignore` 的语法来排除不需要打包的文件。
