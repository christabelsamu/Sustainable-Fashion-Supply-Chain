;; AR Integration Contract

(define-map ar-models
  { garment-id: uint }
  { model-url: (string-utf8 256) }
)

(define-map virtual-try-ons
  { user: principal, garment-id: uint }
  { try-on-count: uint, last-try-on: uint }
)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))

(define-public (add-ar-model (garment-id uint) (model-url (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set ar-models
      { garment-id: garment-id }
      { model-url: model-url }
    ))
  )
)

(define-public (record-virtual-try-on (garment-id uint))
  (let
    ((current-data (default-to { try-on-count: u0, last-try-on: u0 }
                    (map-get? virtual-try-ons { user: tx-sender, garment-id: garment-id }))))
    (ok (map-set virtual-try-ons
      { user: tx-sender, garment-id: garment-id }
      {
        try-on-count: (+ (get try-on-count current-data) u1),
        last-try-on: block-height
      }
    ))
  )
)

(define-read-only (get-ar-model (garment-id uint))
  (map-get? ar-models { garment-id: garment-id })
)

(define-read-only (get-try-on-data (user principal) (garment-id uint))
  (map-get? virtual-try-ons { user: user, garment-id: garment-id })
)

