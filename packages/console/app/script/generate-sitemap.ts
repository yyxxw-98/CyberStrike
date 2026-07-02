#!/usr/bin/env bun
import { readdir, writeFile, access } from "fs/promises"
import { join, dirname } from "path"
import { fileURLToPath } from "url"
import { config } from "../src/config.js"
import { LOCALES, route } from "../src/lib/language.js"

const __dirname = dirname(fileURLToPath(import.meta.url))
const BASE_URL = config.baseUrl
const PUBLIC_DIR = join(__dirname, "../public")
const ROUTES_DIR = join(__dirname, "../src/routes")

// 根据实际项目结构调整此处路径
const DOCS_DIR = join(__dirname, "../../../web/src/content/docs")

interface SitemapEntry {
  url: string
  priority: number
  changefreq: string
}

// XML 特殊字符转义，保证输出合法
function escapeXml(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;")
}

// 检查目录是否存在
async function directoryExists(path: string): Promise<boolean> {
  try {
    await access(path)
    return true
  } catch {
    return false
  }
}

async function getMainRoutes(): Promise<SitemapEntry[]> {
  const routes: SitemapEntry[] = []

  const staticRoutes = [
    { path: "/", priority: 1.0, changefreq: "daily" },
    { path: "/enterprise", priority: 0.8, changefreq: "weekly" },
    { path: "/brand", priority: 0.6, changefreq: "monthly" },
    { path: "/zen", priority: 0.8, changefreq: "weekly" },
  ]

  for (const item of staticRoutes) {
    for (const locale of LOCALES) {
      routes.push({
        url: `${BASE_URL}${route(locale, item.path)}`,
        priority: item.priority,
        changefreq: item.changefreq,
      })
    }
  }

  return routes
}

async function getDocsRoutes(): Promise<SitemapEntry[]> {
  const routes: SitemapEntry[] = []

  const docsDirExists = await directoryExists(DOCS_DIR)
  if (!docsDirExists) {
    console.log(`Docs directory not found at ${DOCS_DIR}, skipping docs routes`)
    return routes
  }

  try {
    const files = await readdir(DOCS_DIR)

    for (const file of files) {
      if (!file.endsWith(".mdx")) continue

      const slug = file.replace(".mdx", "")
      const path = slug === "index" ? "/docs/" : `/docs/${slug}`

      for (const locale of LOCALES) {
        routes.push({
          url: `${BASE_URL}${route(locale, path)}`,
          priority: slug === "index" ? 0.9 : 0.7,
          changefreq: "weekly",
        })
      }
    }
  } catch (error) {
    console.error("Failed to read docs files:", (error as Error).message)
  }

  return routes
}

function generateSitemapXML(entries: SitemapEntry[]): string {
  const urls = entries
    .map(
      (entry) => `  <url>
    <loc>${escapeXml(entry.url)}</loc>
    <changefreq>${entry.changefreq}</changefreq>
    <priority>${entry.priority.toFixed(1)}</priority>
  </url>`,
    )
    .join("\n")

  return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>`
}

async function main() {
  console.log("Generating sitemap...")

  const [mainRoutes, docsRoutes] = await Promise.all([
    getMainRoutes(),
    getDocsRoutes(),
  ])

  const allRoutes = [...mainRoutes, ...docsRoutes]

  console.log(`Found ${mainRoutes.length} main routes`)
  console.log(`Found ${docsRoutes.length} docs routes`)
  console.log(`Total: ${allRoutes.length} routes`)

  const xml = generateSitemapXML(allRoutes)

  const outputPath = join(PUBLIC_DIR, "sitemap.xml")
  await writeFile(outputPath, xml, "utf-8")

  console.log(`✓ Sitemap generated at ${outputPath}`)
}

main()