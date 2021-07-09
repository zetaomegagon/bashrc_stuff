;;; ack-menu-autoloads.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads nil "ack-menu" "ack-menu.el" (0 0 0 0))
;;; Generated autoloads from ack-menu.el

(autoload 'ack-find-same-file "ack-menu" "\
Prompt to find a file found by ack in DIRECTORY.

\(fn &optional DIRECTORY)" t nil)

(autoload 'ack-find-file "ack-menu" "\
Prompt to find a file found by ack in DIRECTORY.

\(fn &optional DIRECTORY)" t nil)

(autoload 'ack-menu "ack-menu" "\
Invoke the ack menu. When finished, ack will be run with the
specified options." t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "ack-menu" '("ack-")))

;;;***

(provide 'ack-menu-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; ack-menu-autoloads.el ends here
