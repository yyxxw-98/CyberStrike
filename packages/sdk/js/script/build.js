import { dirname, join, resolve } from "path";
import { fileURLToPath } from "url";
import { $ } from "bun";
import { createClient } from "@hey-api/openapi-ts";
const __filename = fileURLToPath(import.meta.url);
const scriptDir = dirname(__filename);
// 层级修正，定位packages/cyberstrike
const cyberDir = resolve(scriptDir, "../../../cyberstrike");
const openapiPath = join(scriptDir, "openapi.json");
// Windows兼容生成openapi.json，抛弃管道重定向
const genOutput = await $ `bun dev generate`.cwd(cyberDir).text();
await Bun.write(openapiPath, genOutput);
// 生成SDK，开启自动.ts导入后缀，兼容node16解析
await createClient({
    input: openapiPath,
    output: {
        path: "./src/v2/gen",
        tsConfigPath: join(scriptDir, "tsconfig.json"),
        clean: true,
        fileExtension: ".ts" // 关键：生成导入带.ts后缀，解决TS2834
    },
    plugins: [
        {
            name: "@hey-api/typescript",
            exportFromIndex: false,
        },
        {
            name: "@hey-api/sdk",
            // 替换废弃instance配置，消除警告
            operations: {
                strategy: "single",
                containerName: "CyberstrikeClient",
                methods: "instance"
            },
            exportFromIndex: false,
            auth: false,
            paramsStructure: "flat",
        },
        {
            name: "@hey-api/client-fetch",
            exportFromIndex: false,
            baseUrl: "http://localhost:4096",
        },
    ],
});
// 格式化生成代码，修复导入排版
await $ `bun prettier --write src/gen`;
await $ `bun prettier --write src/v2`;
// TS类型编译（tsconfig修改后启用）
await $ `bun tsc`;
// 清理产物与临时文件
await $ `rm -rf dist`;
await $ `rm openapi.json`;
