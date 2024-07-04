(require 'package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3") ; wtf debian

(package-initialize)

(require 'use-package)

;; additional places to load things
(add-to-list 'load-path "~/.emacs.d/additions/")

;; terminal set up

(setq in-terminal (not window-system))

;; TERM is "dumb" by default. We set a variable so we can access the
;; "original" one.
(setq ambient-term-variable (getenv-internal "TERM" initial-environment))

(when in-terminal
  (menu-bar-mode 0)
  (setq scroll-step 1)
  (setq scroll-conservatively 10000)
  (setq auto-window-vscroll nil)
  (setq ispell-program-name "/usr/local/bin/ispell")
  (setq flyspell-issue-message-flag nil))

;; read in PATH from .bashrc if we aren't in the terminal
;(unless in-terminal
;  (setenv "PATH"
;          (shell-command-to-string "source $HOME/.bashrc && printf $PATH")))

;; do some initialization for the vt420.
;;
;; Emacs comes with a better way to do this, in section 40.1.3
;; "Terminal-Specific Initialization", but I haven't figured it out
;; yet.

;; environment setup

;(setenv "CC" "/usr/bin/gcc")

;(setenv "PATH" (concat (getenv "PATH") ":/usr/bin:/Library/TeX/texbin/"))
;(setq preview-gs-command "/usr/local/bin/gs")

;; font & theme
(unless in-terminal
  (set-face-attribute 'default nil :font "DejaVu Sans Mono 12")

  (add-to-list 'load-path "~/.emacs.d/additions/color-theme-6.6.0/")
  (add-to-list 'load-path "~/.emacs.d/additions/color-theme-6.6.0/themes/")
  (require 'color-theme)
  (setq color-theme-load-all-themes nil)
  (require 'color-theme-tangotango)
  (setq color-theme-choices '(color-theme-tangotango color-theme-tangotango))
  (color-theme-tangotango)
  
  (set-cursor-color "#ffff00")            ; yellow
  )


;; backups

(setq backups-directory "~/.emacs.d/backups/")

(setq backup-directory-alist
      `((".*" . ,backups-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,backups-directory t)))

(tool-bar-mode -1)
(blink-cursor-mode -1)
(icomplete-mode +1)
(show-paren-mode +1)

(windmove-default-keybindings)

(setq-default indent-tabs-mode nil)

(setq column-number-mode t
      indicate-empty-lines t
      inhibit-startup-screen t)

(setq lpr-command "gtklp")
(setq ps-lpr-command "gtklp")

(require 'line-comment-banner)

(global-set-key (kbd "C-;") 'line-comment-banner)

(unless in-terminal
  (set-language-environment "UTF-8")
  (setenv "LANG" "en_US.UTF-8")
  (setenv "LC_TYPE" "en_US.UTF-8"))

;(setenv "SBCL_HOME" "~/Slash/lib/sbcl")
;(setq inferior-lisp-program "~/Slash/bin/sbcl --dynamic-space-size=13312")

;;; align-let

(require 'align-let)

;;; nasm

(autoload 'nasm-mode "~/.emacs.d/additions/nasm-mode.el" "" t)
(add-to-list 'auto-mode-alist '("\\.\\(asm\\|s\\)$" . nasm-mode))

;;; protobuf

(require 'protobuf-mode)

;;; IVY

(customize-set-variable 'ivy-dynamic-exhibit-delay-ms 200 "Customized with use-package ivy")
(customize-set-variable 'ivy-height 14 "Customized with use-package ivy")
(customize-set-variable 'ivy-initial-inputs-alist nil "Customized with use-package ivy")
(customize-set-variable 'ivy-magic-tilde nil "Customized with use-package ivy")
(customize-set-variable 'ivy-re-builders-alist
                        '((t . ivy--regex-ignore-order))
                        "Customized with use-package ivy")
(customize-set-variable 'ivy-use-virtual-buffers t "Customized with use-package ivy")
(customize-set-variable 'ivy-wrap t "Customized with use-package ivy")

(ivy-mode 1)
(ivy-set-occur 'ivy-switch-buffer 'ivy-switch-buffer-occur)
(setq ivy-use-virtual-buffers t
      ivy-count-format "%d/%d ")

;;; markdown
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (progn
          (setq markdown-command "multimarkdown")
          (setq markdown-enable-math t)))


;;; paredit

(autoload 'paredit-mode "paredit"
  "Minor mode for editing s-expressions." t)

(add-hook 'paredit-mode-hook (lambda ()
                               nil))

(add-hook 'emacs-lisp-mode-hook (lambda () (paredit-mode +1)))

(add-hook 'scheme-mode-hook (lambda ()
                              (interactive)
                              (align-let-keybinding)
                              (paredit-mode +1)))

 (defvar electrify-return-match
    "[\]}\)\"]"
    "If this regexp matches the text after the cursor, do an \"electric\"
  return.")
  (defun electrify-return-if-match (arg)
    "If the text after the cursor matches `electrify-return-match' then
  open and indent an empty line between the cursor and the text.  Move the
  cursor to the new line."
    (interactive "P")
    (let ((case-fold-search nil))
      (if (looking-at electrify-return-match)
	  (save-excursion (newline-and-indent)))
      (newline arg)
      (indent-according-to-mode)))
;; Using local-set-key in a mode-hook is a better idea.
(global-set-key (kbd "RET") 'electrify-return-if-match)

;;; SLIME

(load (expand-file-name "~/quicklisp/slime-helper.el"))

(slime-setup '(slime-fancy
               slime-highlight-edits
               slime-autodoc
               slime-indentation
               slime-company))

(setq slime-net-coding-system 'utf-8-unix
      slime-truncate-lines nil
      slime-multiprocessing t
      slime-complete-symbol-function 'slime-fuzzy-complete-symbol)


(add-hook 'lisp-mode-hook (lambda ()
                            (flyspell-prog-mode)
                            (align-let-keybinding)
                            (paredit-mode +1)
                            (slime-highlight-edits-mode)))

(setq lisp-lambda-list-keyword-parameter-alignment t
      lisp-lambda-list-keyword-alignment t
      lisp-align-keywords-in-calls t)

(setq slime-lisp-implementations
      '((sbcl ("~/Slash/bin/sbcl" "--dynamic-space-size" "13312") :coding-system utf-8-unix)
        (ccl ("~/Slash/bin/ccl64") :coding-system utf-8-unix)
        (ccl32 ("~/Source/Foreign/ccl/dx86cl") :coding-system utf-8-unix)
        (ecl ("~/Slash/bin/ecl") :coding-system utf-8-unix)
        (acl ("~/Desktop/allegro/acl10.1-smp.64/alisp") :coding-system utf-8-unix)))

(defun my/slime-read-ql-system (prompt &optional system-name)
  (let ((completion-ignore-case t))
    (completing-read prompt (slime-bogus-completion-alist
                                  (slime-eval
                                   `(cl:append (ql:list-local-systems)
                                               (cl:mapcar (cl:symbol-function 'ql-dist:name)
                                                          (ql:system-list)))))
                     nil t system-name)))

(defun my/slime-repl-quickload (package)
  (interactive (list (let* ((p (slime-current-package))
                            (p (and p (slime-pretty-package-name p)))
                            (p (and (not (equal p (slime-lisp-package))) p)))
                       (my/slime-read-ql-system "System: " p))))
  (slime-repl-send-string (format "(ql:quickload %S)" package)))

(defslime-repl-shortcut nil
    ("quicklisp quickload" "ql")
    (:handler 'my/slime-repl-quickload)
    (:one-liner "Quickload a system"))

(put 'make-instance 'common-lisp-indent-function 1)

;;; CUSTOM STUFF
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(confirm-kill-emacs (quote y-or-n-p))
 '(package-selected-packages
   (quote
    (markdown-mode ivy slime-company beacon auctex)))
 '(preview-gs-options
   (quote
    ("-q" "-dNOPAUSE" "-DNOPLATFONTS" "-dPrinted" "-dTextAlphaBits=4" "-dGraphicsAlphaBits=4" "-dDELAYSAFER"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-tooltip ((t (:foreground "black" :inverse-video t))))
 '(company-tooltip-common ((t (:foreground "red"))))
 '(error ((t (:weight bold))))
 '(font-latex-script-char-face ((t (:foreground "LightPink1"))))
 '(font-lock-comment-face ((t nil)))
 '(font-lock-constant-face ((t (:weight bold))))
 '(font-lock-function-name-face ((t (:weight bold))))
 '(font-lock-type-face ((t (:weight bold))))
 '(mode-line ((t nil)))
 '(show-paren-match ((t (:inverse-video t))))
 '(slime-highlight-edits-face ((t (:background "gray28"))))
 '(widget-field ((t (:background "yellow3" :foreground "black" :underline t)))))
