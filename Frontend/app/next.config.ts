import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  eslint: {
    ignoreDuringBuilds: false, // 保持构建时检查（因为 ESLint 规则已降级为警告）
  },
  typescript: {
    ignoreBuildErrors: false, // 保持类型检查
  },
  output: "standalone", // 根据你的 Dockerfile 配置
  
  // 环境变量配置
  env: {
    // 这些值会被注入到客户端，并且在构建时被 Next.js 替换
    // 如果系统环境变量存在，将使用系统环境变量
    MEDSYNTHAI_FRONTEND_API_HOST: process.env.MEDSYNTHAI_FRONTEND_API_HOST || '100.82.33.121',
    MEDSYNTHAI_FRONTEND_API_PORT: process.env.MEDSYNTHAI_FRONTEND_API_PORT || '8009',
  },
};

export default nextConfig;