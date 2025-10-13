# SimpleMcpServer

Model Context Protocol (MCP) を使用したシンプルなHTTPベースのツールサーバーです。

## 概要

このプロジェクトは、.NET 9.0とModelContextProtocolライブラリを使用して、MCPサーバーを実装しています。ツールをHTTPエンドポイント経由で提供します。

## 必要な環境

- .NET 9.0 SDK
- Python 3.x (テストスクリプト用)
- requests ライブラリ (`pip install requests`)

## プロジェクト構成

```
SimpleMcpServer/
├── Program.cs              # メインサーバー実装
├── SimpleMcpServer.csproj  # プロジェクトファイル
├── test.py                 # テストスクリプト
└── README.md              # このファイル
```

## 利用可能なツール

| ツール名 | 説明 | パラメータ |
|---------|---------|-----------|
| `echo` | 文字列をそのまま返します | `message` (string) |
| `add` | 2つの整数を加算します | `a` (int), `b` (int) |
| `date` | 現在の時刻を取得します | なし |
| `zone` | 指定されたタイムゾーンの現在の時刻を取得します | `timeZone` (string) |

## セットアップと起動

### 1. パッケージの復元とビルド

```bash
cd SimpleMcpServer
dotnet restore
dotnet build
```

### 2. サーバーの起動

```bash
dotnet run
```

サーバーは `http://localhost:5000` で起動します。

## テスト方法

### Pythonテストスクリプトの使用

`test.py` ファイルには、各ツールをテストするためのサンプルペイロードが含まれています。

```bash
python test.py
```

デフォルトでは `tools/list` を実行しますが、test.py内のコメントを切り替えることで、異なるツールをテストできます。

### ツール一覧の取得

```json
{
  "jsonrpc": "2.0",
  "method": "tools/list",
  "params": {},
  "id": 1
}
```

### add ツールの呼び出し

```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "add",
    "arguments": {
      "a": 3,
      "b": 5
    }
  },
  "id": 1
}
```

結果:
```json
{
  "result": {
    "content": [
      {
        "type": "text",
        "text": "8"
      }
    ]
  },
  "id": 1,
  "jsonrpc": "2.0"
}
```

### echo ツールの呼び出し

```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "echo",
    "arguments": {
      "message": "Hello from Python"
    }
  },
  "id": 1
}
```

### zone ツールの呼び出し

```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "zone",
    "arguments": {
      "timeZone": "Asia/Tokyo"
    }
  },
  "id": 1
}
```

## 技術スタック

- .NET 9.0
- ModelContextProtocol (0.3.0-preview.4)
- ModelContextProtocol.AspNetCore (0.3.0-preview.4)

## 参考資料

- [Model Context Protocol 公式ドキュメント](https://modelcontextprotocol.io/)
- [ModelContextProtocol NuGet パッケージ](https://www.nuget.org/packages/ModelContextProtocol)
