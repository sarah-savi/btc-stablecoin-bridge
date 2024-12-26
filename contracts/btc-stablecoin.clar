;; BTC-Stablecoin Bridge Contract
;; 
;; This smart contract facilitates the creation and management of a BTC-backed stablecoin on the Stacks blockchain. 
;; It includes functionalities for collateral management, stablecoin minting and burning, liquidity provision, and price updates.
;; The contract ensures that all operations adhere to predefined constraints and ratios to maintain stability and security.

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1001))
(define-constant ERR-INVALID-AMOUNT (err u1002))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u1003))
(define-constant ERR-POOL-EMPTY (err u1004))
(define-constant ERR-SLIPPAGE-TOO-HIGH (err u1005))
(define-constant ERR-BELOW-MINIMUM (err u1006))
(define-constant ERR-ABOVE-MAXIMUM (err u1007))
(define-constant ERR-ALREADY-INITIALIZED (err u1008))
(define-constant ERR-NOT-INITIALIZED (err u1009))
(define-constant ERR-INVALID-PRICE (err u1010))

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant MINIMUM-COLLATERAL-RATIO u150) ;; 150%
(define-constant LIQUIDATION-RATIO u130) ;; 130%
(define-constant MINIMUM-DEPOSIT u1000000) ;; 0.01 BTC (in sats)
(define-constant POOL-FEE-RATE u3) ;; 0.3%
(define-constant PRECISION u1000000) ;; 6 decimal places
(define-constant MAX-PRICE u100000000000) ;; Maximum allowed price (1M USD with 6 decimal precision)
(define-constant MAX-MINT-AMOUNT u1000000000000) ;; Maximum mint amount (10K USD with 6 decimal precision)

;; Data Variables
(define-data-var contract-initialized bool false)
(define-data-var oracle-price uint u0) ;; BTC/USD price with 6 decimal precision
(define-data-var total-supply uint u0)
(define-data-var pool-btc-balance uint u0)
(define-data-var pool-stable-balance uint u0)

;; Price validation function
(define-private (validate-price (price uint))
    (and 
        (> price u0)
        (<= price MAX-PRICE)
    )
)

;; Data Maps
(define-map balances principal uint)
(define-map stablecoin-balances principal uint)
(define-map collateral-vaults principal {
    btc-locked: uint,
    stablecoin-minted: uint,
    last-update-height: uint
})
(define-map liquidity-providers principal {
    pool-tokens: uint,
    btc-provided: uint,
    stable-provided: uint
})

;; Private Functions
(define-private (transfer-balance (amount uint) (sender principal) (recipient principal))
    (let (
        (sender-balance (default-to u0 (map-get? balances sender)))
        (recipient-balance (default-to u0 (map-get? balances recipient)))
    )
    (if (>= sender-balance amount)
        (begin
            (map-set balances sender (- sender-balance amount))
            (map-set balances recipient (+ recipient-balance amount))
            (ok true)
        )
        ERR-INSUFFICIENT-BALANCE
    ))
)

(define-private (calculate-collateral-ratio (btc-amount uint) (stablecoin-amount uint))
    (if (is-eq stablecoin-amount u0)
        PRECISION
        (let (
            (btc-value-usd (* btc-amount (var-get oracle-price)))
            (collateral-ratio (/ (* btc-value-usd u100) stablecoin-amount))
        )
        collateral-ratio))
)

(define-private (check-collateral-requirement (btc-locked uint) (stablecoin-amount uint))
    (let (
        (ratio (calculate-collateral-ratio btc-locked stablecoin-amount))
    )
    (if (>= ratio MINIMUM-COLLATERAL-RATIO)
        (ok true)
        ERR-INSUFFICIENT-COLLATERAL))
)

(define-private (calculate-lp-tokens (btc-amount uint) (stable-amount uint))
    (let (
        (pool-btc (var-get pool-btc-balance))
        (pool-stable (var-get pool-stable-balance))
    )
    (if (is-eq pool-btc u0)
        (sqrt (* btc-amount stable-amount))
        (/ (* btc-amount (sqrt (* pool-btc pool-stable))) pool-btc)
    ))
)

(define-private (sqrt (x uint))
    (let (
        (next (+ (/ x u2) u1))
    )
    (if (<= x u2)
        u1
        next
    ))
)

;; Public Functions
(define-public (initialize (initial-price uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (asserts! (not (var-get contract-initialized)) ERR-ALREADY-INITIALIZED)
        (asserts! (validate-price initial-price) ERR-INVALID-PRICE)
        (var-set oracle-price initial-price)
        (var-set contract-initialized true)
        (ok true)
    )
)

;; Update price with validation
(define-public (update-price (new-price uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (asserts! (validate-price new-price) ERR-INVALID-PRICE)
        (var-set oracle-price new-price)
        (ok true)
    )
)

(define-public (deposit-collateral (btc-amount uint))
    (let (
        (sender-vault (default-to {
            btc-locked: u0,
            stablecoin-minted: u0,
            last-update-height: block-height
        } (map-get? collateral-vaults tx-sender)))
    )
    (begin
        (asserts! (>= btc-amount MINIMUM-DEPOSIT) ERR-BELOW-MINIMUM)
        (try! (transfer-balance btc-amount tx-sender (as-contract tx-sender)))
        (map-set collateral-vaults tx-sender {
            btc-locked: (+ btc-amount (get btc-locked sender-vault)),
            stablecoin-minted: (get stablecoin-minted sender-vault),
            last-update-height: block-height
        })
        (ok true)
    ))
)

;; Mint stablecoin with amount validation
(define-public (mint-stablecoin (amount uint))
    (let (
        (vault (unwrap! (map-get? collateral-vaults tx-sender) ERR-NOT-INITIALIZED))
        (current-stable-balance (default-to u0 (map-get? stablecoin-balances tx-sender)))
        (new-stable-amount (+ (get stablecoin-minted vault) amount))
    )
    (begin
        (asserts! (and 
            (> amount u0)
            (<= amount MAX-MINT-AMOUNT)
            (<= (+ (var-get total-supply) amount) (* (var-get pool-btc-balance) (var-get oracle-price)))
        ) ERR-INVALID-AMOUNT)
        (try! (check-collateral-requirement (get btc-locked vault) new-stable-amount))
        
        ;; Update vault
        (map-set collateral-vaults tx-sender {
            btc-locked: (get btc-locked vault),
            stablecoin-minted: new-stable-amount,
            last-update-height: block-height
        })
        
        ;; Update balances safely
        (let (
            (new-total-supply (+ (var-get total-supply) amount))
            (new-user-balance (+ current-stable-balance amount))
        )
        (asserts! (<= new-total-supply MAX-MINT-AMOUNT) ERR-ABOVE-MAXIMUM)
        (map-set stablecoin-balances tx-sender new-user-balance)
        (var-set total-supply new-total-supply)
        (ok true))
    ))
)

(define-public (burn-stablecoin (amount uint))
    (let (
        (vault (unwrap! (map-get? collateral-vaults tx-sender) ERR-NOT-INITIALIZED))
        (current-stable-balance (default-to u0 (map-get? stablecoin-balances tx-sender)))
    )
    (begin
        (asserts! (>= current-stable-balance amount) ERR-INSUFFICIENT-BALANCE)
        (map-set collateral-vaults tx-sender {
            btc-locked: (get btc-locked vault),
            stablecoin-minted: (- (get stablecoin-minted vault) amount),
            last-update-height: block-height
        })
        (map-set stablecoin-balances tx-sender (- current-stable-balance amount))
        (var-set total-supply (- (var-get total-supply) amount))
        (ok true)
    ))
)