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
   '(ace-window browse-kill-ring atomic-chrome zygospore abyss-theme electric-pair auto-complete-config auto-complete markdown-mode markdown-mode+ markdown-preview-mode magit org-bullets which-key use-package try)))

;;;; user set stuff
(setq inhibit-startup-message t)
(global-display-line-numbers-mode)
(column-number-mode 1)
(global-set-key (kbd "C-x 1") 'zygospore-toggle-delete-other-windows)
(global-set-key (kbd "\C-cy") 'browse-kill-ring)

;; movemet key rebinds
;; (global-set-key (kbd "C-k") 'next-line)
;; (global-set-key (kbd "C-j") 'previous-line)
;; (global-set-key (kbd "C-l") 'forward-char)
;; (global-set-key (kbd "C-h") 'backward-char)
;; (global-set-key (kbd "M-h") 'backward-word)
;; (global-set-key (kbd "M-l") 'forward-word)

;; ace-window
(global-set-key (kbd "\C-co") 'ace-window)
(setq aw-keys '(?j ?k ?l ?\;))
(setq aw-background nil)

;; backup and autosave custom paths
(if (not (file-exists-p "~/.emacs.d/backups"))
    (make-directory "~/.emacs.d/backups"))
(if (not (file-exists-p "~/.emacs.d/autosaves"))
    (make-directory "~/.emacs.d/autosaves"))

(setq backup-directory-alist
      `((".*" . ,"~/.emacs.d/backups")))
(setq auto-save-file-name-transforms
      `((".*" ,"~/.emacs.d/backups" t)))

;; package management
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

; org-mode stuff
(use-package org
  :ensure t)

(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

; chromium interface
(use-package atomic-chrome
  :ensure t
  :config
  (atomic-chrome-start-server))

(use-package magit
  :ensure t)

; auto-complete
(use-package auto-complete
  :ensure t
  :config
  (ac-config-default))

;; disable the menu-bar
(menu-bar-mode -1)
