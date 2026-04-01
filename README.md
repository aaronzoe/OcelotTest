# Ocelot 接口转发测试项目

这是一个使用 Ocelot 的 .NET Core API 网关测试项目，包含下游微服务和负载均衡功能。

## 项目结构

```
OcelotTest/
├── OcelotGateway/  # Ocelot 网关 (端口 5000)
├── ServiceA/        # 下游服务 A (端口 5001)
├── ServiceA2/       # 下游服务 A2 (端口 5003) - 用于负载均衡
├── ServiceB/        # 下游服务 B (端口 5002)
└── OcelotTest.sln
```

## 运行方式

### 分别运行四个项目

打开四个终端窗口，分别执行：

```bash
# 终端1 - 启动 ServiceA
cd ServiceA
dotnet run --launch-profile http

# 终端2 - 启动 ServiceA2 (负载均衡实例)
cd ServiceA2
dotnet run --launch-profile http

# 终端3 - 启动 ServiceB
cd ServiceB
dotnet run --launch-profile http

# 终端4 - 启动 Ocelot 网关
cd OcelotGateway
dotnet run --launch-profile http
```

### 快速开始

```bash
# 查看启动指引
.\start-all.ps1

# 运行测试 (需要先启动所有服务)
.\test-api.ps1
```

## 负载均衡配置

ServiceA 和 ServiceA2 配置了 **RoundRobin (轮询)** 负载均衡策略。

### 负载均衡测试

连续访问 `/servicea/hello` 会在 ServiceA (5001) 和 ServiceA2 (5003) 之间轮流切换：

```powershell
# 运行多次观察负载均衡效果
for ($i=1; $i -le 6; $i++) {
    Invoke-RestMethod "http://localhost:5000/servicea/hello"
}
```

## 测试接口

### 网关地址
http://localhost:5000

### 通过网关访问 ServiceA (含负载均衡)

| 网关路径 | 转发到 | 说明 |
|---------|-------|------|
| `/servicea/weather` | ServiceA/A2 `/api/weather` | 获取天气预报 (负载均衡) |
| `/servicea/hello` | ServiceA/A2 `/api/hello` | Hello 接口 (负载均衡) |
| `/servicea/info` | ServiceA/A2 `/api/info` | 服务信息 (负载均衡) |
| `/servicea/users/{id}` | ServiceA/A2 `/api/users/{id}` | 获取用户信息 (负载均衡) |
| POST `/servicea/data` | ServiceA/A2 `/api/data` | 提交数据 (负载均衡) |

### 通过网关访问 ServiceB

| 网关路径 | 转发到 ServiceB | 说明 |
|---------|----------------|------|
| `/serviceb/hello` | `/api/hello` | Hello 接口 |
| `/serviceb/info` | `/api/info` | 服务信息 |
| `/serviceb/products/{id}` | `/api/products/{id}` | 获取产品信息 |
| `/serviceb/orders` | `/api/orders` | 获取订单列表 |
| POST `/serviceb/data` | `/api/data` | 提交数据 |

### 特殊路由 (含负载均衡)

| 网关路径 | 转发到 | 说明 |
|---------|-------|------|
| `/weather` | ServiceA/A2 `/api/weather` | 天气接口 (负载均衡) |

## 测试示例

### 使用 curl 测试负载均衡

```bash
# 多次请求观察服务切换
for i in {1..6}; do curl http://localhost:5000/servicea/hello; echo ""; done
```

### 使用 PowerShell 测试负载均衡

```powershell
# 测试负载均衡
Write-Host "Testing Load Balancing..."
for ($i=1; $i -le 6; $i++) {
    $result = Invoke-RestMethod "http://localhost:5000/servicea/hello"
    Write-Host "Request $i : From $($result.Service)"
}
```

## 配置说明

Ocelot 配置文件位于 [OcelotGateway/ocelot.json](OcelotGateway/ocelot.json)

### 负载均衡配置示例

```json
{
  "DownstreamHostAndPorts": [
    { "Host": "localhost", "Port": 5001 },
    { "Host": "localhost", "Port": 5003 }
  ],
  "LoadBalancerOptions": {
    "Type": "RoundRobin"
  }
}
```

### 支持的负载均衡类型

- `RoundRobin` - 轮询 (默认)
- `LeastConnection` - 最少连接数
- `CookieStickySessions` - Cookie 粘性会话
- `NoLoadBalancer` - 不使用负载均衡

### 服务端口

- Ocelot Gateway: http://localhost:5000
- ServiceA: http://localhost:5001
- ServiceA2: http://localhost:5003
- ServiceB: http://localhost:5002

## Swagger 文档

- ServiceA Swagger: http://localhost:5001/swagger
- ServiceA2 Swagger: http://localhost:5003/swagger
- ServiceB Swagger: http://localhost:5002/swagger
