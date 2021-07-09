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

;; user set stuff
(setq inhibit-startup-message t)
(global-display-line-numbers-mode)
(column-number-mode 1)
(electric-pair-mode 1)
(put 'narrow-to-region 'disabled nil)

;; straight.el
(setq straight-use-package-by-default t)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; use-package

;;; make sure use-package is installed
(straight-use-package 'use-package)

;;; installed packages
(use-package ace-window
  :config
  (global-unset-key (kbd "\C-xo"))
  (global-set-key (kbd "\C-xo") 'ace-window)
  (setq aw-keys '(?j ?k ?l ?\;))
  (setq aw-background nil))

(use-package browse-kill-ring
  :config
  (global-set-key (kbd "\C-cy") 'browse-kill-ring))

(use-package zygospore
  :config
  (global-set-key (kbd "C-x 1") 'zygospore-toggle-delete-other-windows))

(use-package which-key
  :config
  (which-key-mode)) 

(use-package magit)

(use-package auto-complete
  :config
  (ac-config-default))

(use-package markdown-mode
  :commands
  (markdown-mode gfm-mode)
  :mode
  (("README\\.md\\'" . gfm-mode)
   ("\\.md\\'" . markdown-mode)
   ("\\.markdown\\'" . markdown-mode))
  :init
  (setq markdown-command "multimarkdown"))

(use-package helm
  :config
  (global-set-key (kbd "M-x") #'helm-M-x)
  (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
  (global-set-key (kbd "C-x C-f") #'helm-find-files)
  (helm-mode 1))
  
;; disable the menu-bar
(menu-bar-mode -1)

;; browse various package repos using "M-x package-list"
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/")
	     '("melpa-stable" . "https://stable.melpa.org/packages/"))
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
