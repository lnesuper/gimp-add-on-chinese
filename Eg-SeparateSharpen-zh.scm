;
; Separate Sharpening, V2.4
;
; Martin Egger (martin.egger@gmx.net)
; (C) 2007, Bern, Switzerland
;
; You can find more about Separate Sharpening at
; http://thomas-stoelting.de/photoshop.html
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
; Chinese localization:lnsuper@gmail.com
(define (script-fu-Eg-SeparateSharpen InImage InLayer InRadius InAmount InThreshold InFlatten)
;
; Save history			
;
	(gimp-image-undo-group-start InImage)
;
	(let*	(
		(SharpenLightsLayer (car (gimp-layer-copy InLayer TRUE)))
		)
;
		(gimp-image-add-layer InImage SharpenLightsLayer -1)
   		(gimp-layer-set-mode SharpenLightsLayer LIGHTEN-ONLY-MODE)
   		(gimp-layer-set-opacity SharpenLightsLayer 40)
		(plug-in-unsharp-mask TRUE InImage SharpenLightsLayer InRadius InAmount InThreshold)
;
		(let*	(
			(SharpenShadowsLayer (car (gimp-layer-copy SharpenLightsLayer TRUE)))
			)
			(gimp-image-add-layer InImage SharpenShadowsLayer -1)
			(gimp-layer-set-mode SharpenShadowsLayer DARKEN-ONLY-MODE)
			(gimp-layer-set-opacity SharpenShadowsLayer 100)
		
;
; Flatten the image, if we need to
;
			(cond
				((= InFlatten TRUE)
					(begin
						(let*	(
							(SharpenLightsLayer (car (gimp-image-merge-down InImage SharpenShadowsLayer CLIP-TO-IMAGE)))
							)
							(gimp-image-merge-down InImage SharpenLightsLayer CLIP-TO-IMAGE)
						)
					)
				)
				((= InFlatten FALSE)
					(begin
						(gimp-drawable-set-name SharpenLightsLayer "Sharpened Lights")
						(gimp-drawable-set-name SharpenShadowsLayer "Sharpened Shadows")
						(gimp-image-set-active-layer InImage InLayer)
					)
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
(script-fu-register 
	"script-fu-Eg-SeparateSharpen"
	_"锐化 (分化 高亮和阴暗_Lights&Shadows)"
	"单独锐化 (高亮和阴影)"
	"Martin Egger (martin.egger@gmx.net)"
	"Martin Egger, Bern, Switzerland"
	"20.10.2007"
	"RGB* GRAY*"
	SF-IMAGE	"The Image"		0
	SF-DRAWABLE	"The Layer"		0
	SF-ADJUSTMENT	"USM 半径"		'(3.0 0.0 50.0 1 0 2 0)
	SF-ADJUSTMENT	"USM 数量"		'(1.0 0.0 5.0 0.5 0 2 0)
	SF-ADJUSTMENT	"阀值"		'(0.0 0.0 50.0 1.0 0 2 0)
	SF-TOGGLE	"合并图层"		FALSE
)
;
(script-fu-menu-register "script-fu-Eg-SeparateSharpen"
			 "<Image>/Filters/GimpBox/Eg")
;
