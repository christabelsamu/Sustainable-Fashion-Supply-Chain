;; Garment Lifecycle NFT Contract

(define-non-fungible-token garment-nft uint)

(define-map garment-details
  { garment-id: uint }
  {
    raw-materials: (list 5 (string-ascii 64)),
    manufacturer: principal,
    production-date: uint,
    sustainability-score: uint,
    current-owner: principal
  }
)

(define-data-var last-garment-id uint u0)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

(define-public (mint-garment (raw-materials (list 5 (string-ascii 64))) (sustainability-score uint))
  (let
    ((new-garment-id (+ (var-get last-garment-id) u1)))
    (try! (nft-mint? garment-nft new-garment-id tx-sender))
    (map-set garment-details
      { garment-id: new-garment-id }
      {
        raw-materials: raw-materials,
        manufacturer: tx-sender,
        production-date: block-height,
        sustainability-score: sustainability-score,
        current-owner: tx-sender
      }
    )
    (var-set last-garment-id new-garment-id)
    (ok new-garment-id)
  )
)

(define-public (transfer-garment (garment-id uint) (recipient principal))
  (let
    ((garment-owner (unwrap! (nft-get-owner? garment-nft garment-id) err-not-found)))
    (asserts! (is-eq tx-sender garment-owner) err-unauthorized)
    (try! (nft-transfer? garment-nft garment-id tx-sender recipient))
    (map-set garment-details
      { garment-id: garment-id }
      (merge (unwrap! (map-get? garment-details { garment-id: garment-id }) err-not-found)
             { current-owner: recipient })
    )
    (ok true)
  )
)

(define-read-only (get-garment-details (garment-id uint))
  (map-get? garment-details { garment-id: garment-id })
)

(define-read-only (get-garment-owner (garment-id uint))
  (nft-get-owner? garment-nft garment-id)
)
