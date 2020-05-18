;
; Color Vibrance, V2.4
;
; Martin Egger (martin.egger@gmx.net)
; (C) 2007, Bern, Switzerland
;
; This script was tested with Gimp 2.4
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 3 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, see <http://www.gnu.org/licenses>.
;
; Define the function
;
; Chinese localization:lnesuper@gmail.com
(define (script-fu-Eg-ColorVibrance InImage InLayer InIntensity InOpacity InRG InSatMask InFlatten)
;	
; Save history			
;
	(gimp-image-undo-group-start InImage)
;
	(let*	(
		(factor (* InIntensity .025))
		(plusr (+ 1 (* 2 factor)))
		(minusr (* -1 factor))
		(plusg (+ 1 (* 2 factor)))
		(minusg (* -1 factor))
		(plusb (+ 1 (* 2 factor)))
		(minusb (* -1 factor))
		(ColorLayer (car (gimp-layer-copy InLayer TRUE)))
		)
		(gimp-image-add-layer InImage ColorLayer -1)
		(gimp-layer-set-opacity ColorLayer InOpacity)
;
; Prefer Red/Green saturation, if we need to
;
		(cond
			((= InRG TRUE)
				(begin
					(set! plusb (+ 1 factor))
					(set! minusb (* -0.5 factor))
				)
			)
		)
;
; Apply new color mappings to image
;
		(plug-in-colors-channel-mixer TRUE InImage ColorLayer FALSE plusr minusr minusr minusg plusg minusg minusb minusb plusb)
;
; Add inverse saturation mask, if we need to
;
		(cond
			((= InSatMask TRUE)
				(begin
					(let*	(
						(SatMask (car (gimp-layer-create-mask ColorLayer ADD-WHITE-MASK)))
						(HSVImage (car (plug-in-decompose TRUE InImage InLayer "HSV" TRUE)))
		   				(HSVLayer (cadr (gimp-image-get-layers HSVImage)))
						)
						(gimp-layer-add-mask ColorLayer SatMask)
						(gimp-selection-all HSVImage)
						(gimp-edit-copy (aref HSVLayer 1))
						(gimp-floating-sel-anchor (car (gimp-edit-paste SatMask TRUE)))
						(gimp-invert SatMask)
						(gimp-layer-set-edit-mask ColorLayer FALSE)
						(gimp-image-delete HSVImage)
					)
				)
			)
		)
;
; Flatten the image, if we need to
;
		(cond
			((= InFlatten TRUE) (gimp-image-merge-down InImage ColorLayer CLIP-TO-IMAGE))
			((= InFlatten FALSE) 
				(begin
					(gimp-drawable-set-name ColorLayer "Vibrance")
					(gimp-image-set-active-layer InImage InLayer)
				)
			)
		)
	)
;
; Finish work
;
	(gimp-image-undo-group-end InImage)
	(gimp-displays-flush)
;
)
;
; Register the function with the GIMP
;
(script-fu-register
	"script-fu-Eg-ColorVibrance"
	_"颜色润亮 (_Color Vibrance)"
	"侵润或者稀释图像颜色(振动/响亮) //Saturate or desaturate color images (则会)"
	"Martin Egger (martin.egger@gmx.net)"
	"Martin Egger, Bern, Switzerland"
	"20.10.2007"
	"RGB*"
	SF-IMAGE	"The Image"	0
	SF-DRAWABLE	"The Layer"	0
	SF-ADJUSTMENT	"强度"	'(1 -20 20 0.5 0 2 0)
	SF-ADJUSTMENT	"着色层不透明度" '(70.0 1.0 100.0 1.0 0 2 0)
	SF-TOGGLE	"倾向于 红色/绿色 侵润"	FALSE
	SF-TOGGLE	"应用逆饱和蒙板"	TRUE
	SF-TOGGLE	"图层合并"	FALSE
)
;
(script-fu-menu-register "script-fu-Eg-ColorVibrance"
			 "<Image>/Filters/GimpBox/Eg")
;
