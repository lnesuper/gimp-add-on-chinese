;adapted for GIMP-2 by Eddy Verlinden

(define (script-fu-stampify img drawable paper hole diameter gap marg)
		(let*	(
			(owidth (car (gimp-image-width img)))
			(oheight (car (gimp-image-height img)))
			(nw (+ diameter (+ owidth (* 2 marg))))
			(nh (+ diameter (+ oheight (* 2 marg))))
			(img2 (car (gimp-image-new nw nh RGB)))
			(layer1 (car (gimp-layer-new img2 nw nh 0 "Layer1" 100 NORMAL)))
			(nholes 0)
			(pos 0)
			(i 0)
			(dist 0)
			)

	(gimp-image-add-layer img2 layer1 0)
	(gimp-image-set-active-layer img2 layer1)
	(gimp-palette-set-background paper)
	(gimp-drawable-fill layer1 1)
	(gimp-selection-none img2)

;; calculate number of horisontal holes
	(set! nholes (/ (+ nw gap) (+ diameter gap)))
	(set! pos 0)
	(set! i 0)

;; loop horisontally
	(while (< i nholes)
		(gimp-ellipse-select img2 pos 0 diameter diameter ADD 1 0 0)
		(set! pos (+ pos diameter gap))
		(set! i (+ i 1))
	)

;; calculate number of vertical holes
	(set! nholes (/ (+ nh gap) (+ diameter gap)))
	(set! pos 0)
	(set! i 0)

;; loop vertically
	(while (< i nholes)
		(gimp-ellipse-select img2 0 pos diameter diameter ADD 1 0 0)
		(set! pos (+ pos diameter gap))
		(set! i (+ i 1))
	)

;; and fill the holes with a colour
	(gimp-palette-set-background hole)
	(gimp-edit-fill layer1 1)
	(gimp-selection-none img2)

;; and here comes the clever part:
;; offset horis and vert holes by half the diameter
	(set! dist (* -1 (/ diameter 2)))
	(gimp-drawable-offset layer1 1 0 dist dist)

;; insert old image into a new layer in img2
	(gimp-selection-all img)
	(gimp-edit-copy drawable)
	(let 	((floating-sel (car (gimp-edit-paste layer1 0))))
		(gimp-floating-sel-anchor floating-sel)
	)
;; and return command to The Gimp
	(gimp-image-clean-all img2)
	(gimp-display-new img2)
)
)

(script-fu-register "script-fu-stampify"
	"<Image>/Filters/GimpBox/Script-Fu-中文/Decor/邮票(_Stampify)"
	"为图像添加一个像邮票的边框."
	"Claes G Lindblad <claesg@algonet.se>"
	"Claes G Lindblad <claesg@algonet.se>"
	"990330"
	"*"
	SF-IMAGE "Input Image" 0
	SF-DRAWABLE "Input Drawable" 0
	SF-COLOR "纸质颜色" '(242 242 242)
	SF-COLOR "穿孔颜色" '(153 153 153)
	SF-VALUE "穿孔直径" "10"
	SF-VALUE "穿孔间距" "5"
	SF-VALUE "临界距离艺术穿孔" "7"
)
