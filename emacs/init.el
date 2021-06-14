(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["black" "#d55e00" "#009e73" "#f8ec59" "#0072b2" "#cc79a7" "#56b4e9" "white"])
 '(custom-enabled-themes '(manoj-dark))
 '(package-selected-packages
   '(abyss-theme fantom-theme electric-pair auto-complete-config auto-complete markdown-mode markdown-mode+ markdown-preview-mode magit org-bullets which-key use-package try atomic-chrome)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;(setq inhibit-startup-message t)
(global-display-line-numbers-mode)
(column-number-mode 1)

(if (not (file-exists-p "~/.emacs.d/backups"))
    (make-directory "~/.emacs.d/backups"))

(if (not (file-exists-p "~/.emacs.d/autosaves"))
    (make-directory "~/.emacs.d/autosaves"))

(setq backup-directory-alist
      `((".*" . ,"~/.emacs.d/backups")))
(setq auto-save-file-name-transforms
      `((".*" ,"~/.emacs.d/backups" t)))

(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("gnu"          . "https://elpa.gnu.org/packages/")
			 ("melpa"        . "https://melpa.org/packages/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
			 ("marmalade"    . "https://marmalade-repo.org/packages/")))

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package try
  :ensure t)

(use-package which-key
  :ensure t
  :config
  (which-key-mode)) 

;;;; org-mode stuff
(use-package org
  :ensure t)

(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

;;;; chromium interface
(use-package atomic-chrome
  :ensure t
  :config
  (atomic-chrome-start-server))

(use-package magit
  :ensure t)

;;;; auto-complete
(use-package auto-complete
  :ensure t
  :config
  (ac-config-default))

(use-package fantom-theme
  :ensure t
  :config
  (load-theme 'fantom-theme t))
