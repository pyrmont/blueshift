(def- base64-chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")

(defn encode
  "Encode a string or buffer to Base64"
  [data]
  (def bytes (if (string? data) (string/bytes data) data))
  (def len (length bytes))
  (def buf @"")
  (var i 0)
  # Process 3 bytes at a time
  (while (< (+ i 2) len)
    (def b1 (bytes i))
    (def b2 (bytes (+ i 1)))
    (def b3 (bytes (+ i 2)))
    # Convert 3 bytes (24 bits) to 4 base64 characters (6 bits each)
    (buffer/push buf
      (base64-chars (brshift b1 2))
      (base64-chars (bor (blshift (band b1 0x03) 4) (brshift b2 4)))
      (base64-chars (bor (blshift (band b2 0x0F) 2) (brshift b3 6)))
      (base64-chars (band b3 0x3F)))
    (+= i 3))
  # Handle remaining bytes (1 or 2 bytes)
  (def remaining (- len i))
  (when (> remaining 0)
    (def b1 (bytes i))
    (buffer/push buf (base64-chars (brshift b1 2)))
    (if (= remaining 1)
      # 1 byte remaining: add 1 char + 2 padding
      (buffer/push buf
        (base64-chars (blshift (band b1 0x03) 4))
        "==")
      # 2 bytes remaining: add 2 chars + 1 padding
      (do
        (def b2 (bytes (+ i 1)))
        (buffer/push buf
          (base64-chars (bor (blshift (band b1 0x03) 4) (brshift b2 4)))
          (base64-chars (blshift (band b2 0x0F) 2))
          "="))))
  (string buf))
