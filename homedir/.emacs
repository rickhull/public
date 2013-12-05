(add-hook 'before-save-hook 'delete-trailing-whitespace)
;; use setq-default so modes that want tabs can enable this
(setq-default indent-tabs-mode nil)

;; sh-mode customizations
;;(setq-default sh-basic-offset 2)
;;(setq-default sh-indentation 2)

(defun rick-sh-mode ()
  "2 space indent"
  (interactive)
  (setq sh-basic-offset 2
        sh-indentation 2))
(add-hook 'sh-mode-hook 'rick-sh-mode)

;;(defun emacs-global-indent ()
;;   "Indent the entire buffer."
;;   (indent-region (point-min) (point-max) nil)
;;   (save-buffer)
;;)

(defun rick-sh-mode-indent ()
  (setq sh-basic-offset 2
        sh-indentation 2)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max))
  (save-buffer)
)
