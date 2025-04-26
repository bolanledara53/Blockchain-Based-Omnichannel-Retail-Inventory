;; Fulfillment Contract
;; Tracks order processing and delivery

(define-data-var admin principal tx-sender)

;; Map to track order fulfillment
(define-map orders
  { order-id: (string-ascii 32) }
  {
    customer-id: (string-ascii 32),
    store-id: (string-ascii 32),
    status: (string-ascii 20),
    creation-date: uint,
    fulfillment-date: (optional uint)
  }
)

;; Map to track order items
(define-map order-items
  { order-id: (string-ascii 32), product-id: (string-ascii 32) }
  {
    quantity: uint
  }
)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Create a new order
(define-public (create-order (order-id (string-ascii 32)) (customer-id (string-ascii 32)) (store-id (string-ascii 32)))
  (begin
    (asserts! (is-admin) (err u1))
    (ok (map-insert orders
      { order-id: order-id }
      {
        customer-id: customer-id,
        store-id: store-id,
        status: "created",
        creation-date: block-height,
        fulfillment-date: none
      }
    ))
  )
)

;; Add item to order
(define-public (add-order-item (order-id (string-ascii 32)) (product-id (string-ascii 32)) (quantity uint))
  (begin
    (asserts! (is-admin) (err u1))
    (ok (map-insert order-items
      { order-id: order-id, product-id: product-id }
      {
        quantity: quantity
      }
    ))
  )
)

;; Update order status
(define-public (update-order-status (order-id (string-ascii 32)) (status (string-ascii 20)))
  (begin
    (asserts! (is-admin) (err u1))
    (match (map-get? orders { order-id: order-id })
      order (ok (map-set orders
              { order-id: order-id }
              (merge order {
                status: status,
                fulfillment-date: (if (is-eq status "fulfilled") (some block-height) (get fulfillment-date order))
              })))
      (err u404)
    )
  )
)

;; Get order details
(define-read-only (get-order (order-id (string-ascii 32)))
  (map-get? orders { order-id: order-id })
)

;; Get order item details
(define-read-only (get-order-item (order-id (string-ascii 32)) (product-id (string-ascii 32)))
  (map-get? order-items { order-id: order-id, product-id: product-id })
)
