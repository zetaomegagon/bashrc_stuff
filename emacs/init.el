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
(column-number-mode 1)
;(electric-pair-mode 1)
(put 'narrow-to-region 'disabled nil)
(setq create-lockfiles nil)
;; indenting
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq indent-line-function 'insert-tab)

;; common lisp devel
(setq show-paren-delay 0)
(show-paren-mode)
  
;; auto saves and backups
(if (not (file-directory-p "/home/ebeale/gits/bashrc_stuff/emacs/backups/"))
    (make-directory "/home/ebeale/gits/bashrc_stuff/emacs/backups/" t))

(if (not (file-directory-p "/home/ebeale/gits/bashrc_stuff/emacs/autosaves/"))
    (make-directory "/home/ebeale/gits/bashrc_stuff/emacs/autosaves/" t))

(setq auto-save-interval 20)

(setq backup-by-copying t
      backup-directory-alist '(("." . "/home/ebeale/gits/bashrc_stuff/emacs/backups/"))
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)
(setq auto-save-file-name-transforms
      `((".*" "/home/ebeale/gits/bashrc_stuff/emacs/autosaves/")))

;;;; better unique naming of file buffers with the same name
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)
(setq uniquify-separator "|")
(setq uniquify-after-kill-buffer-p t)
(setq uniquify-ignore-buffers-re "^\\*")

;;;; remember recently opened files
(recentf-mode t)
(global-set-key (kbd "<f7>") 'recentf-open-files)
(save-place-local-mode)
(setq-default fill-column 80)

;;;; line number mode
(global-display-line-numbers-mode)
(set-face-foreground 'line-number "firebrick")
(set-face-foreground 'line-number-current-line "DarkOrange2")

(defun display-line-numbers-equalize ()
  "Equalize the width.  For more information, see: https://emacs.stackexchange.com/a/55166/8887."
  (setq display-line-numbers-width
        (length (number-to-string (line-number-at-pos (point-max))))))
(add-hook 'find-file-hook 'display-line-numbers-equalize)

;;;; straight.el
;;
;; also see .emacs.d/early-init.el for preconfig
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

;; update melpa
(straight-pull-package "melpa")

;;;; use-package

;;;; make sure use-package is installed
(straight-use-package 'use-package)

;;;; installed packages

;; common lisp devel
(use-package slime
  :init
  (defun my-slime-keybindings ()
  "For use in slime-mode-hook and slime-repl-mode-hook."
  (local-set-key (kbd "C-l") 'slime-repl-clear-buffer))
  
  (add-hook 'slime-mode-hook      #'my-slime-keybindings)
  (add-hook 'slime-repl-mode-hook #'my-slime-keybindings)
  :config
  (add-to-list 'exec-path "/usr/local/bin")
  (setq inferior-lisp-program "sbcl"))

(use-package paredit
  :init
  (add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook 'enable-paredit-mode)
  (add-hook 'ielm-mode-hook 'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook 'enable-paredit-mode)
  (add-hook 'lisp-mode-hook 'enable-paredit-mode)
  (add-hook 'slime-repl-mode-hook 'enable-paredit-mode)
  :config
  (defun override-slime-del-key ()
    (define-key slime-repl-mode-map
      (read-kbd-macro paredit-backward-delete-key) nil))
  (add-hook 'slime-repl-mode-hook 'override-slime-del-key))

(use-package rainbow-delimiters
  :init
  (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'ielm-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'lisp-interaction-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'lisp-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'slime-repl-mode-hook 'rainbow-delimiters-mode)
  :config
  (require 'rainbow-delimiters)
  (set-face-foreground 'rainbow-delimiters-depth-1-face "#c66")   ; red
  (set-face-foreground 'rainbow-delimiters-depth-2-face "#6c6")   ; green
  (set-face-foreground 'rainbow-delimiters-depth-3-face "#69f")   ; blue
  (set-face-foreground 'rainbow-delimiters-depth-4-face "#cc6")   ; yellow
  (set-face-foreground 'rainbow-delimiters-depth-5-face "#6cc")   ; cyan
  (set-face-foreground 'rainbow-delimiters-depth-6-face "#c6c")   ; magenta
  (set-face-foreground 'rainbow-delimiters-depth-7-face "#ccc")   ; light gray
  (set-face-foreground 'rainbow-delimiters-depth-8-face "#999")   ; medium gray
  (set-face-foreground 'rainbow-delimiters-depth-9-face "#666"))  ; dark gray

(use-package systemd)

(use-package browse-kill-ring
  :config
  (global-set-key (kbd "C-c y") 'browse-kill-ring))

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

(use-package web-server)

;; window / buffer management
(use-package ace-window
  :config
  (global-unset-key (kbd "C-x o"))
  (global-set-key (kbd "C-x o") 'ace-window)
  (setq aw-keys '(?j ?k ?l ?\;))
  (setq aw-background nil))

(use-package zygospore
  :config
  (global-set-key (kbd "C-x 1") 'zygospore-toggle-delete-other-windows))

(use-package buffer-move
  :init
  (global-unset-key (kbd "C-c j"))
  (global-unset-key (kbd "C-c k"))
  (global-unset-key (kbd "C-c l"))
  (global-unset-key (kbd "C-c ;"))
  :config
  (global-set-key (kbd "C-c j") 'buf-move-left)
  (global-set-key (kbd "C-c k") 'buf-move-up)
  (global-set-key (kbd "C-c l") 'buf-move-down)
  (global-set-key (kbd "C-c ;") 'buf-move-right)
  (setq buffer-move-stay-after-swap t))

;; delete windows
(global-set-key (kbd "C-c <delete>") 'ace-delete-window)
(global-set-key (kbd "C-x <delete>") 'ace-delete-other-windows)

(defun toggle-window-split ()
  "Toggle between horizontal / vertical window split for two windows.
This needs to be added to a repo and installed via straight / use-package."
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
					                               (car next-win-edges))
				                             (<= (cadr this-win-edges)
					                               (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
		                 (car (window-edges (next-window))))
		              'split-window-horizontally
		            'split-window-vertically)))
	      (delete-other-windows)
	      (let ((first-win (selected-window)))
	        (funcall splitter)
	        (if this-win-2nd (other-window 1))
	        (set-window-buffer (selected-window) this-win-buffer)
	        (set-window-buffer (next-window) next-win-buffer)
	        (select-window first-win)
	        (if this-win-2nd (other-window 1))))))

(global-set-key (kbd "C-c i") 'toggle-window-split)


;; syntax checking, linting, highlighting
(use-package emmet-mode
  :config
  (add-hook 'html-mode-hook 'emmet-mode)
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook 'emmet-mode)
  (add-hook 'emmet-mode-hook
	          (lambda () (setq emmet-indent-after-insert nil)))
  (add-hook 'emmet-mode-hook
	          (lambda () (setq emmet-indentation 2)))
  (setq emmet-expand-jsx-className? t)
  (setq emmet-self-closing-tag-style " /")
  (setq emmet-move-cursor-between-quotes t)
  (global-set-key (kbd "C-c '") 'emmet-expand-line))

(use-package highlight-indent-guides
  :config
  (add-hook 'prog-mode-hook 'highlight-indent-guides-mode))

(use-package yasnippet
  :config
  (yas-global-mode 1))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c [")
  :hook
  ((prog-mode-hook . lsp)
   (lsp-mode . lsp-enable-which-key-integration))
  :commands
  lsp)

(use-package lsp-ui
  :commands lsp-ui-mode)

(use-package helm-lsp
  :commands helm-lsp-workspace-symbol)

(use-package which-key
  :config
  (which-key-mode))

(use-package flycheck
  :init
  (global-flycheck-mode)
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

(use-package company
  :config
  (add-hook 'after-init-hook 'global-company-mode))

(use-package lsp-treemacs
  :commands
  (lsp-treemacs-errors-list)
  :config
  (lsp-treemacs-sync-mode 1))

(use-package helm-lsp
  :config
  (define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol))

(use-package vterm
  :config
  (define-key vterm-mode-map (kbd "<C-backspace>")
    (lambda () (interactive) (vterm-send-key (kbd "C-w"))))
  (defun vterm-counsel-yank-pop-action (orig-fun &rest args)
    "https://github.com/zetaomegagon/emacs-libvterm#frequently-asked-questions-and-problems."
    (if (equal major-mode 'vterm-mode)
	      (let ((inhibit-read-only t)
              (yank-undo-function (lambda (_start _end) (vterm-undo))))
          (cl-letf (((symbol-function 'insert-for-yank)
		                 (lambda (str) (vterm-send-string str t))))
            (apply orig-fun args)))
      (apply orig-fun args)))
  (advice-add 'counsel-yank-pop-action :around #'vterm-counsel-yank-pop-action))

(use-package multi-vterm
  :config
  (global-set-key (kbd "C-c t") #'multi-vterm))

(use-package edit-server
  :commands edit-server-start
  :init (if after-init-time
              (edit-server-start)
            (add-hook 'after-init-hook
                      #'(lambda() (edit-server-start))))
  :config (setq edit-server-new-frame-alist
                '((name . "Edit with Emacs FRAME")
                  (top . 200)
                  (left . 200)
                  (width . 80)
                  (height . 25)
                  (minibuffer . t)
                  (menu-bar-lines . t)
                  (window-system . x))))

(use-package tldr)

;; disable the menu-bar in cli and toolbar in gui.
;; disable scrollbar in both
(menu-bar-mode -1)
(when (display-graphic-p)
  (tool-bar-mode 0)
  (scroll-bar-mode 0))
;; browse various package repos using "M-x package-list"
(require 'package)
(add-to-list 'package-archives
	           '("melpa" . "https://melpa.org/packages/")
	           '("melpa-stable" . "https://stable.melpa.org/packages/"))
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(provide 'init)
;;; init.el ends here
