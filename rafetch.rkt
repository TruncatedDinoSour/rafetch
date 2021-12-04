#!/usr/bin/env racket
#lang racket/base

(require mzlib/os
         racket/system
         dyoo-while-loop
         racket/list
         racket/port
         racket/date
         2htdp/batch-io)


(define (cmd command)
    (regexp-replace #rx"\r?\n$"
        (with-output-to-string (lambda () (system command)))
        ""
    )
)


(define (get_distro)
    (define info (read-file "/etc/os-release"))
    (define name "Unknown")

    (for (((line) (regexp-split #rx"\n" info)))
        (define name_reg (regexp-split #rx"^NAME=" line))

        (unless (< (length name_reg) 2)
          (set! name (list-ref name_reg 1))
        )
    )

    name
)


(define logo_sep "  ")
(define logo (regexp-split #rx"\n" (read-file "logo")))
(define logo_idx 0)


(define info (hash
    "Distro" (get_distro)
    "Kernel" (cmd "uname -r")
    "Uptime" (cmd "uptime --pretty")
    "Terminal" (getenv "TERM")
    "Racket" (cmd "racket --version")
    "Time" (date->string (current-date))
))


(for ([_ (make-vector (+ (string-length (first logo)) (string-length logo_sep)))])
    (display " ")
)

(printf "~a@~a~%" (getenv "USER") (gethostname))

(for (((key value) info))
    (define extra "")
    (unless (<= (length logo) logo_idx)
        (set! extra (list-ref logo logo_idx)
    ))

    (printf "~a~a~a: ~a~%" extra logo_sep key value)
    (set! logo_idx (+ logo_idx 1))
)

(while (not (<= (length logo) logo_idx))
    (begin
        (display (list-ref logo logo_idx))
        (newline)
        (set! logo_idx (+ logo_idx 1))
    )
)
