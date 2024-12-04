;; Sustainability Incentives Contract

(define-fungible-token sustainability-token)

(define-map user-points
  { user: principal }
  { points: uint }
)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-points (err u101))

(define-public (award-points (user principal) (points uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let
      ((current-points (default-to u0 (get points (map-get? user-points { user: user })))))
      (map-set user-points
        { user: user }
        { points: (+ current-points points) }
      )
      (try! (ft-mint? sustainability-token points user))
      (ok true)
    )
  )
)

(define-public (redeem-points (points uint))
  (let
    ((user-balance (default-to u0 (get points (map-get? user-points { user: tx-sender })))))
    (asserts! (>= user-balance points) err-insufficient-points)
    (map-set user-points
      { user: tx-sender }
      { points: (- user-balance points) }
    )
    (try! (ft-burn? sustainability-token points tx-sender))
    (ok true)
  )
)

(define-read-only (get-user-points (user principal))
  (default-to u0 (get points (map-get? user-points { user: user })))
)

(define-read-only (get-token-balance (account principal))
  (ft-get-balance sustainability-token account)
)

