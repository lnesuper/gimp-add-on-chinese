;
; Add film grain, 2.4
;
; Martin Egger (martin.egger@gmx.net)
; (C) 2006, Bern, Switzerland
;
; You can find more about adding realistic film grain to BW images at
; http://www.outbackphoto.com/workflow/wf_95/essay.html
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
; Chinese localization:lnesuper@gmai.com
(define (script-fu-Eg-AddFilmGrain InImage InLayer InFlatten InMidCol InMidRad InShadCol InShadRad InMid1Blur InMid2Blur InShad1Blur InShad2Blur InMid1Sharp InShad1Sharp)
;
; Save history			
;
	(gimp-image-undo-group-start InImage)
	(if (= (car (gimp-drawable-is-rgb InLayer)) FALSE ) (gimp-image-convert-rgb InImage))
;
	(let*	(
		(Midtone1Layer (car (gimp-layer-new InImage (car (gimp-image-width InImage)) (car (gimp-image-height InImage))  RGBA-IMAGE "Noise 1 - midtones" 20 NORMAL-MODE)))
		(Midtone2Layer (car (gimp-layer-new InImage (car (gimp-image-width InImage)) (car (gimp-image-height InImage))  RGBA-IMAGE "Noise 2 - midtones" 20 NORMAL-MODE)))
		(ShadHL1Layer (car (gimp-layer-new InImage (car (gimp-image-width InImage)) (car (gimp-image-height InImage))  RGBA-IMAGE "Noise 1 - shadows" 85 NORMAL-MODE)))
		(ShadHL2Layer (car (gimp-layer-new InImage (car (gimp-image-width InImage)) (car (gimp-image-height InImage))  RGBA-IMAGE "Noise 2 - shadows" 40 NORMAL-MODE)))
		)
		(gimp-drawable-fill Midtone1Layer TRANSPARENT-FILL)
		(gimp-drawable-fill Midtone2Layer TRANSPARENT-FILL)
		(gimp-drawable-fill ShadHL1Layer TRANSPARENT-FILL)
		(gimp-drawable-fill ShadHL2Layer TRANSPARENT-FILL)
		(gimp-image-add-layer InImage Midtone1Layer -1)
		(gimp-image-add-layer InImage Midtone2Layer -1)
		(gimp-image-add-layer InImage ShadHL1Layer -1)
		(gimp-image-add-layer InImage ShadHL2Layer -1)
		(gimp-selection-none InImage)
;
		(gimp-by-color-select InLayer InMidCol InMidRad CHANNEL-OP-REPLACE TRUE TRUE 3 TRUE)
		(plug-in-rgb-noise TRUE InImage Midtone1Layer FALSE FALSE 1 1 1 1)
		(plug-in-rgb-noise TRUE InImage Midtone2Layer FALSE FALSE 1 1 1 1)
;
		(gimp-by-color-select InLayer InShadCol InShadRad CHANNEL-OP-REPLACE TRUE TRUE 3 TRUE)
		(plug-in-rgb-noise TRUE InImage ShadHL1Layer FALSE FALSE 1 1 1 1)
		(plug-in-rgb-noise TRUE InImage ShadHL2Layer FALSE FALSE 1 1 1 1)
		(gimp-selection-none InImage)
;
		(plug-in-gauss TRUE InImage Midtone1Layer InMid1Blur InMid1Blur TRUE)
		(plug-in-gauss TRUE InImage Midtone2Layer InMid2Blur InMid2Blur TRUE)
		(plug-in-gauss TRUE InImage ShadHL1Layer InShad1Blur InShad1Blur TRUE)
		(plug-in-gauss TRUE InImage ShadHL2Layer InShad2Blur InShad2Blur TRUE)
;
		(plug-in-unsharp-mask TRUE InImage Midtone1Layer InMid1Sharp 0 0)
		(plug-in-unsharp-mask TRUE InImage ShadHL1Layer InShad1Sharp 0 0)
;		
; Flatten the image, if we need to
;
		(cond
			((= InFlatten TRUE) 
				(begin
					(gimp-image-merge-down InImage Midtone1Layer CLIP-TO-IMAGE)
					(gimp-image-merge-down InImage Midtone2Layer CLIP-TO-IMAGE)
					(gimp-image-merge-down InImage ShadHL1Layer CLIP-TO-IMAGE)
					(gimp-image-merge-down InImage ShadHL2Layer CLIP-TO-IMAGE)
				)
			)
			((= InFlatten FALSE) 
				(begin
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
(script-fu-register 
	"script-fu-Eg-AddFilmGrain"
	_"添加胶片颗粒(影片效果)"
	"为BW图片添加胶片颗粒效果.(黑白图片效果明显)"
	"Martin Egger (martin.egger@gmx.net)"
	"Martin Egger, Bern, Switzerland"
	"18.11.2007"
	"RGB* GRAY*"
	SF-IMAGE	"The Image"		0
	SF-DRAWABLE	"The Layer"		0
	SF-TOGGLE	"合并图层"	FALSE
	SF-COLOR	"中间色调颜色"	'(140 140 140)
	SF-ADJUSTMENT	"中间色调选择范围"	'(50.0 1.0 100.0 1.0 0 2 0)
	SF-COLOR	"阴影(颗粒)颜色"	'(35 35 35)
	SF-ADJUSTMENT	"阴影选择范围"	'(35.0 1.0 100.0 1.0 0 2 0)
	SF-ADJUSTMENT	"中间色调 1 柔化半径"	'(2.5 0.5 10.0 0.5 0 2 0)
	SF-ADJUSTMENT	"中间色调 2 柔化半径"	'(2.5 0.5 10.0 0.5 0 2 0)
	SF-ADJUSTMENT	"阴影 1 柔化半径"	'(20 0.5 50.0 0.5 0 2 0)
	SF-ADJUSTMENT	"阴影 2 柔化半径"	'(2.5 0.5 10.0 0.5 0 2 0)
	SF-ADJUSTMENT	"中间色调 1 锐化半径"	'(80 0.0 150.0 5.0 0 2 0)
	SF-ADJUSTMENT	"阴影 1 锐化半径"	'(80 0.0 150.0 5.0 0 2 0)
)
;
(script-fu-menu-register "script-fu-Eg-AddFilmGrain"
			 "<Image>/Filters/GimpBox/Eg")
;
