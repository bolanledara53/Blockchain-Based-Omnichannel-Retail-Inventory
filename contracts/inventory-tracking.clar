;; Inventory Tracking Contract
;; Monitors stock levels across channels

(define-data-var admin principal tx-sender)

;; Map to track inventory across stores
(define-map inventory
  { store-id: (string-ascii 32), product-id: (string-ascii 32) }
  {
    quantity: uint,
    last-updated: uint
  }
)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Update inventory for a product at a specific store
(define-public (update-inventory (store-id (string-ascii 32)) (product-id (string-ascii 32)) (quantity uint))
  (begin
    (asserts! (is-admin) (err u1))
    (ok (map-set inventory
      { store-id: store-id, product-id: product-id }
      {
        quantity: quantity,
        last-updated: block-height
      }
    ))
  )
)

;; Increase inventory quantity
(define-public (increase-inventory (store-id (string-ascii 32)) (product-id (string-ascii 32)) (amount uint))
  (begin
    (asserts! (is-admin) (err u1))
    (match (map-get? inventory { store-id: store-id, product-id: product-id })
      inv (ok (map-set inventory
              { store-id: store-id, product-id: product-id }
              {
                quantity: (+ (get quantity inv) amount),
                last-updated: block-height
              }))
      (err u404)
    )
  )
)

;; Decrease inventory quantity
(define-public (decrease-inventory (store-id (string-ascii 32)) (product-id (string-ascii 32)) (amount uint))
  (begin
    (asserts! (is-admin) (err u1))
    (match (map-get? inventory { store-id: store-id, product-id: product-id })
      inv (begin
            (asserts! (>= (get quantity inv) amount) (err u3))
            (ok (map-set inventory
                { store-id: store-id, product-id: product-id }
                {
                  quantity: (- (get quantity inv) amount),
                  last-updated: block-height
                })))
      (err u404)
    )
  )
)

;; Get current inventory for a product at a specific store
(define-read-only (get-inventory (store-id (string-ascii 32)) (product-id (string-ascii 32)))
  (map-get? inventory { store-id: store-id, product-id: product-id })
)

;; Check if product is in stock at a specific store
(define-read-only (is-in-stock (store-id (string-ascii 32)) (product-id (string-ascii 32)))
  (match (map-get? inventory { store-id: store-id, product-id: product-id })
    inv (> (get quantity inv) u0)
    false
  )
)
