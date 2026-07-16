# 基于官方原始镜像构建，与compose配置镜像保持一致
FROM puritan3116/grok-register-lite:latest

# 设置时区，匹配上海时区配置
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 核心服务环境变量配置，完全对齐docker-compose参数
ENV GROK_REGISTER_LITE=1 \
    GROK_REGISTER_LITE_HOST=0.0.0.0 \
    GROK_REGISTER_LITE_PORT=8788 \
    GROK_REGISTER_LITE_DATA_DIR=/data \
    GROK_REGISTER_LITE_DB=/data/register_lite.sqlite3 \
    GROK_REGISTER_LITE_OUTPUT_DIR=/data/outputs \
    GROK2API_AUTH_FILE=/data/outputs/grok2api_auth.json \
    GROK_REGISTER_ADMIN_BASE_PATH=/admin \
    GROK_REGISTER_ADMIN_FORCE_RESET=0 \
    GROK_REGISTER_ALLOW_PRIVATE_URLS=1 \
    GROK_REGISTER_ALLOW_HTTP_URLS=0 \
    GROK2API_CAPTCHA_PROVIDER=local \
    CAPTCHA_PROVIDER=local \
    GROK2API_INLINE_SOLVER=1 \
    GROK2API_LOCAL_SOLVER_URL=http://127.0.0.1:5072 \
    LOCAL_SOLVER_URL=http://127.0.0.1:5072 \
    TURNSTILE_HOST=127.0.0.1 \
 TURNSTILE_PORT=5072 \
    TURNSTILE_THREAD=2 \
    TURNSTILE_BROWSER_TYPE=camoufox \
    TURNSTILE_LAZY=1 \
    TURNSTILE_IDLE_SEC=180 \
    TURNSTILE_BROWSER_AUTO_FETCH=1 \
    XDG_CACHE_HOME=/data/cache \
    PLAYWRIGHT_BROWSERS_PATH=/data/cache/ms-playwright

# 暴露服务端口
EXPOSE 8788

# 创建数据持久化目录，避免权限问题
RUN mkdir -p /data /data/outputs /data/cache/ms-playwright

# 设置数据卷挂载目录，对应宿主机数据持久化
VOLUME ["/data"]

# 健康检查配置，完全对齐原compose检测规则
HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=5 \
    CMD curl -fsS http://127.0.0.1:8788/admin/api/session || exit 1

# 容器启动默认命令（沿用原镜像启动逻辑）
CMD ["sh", "-c", "exec /app/start.sh"]
