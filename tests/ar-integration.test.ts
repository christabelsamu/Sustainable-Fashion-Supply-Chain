import { describe, it, expect, beforeEach } from 'vitest'

// Mock blockchain state
let arModels: { [key: number]: string } = {}
let virtualTryOns: { [key: string]: { tryOnCount: number, lastTryOn: number } } = {}

// Mock contract functions
const addArModel = (sender: string, garmentId: number, modelUrl: string) => {
  if (sender !== 'contract-owner') {
    return { success: false, error: 100 }
  }
  arModels[garmentId] = modelUrl
  return { success: true }
}

const recordVirtualTryOn = (user: string, garmentId: number) => {
  const key = `${user}:${garmentId}`
  const currentData = virtualTryOns[key] || { tryOnCount: 0, lastTryOn: 0 }
  virtualTryOns[key] = {
    tryOnCount: currentData.tryOnCount + 1,
    lastTryOn: Date.now()
  }
  return { success: true }
}

const getArModel = (garmentId: number) => {
  return { success: true, value: arModels[garmentId] }
}

const getTryOnData = (user: string, garmentId: number) => {
  const key = `${user}:${garmentId}`
  return { success: true, value: virtualTryOns[key] }
}

describe('AR Integration', () => {
  beforeEach(() => {
    arModels = {}
    virtualTryOns = {}
  })
  
  it('allows adding AR models', () => {
    const result = addArModel('contract-owner', 1, 'https://example.com/model1.glb')
    expect(result.success).toBe(true)
    expect(arModels[1]).toBe('https://example.com/model1.glb')
  })
  
  it('prevents unauthorized AR model addition', () => {
    const result = addArModel('user1', 1, 'https://example.com/model1.glb')
    expect(result.success).toBe(false)
    expect(result.error).toBe(100)
    expect(arModels[1]).toBeUndefined()
  })
  
  it('allows recording virtual try-ons', () => {
    const result = recordVirtualTryOn('user1', 1)
    expect(result.success).toBe(true)
    expect(virtualTryOns['user1:1'].tryOnCount).toBe(1)
  })
  
  it('increments try-on count for multiple tries', () => {
    recordVirtualTryOn('user1', 1)
    recordVirtualTryOn('user1', 1)
    const result = getTryOnData('user1', 1)
    expect(result.success).toBe(true)
    expect(result.value.tryOnCount).toBe(2)
  })
  
  it('allows retrieving AR model', () => {
    addArModel('contract-owner', 1, 'https://example.com/model1.glb')
    const result = getArModel(1)
    expect(result.success).toBe(true)
    expect(result.value).toBe('https://example.com/model1.glb')
  })
})

