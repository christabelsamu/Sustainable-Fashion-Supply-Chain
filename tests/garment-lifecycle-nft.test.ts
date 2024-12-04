import { describe, it, expect, beforeEach } from 'vitest'

// Mock blockchain state
let garmentNFTs: { [key: number]: string } = {}
let garmentDetails: { [key: number]: any } = {}
let lastGarmentId = 0

// Mock contract functions
const mintGarment = (sender: string, rawMaterials: string[], sustainabilityScore: number) => {
  lastGarmentId++
  garmentNFTs[lastGarmentId] = sender
  garmentDetails[lastGarmentId] = {
    rawMaterials,
    manufacturer: sender,
    productionDate: Date.now(),
    sustainabilityScore,
    currentOwner: sender
  }
  return { success: true, value: lastGarmentId }
}

const transferGarment = (sender: string, garmentId: number, recipient: string) => {
  if (garmentNFTs[garmentId] !== sender) {
    return { success: false, error: 102 }
  }
  garmentNFTs[garmentId] = recipient
  garmentDetails[garmentId].currentOwner = recipient
  return { success: true }
}

const getGarmentDetails = (garmentId: number) => {
  return { success: true, value: garmentDetails[garmentId] }
}

const getGarmentOwner = (garmentId: number) => {
  return { success: true, value: garmentNFTs[garmentId] }
}

describe('Garment Lifecycle NFT', () => {
  beforeEach(() => {
    garmentNFTs = {}
    garmentDetails = {}
    lastGarmentId = 0
  })
  
  it('allows minting a new garment', () => {
    const result = mintGarment('manufacturer1', ['organic cotton', 'recycled polyester'], 85)
    expect(result.success).toBe(true)
    expect(result.value).toBe(1)
    expect(garmentNFTs[1]).toBe('manufacturer1')
    expect(garmentDetails[1].rawMaterials).toContain('organic cotton')
    expect(garmentDetails[1].sustainabilityScore).toBe(85)
  })
  
  it('allows transferring a garment', () => {
    mintGarment('manufacturer1', ['organic cotton', 'recycled polyester'], 85)
    const result = transferGarment('manufacturer1', 1, 'user1')
    expect(result.success).toBe(true)
    expect(garmentNFTs[1]).toBe('user1')
    expect(garmentDetails[1].currentOwner).toBe('user1')
  })
  
  it('prevents unauthorized transfer', () => {
    mintGarment('manufacturer1', ['organic cotton', 'recycled polyester'], 85)
    const result = transferGarment('user2', 1, 'user1')
    expect(result.success).toBe(false)
    expect(result.error).toBe(102)
    expect(garmentNFTs[1]).toBe('manufacturer1')
  })
  
  it('allows retrieving garment details', () => {
    mintGarment('manufacturer1', ['organic cotton', 'recycled polyester'], 85)
    const result = getGarmentDetails(1)
    expect(result.success).toBe(true)
    expect(result.value.manufacturer).toBe('manufacturer1')
    expect(result.value.sustainabilityScore).toBe(85)
  })
  
  it('allows retrieving garment owner', () => {
    mintGarment('manufacturer1', ['organic cotton', 'recycled polyester'], 85)
    const result = getGarmentOwner(1)
    expect(result.success).toBe(true)
    expect(result.value).toBe('manufacturer1')
  })
})

