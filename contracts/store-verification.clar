;; Store Verification Contract
;; Validates legitimate retail locations

(define-data-var admin principal tx-sender)

;; Map to store verified retail locations
(define-map verified-stores
  { store-id: (string-ascii 32) }
  {
    name: (string-ascii 100),
    location: (string-ascii 100),
    is-verified: bool,
    verification-date: uint
  }
)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Add a new store to the verified list
(define-public (register-store (store-id (string-ascii 32)) (name (string-ascii 100)) (location (string-ascii 100)))
  (begin
    (asserts! (is-admin) (err u1))
    (ok (map-insert verified-stores
      { store-id: store-id }
      {
        name: name,
        location: location,
        is-verified: true,
        verification-date: block-height
      }
    ))
  )
)

;; Check if a store is verified
(define-read-only (is-store-verified (store-id (string-ascii 32)))
  (match (map-get? verified-stores { store-id: store-id })
    store (ok (get is-verified store))
    (err u404)
  )
)

;; Update store verification status
(define-public (update-verification (store-id (string-ascii 32)) (status bool))
  (begin
    (asserts! (is-admin) (err u1))
    (match (map-get? verified-stores { store-id: store-id })
      store (ok (map-set verified-stores
                { store-id: store-id }
                (merge store { is-verified: status, verification-date: block-height })))
      (err u404)
    )
  )
)

;; Get store details
(define-read-only (get-store-details (store-id (string-ascii 32)))
  (map-get? verified-stores { store-id: store-id })
)
