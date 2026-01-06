'use client'
import dynamic from 'next/dynamic'

// 动态导入避免SSR问题
const PreTriageSystem = dynamic(() => import('@/pre-triage/page'), { 
  loading: () => <div>加载预分诊系统...</div>,
  ssr: false 
})

export default function UnifiedEntry() {
  return (
    <div className="pre-triage-system">
      <PreTriageSystem />
    </div>
  )
}