;; Fair Labor Practices Contract

(define-map labor-practices
  { manufacturer: principal }
  {
    certification: (string-ascii 64),
    last-audit-date: uint,
    compliance-score: uint
  }
)

(define-map worker-payments
  { worker: principal }
  { total-paid: uint }
)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-unauthorized (err u101))

(define-public (register-manufacturer (certification (string-ascii 64)) (compliance-score uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set labor-practices
      { manufacturer: tx-sender }
      {
        certification: certification,
        last-audit-date: block-height,
        compliance-score: compliance-score
      }
    ))
  )
)

(define-public (update-compliance-score (manufacturer principal) (new-score uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set labor-practices
      { manufacturer: manufacturer }
      (merge (unwrap! (map-get? labor-practices { manufacturer: manufacturer }) err-unauthorized)
             { compliance-score: new-score, last-audit-date: block-height })
    ))
  )
)

(define-public (record-worker-payment (worker principal) (amount uint))
  (let
    ((current-total (default-to u0 (get total-paid (map-get? worker-payments { worker: worker })))))
    (ok (map-set worker-payments
      { worker: worker }
      { total-paid: (+ current-total amount) }
    ))
  )
)

(define-read-only (get-manufacturer-compliance (manufacturer principal))
  (map-get? labor-practices { manufacturer: manufacturer })
)

(define-read-only (get-worker-payments (worker principal))
  (map-get? worker-payments { worker: worker })
)

