;; Product Registration Contract
;; Records details of merchandise

(define-data-var admin principal tx-sender)

;; Map to store product details
(define-map products
  { product-id: (string-ascii 32) }
  {
    name: (string-ascii 100),
    description: (string-ascii 255),
    category: (string-ascii 50),
    manufacturer: (string-ascii 100),
    creation-date: uint
  }
)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Register a new product
(define-public (register-product
    (product-id (string-ascii 32))
    (name (string-ascii 100))
    (description (string-ascii 255))
    (category (string-ascii 50))
    (manufacturer (string-ascii 100)))
  (begin
    (asserts! (is-admin) (err u1))
    (ok (map-insert products
      { product-id: product-id }
      {
        name: name,
        description: description,
        category: category,
        manufacturer: manufacturer,
        creation-date: block-height
      }
    ))
  )
)

;; Update product details
(define-public (update-product
    (product-id (string-ascii 32))
    (name (string-ascii 100))
    (description (string-ascii 255))
    (category (string-ascii 50))
    (manufacturer (string-ascii 100)))
  (begin
    (asserts! (is-admin) (err u1))
    (match (map-get? products { product-id: product-id })
      product (ok (map-set products
                { product-id: product-id }
                {
                  name: name,
                  description: description,
                  category: category,
                  manufacturer: manufacturer,
                  creation-date: (get creation-date product)
                }))
      (err u404)
    )
  )
)

;; Get product details
(define-read-only (get-product-details (product-id (string-ascii 32)))
  (map-get? products { product-id: product-id })
)

;; Check if product exists
(define-read-only (product-exists (product-id (string-ascii 32)))
  (is-some (map-get? products { product-id: product-id }))
)
