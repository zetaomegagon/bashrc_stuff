;;; zygospore-autoloads.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads nil "zygospore" "zygospore.el" (0 0 0 0))
;;; Generated autoloads from zygospore.el

(autoload 'zygospore-toggle-delete-other-windows "zygospore" "\
Main zygospore func.
If the current frame has several windows, it will act as `delete-other-windows'.
If the current frame has one window,
	and it is the one that was last full-frame'd,
	and the buffer remained the same,
it will restore the window configuration to prior to full-framing." t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "zygospore" '("zygospore-")))

;;;***

(provide 'zygospore-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; zygospore-autoloads.el ends here
