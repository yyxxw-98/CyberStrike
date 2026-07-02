export * from "./gen/types.gen"
import { createClient } from "./gen/client/client.gen.js"
import { type Config } from "./gen/client/types.gen.js"
import { CyberstrikeClient } from "./gen/sdk.gen.js"
export { type Config as CyberstrikeClientConfig, CyberstrikeClient }

export function createCyberstrikeClient(config?: Config & { directory?: string; headers?: Record<string, string> }) {
  if (!config?.fetch) {
    const customFetch: any = (req: any) => {
      // @ts-ignore
      req.timeout = false
      return fetch(req)
    }
    config = {
      ...config,
      fetch: customFetch,
    }
  }

  if (config?.directory) {
    const isNonASCII = /[^\x00-\x7F]/.test(config.directory)
    const encodedDirectory = isNonASCII ? encodeURIComponent(config.directory) : config.directory
    // 统一转成普通对象，规避Headers类型冲突
    const oldHeaders = config.headers ? Object.fromEntries(new Headers(config.headers)) : {}
    config.headers = {
      ...oldHeaders,
      "x-cyberstrike-directory": encodedDirectory,
    }
  }

  const client = createClient(config)
  return new CyberstrikeClient({ client })
}
