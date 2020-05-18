; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
; 
; A set of layer effects script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/08/06
;     - Initial relase
; version 0.2  by Iccii 2001/08/07
;     - Divide each function into depending function and common function
; version 0.3  by Iccii 2001/08/09
;     - Add the Stain script
; version 0.4  by Iccii 2001/08/10
;     - Add the Color/Gradient/Pattern Overlay scripts
; version 0.5  by Iccii 2001/08/14
;     - Add the Border script (not better)
; version 0.5a by Iccii 2003/05/29
;     - Add "Antialias" option in Add Border script
;
; --------------------------------------------------------------------
; version 0.6
; corrections made by Michael Hoelzen <MichaelHoelzen@aol.com>
; begin
; 2005-11-13	error corrected in gradient overlay script:
;				"do adaptive supersampling" and "supersampling threshold"
;				weren't set
; 2005-11-13	replaced deprecated procedures (hopefully all of them)
; 2005-11-13	commented the replacements in sourcetext
;				where the number of call-parameters had changed 
; corrections made by Michael Hoelzen
; end
;-------------------------------------------------------------------------------------
; changes made by eddy_verlinden@hotmail.com 
; Version 0.6a
; - added the possibility to automatically expand the (text)layers to the size of the canvas
;   as it was usually necessary to do this in advance. 
;   These lines all contain the word "expand"; also there is extra SF-TOGGLE at the end.
; - Changed de way the border was improved Add Border --> more possibilities + improved antialiasing
; - saving of the selection in a channel and restoring it afterwards (problems were caused by these selections)
; 
;Version 0.6b
; - added hints in the dialogs for the translating of tutorials on the web (size,distance,choke,spread,...)
; - for the same reason the angle had to start from the x-axis, and was the emboss-effect downsized
; - added linked state to the layers, so they can be moved together (doesn't work on masks however, so I made them uneditable)
; --------------------------------------------------------------------
;Version 2.0
;Identical to version 06b but now declared stable
;---------------------------------------------------------------------
; 
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.  
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;
; Chinese localization: lnesuper@gmail.com
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Layer Effect common function              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (layer_effects_common1
                   img           ; 
                   layer         ; 
                   color         ; 
                   angle         ; 
                   offset-radius ; 
                   effect-radius ; 
                   blur-radius   ; 
                   opacity       ; 
                   layer-mode    ; 
                   layer-name    ; 
                   color-side    ; (Outer(0) Inner(1) Inner-Inverse(2))
		   link?
        )

  (let* (
         (width (car (gimp-drawable-width layer)))
         (height (car (gimp-drawable-height layer)))
; EV version 0.6b: changed angle 0° from the top to the right
         (radians (/ (* 2 *pi* (- angle 90)) 360))
         (x-offset (* offset-radius (sin radians)))
         (y-offset (* offset-radius (cos radians)))
         (target-layer (car (gimp-layer-copy layer TRUE)))
         (effect-layer (car (gimp-layer-new img width height RGBA-IMAGE
                                  layer-name opacity layer-mode)))
         (effect-mask (car (gimp-layer-create-mask effect-layer WHITE-MASK)))
	 (effect-mask2)
        )

	;; 
    (gimp-image-add-layer img effect-layer -1)
;replaced 2005-11-13
;    (gimp-image-add-layer-mask img effect-layer effect-mask)
    (gimp-layer-add-mask effect-layer effect-mask)
    (if (= color-side 0)
        (gimp-invert effect-mask))
    (if (< 0 (car (gimp-layer-get-mask target-layer)))
;replaced 2005-11-13
;        (gimp-image-remove-layer-mask img target-layer APPLY))
        (gimp-layer-remove-mask target-layer APPLY))

	;; 
    (gimp-context-set-background color)
    (gimp-drawable-fill effect-layer BG-IMAGE-FILL)
    (gimp-selection-layer-alpha target-layer)
    (if (= color-side 0)
        (gimp-selection-grow img effect-radius)
        (begin
          (gimp-selection-invert img)
          (gimp-selection-grow img effect-radius)
          (gimp-selection-invert img) ))
    (if (= color-side 0)
        (gimp-context-set-background '(255 255 255))
        (gimp-context-set-background '(0 0 0)))
    (gimp-edit-fill effect-mask BG-IMAGE-FILL)
    (gimp-selection-none img)

	;; 
    (gimp-context-set-background '(0 0 0))
    (if (< 0 offset-radius)
        (gimp-drawable-offset effect-mask FALSE OFFSET-BACKGROUND x-offset y-offset))
    (if (< 0 blur-radius)
        (plug-in-gauss-iir2 1 img effect-mask blur-radius blur-radius))
    (if (= color-side 2)
        (gimp-invert effect-mask))

	;; 
;replaced 2005-11-13
;    (gimp-image-remove-layer-mask img effect-layer APPLY)
    (gimp-layer-remove-mask effect-layer APPLY)
    (set! effect-mask2 (car (gimp-layer-create-mask effect-layer BLACK-MASK)))
;replaced 2005-11-13
;	(gimp-image-add-layer-mask img effect-layer effect-mask2)
	(gimp-layer-add-mask effect-layer effect-mask2)
    (if (= color-side 0)
        (gimp-invert effect-mask2))
    (gimp-selection-layer-alpha target-layer)
    (if (= color-side 0)
        (gimp-context-set-background '(0 0 0))
        (gimp-context-set-background '(255 255 255)))
    (gimp-edit-fill effect-mask2 BG-IMAGE-FILL)
    (gimp-layer-set-edit-mask effect-layer FALSE) ; added in version 0.6b beacause mask can't be linked, therefore it's put inactive.
    (gimp-selection-none img)

	;; 
    (if (= color-side 0)
        (gimp-image-lower-layer img effect-layer))
    (gimp-image-set-active-layer img layer)
    (list effect-layer)
    (if (= link? TRUE)(gimp-drawable-set-linked effect-layer TRUE)) ; added in version 0.6b
  )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Drop Shadow Script                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (script_fu_layer_effects_drop_shadow
                   img           ; 
                   layer         ; 
                   color         ; 
                   angle         ; 
                   offset-radius ; 
                   radius        ; 
                   blur-radius   ; 
                   opacity       ; 
                   layer-mode    ; 
		   link?	 ;
                   expand?       ; 
         )

  (let* (
         (old-bg (car (gimp-context-get-background)))
         (layer-mode (cond ((= layer-mode 0) 3)
                           ((= layer-mode 2) 0)
                           (layer-mode)))
	 (currentselection)
        )
    (gimp-image-undo-group-start img)
    (set! currentselection (car(gimp-selection-save img))) ; these two lines are new in version 0.6a
    (gimp-selection-none img)
    (if (= expand? TRUE) (gimp-layer-resize-to-image-size layer))

;begin
    (layer_effects_common1 img layer color angle offset-radius radius blur-radius
                           opacity layer-mode "Drop Shadow" 0 link?)
;end

    (gimp-context-set-background old-bg)
    (gimp-selection-load currentselection) ; these two lines are new in version 0.6a
    (gimp-image-remove-channel img currentselection)
    (if (= link? TRUE)(gimp-drawable-set-linked layer TRUE)) ; added in version 0.6b
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script_fu_layer_effects_drop_shadow"
  "<Image>/Filters/GimpBox/Script-Fu-中文/图层样式/光照阴影..."
  "为图层alpha通道创建光照阴影"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "Aug, 2001"
  "RGBA"
  SF-IMAGE      "Image"               0
  SF-DRAWABLE   "Drawable"            0
  SF-COLOR      "阴影颜色"        '(0 0 0)
  SF-ADJUSTMENT "Lighting (degrees)"  '(120 0 360 1 15 0 0)
  SF-ADJUSTMENT "偏移半径 (=距离)"       '(10 0 100 1 10 0 1)
  SF-ADJUSTMENT "阴影半径 (=延伸)"       '(0 0 100 1 10 0 1)
  SF-ADJUSTMENT "阴影模糊半径 (size*1.5)"  '(5 0 100 1 10 0 1)
  SF-ADJUSTMENT "阴影不透明度" '(75 0 100 1 10 0 0)
  SF-OPTION     "阴影图层模式"   '("默认 (相乘)" "溶解" "正常"
                                        "相乘" "掩蔽" "覆盖" "差值"
                                        "相加" "减去" "仅变暗" "仅变亮"
                                        "色调" "饱和度" "Color" "亮度" "相除")
  SF-TOGGLE     "套索图层?"           TRUE
  SF-TOGGLE     "通常是,图层适应图像大小! "	TRUE
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                  Inner Shadow script                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (script_fu_layer_effects_inner_shadow
                   img           ; 
                   layer         ; 
                   color         ; 
                   angle         ; 
                   offset-radius ; 
                   radius        ; 
                   blur-radius   ; 
                   opacity       ; 
                   layer-mode    ; 
		   link?	 ;
                   expand?       ; 
        )

  (let* (
         (old-bg (car (gimp-context-get-background)))
         (layer-mode (cond ((= layer-mode 0) 3)
                           ((= layer-mode 2) 0)
                           (layer-mode)))
	 (currentselection)
        )
    (gimp-image-undo-group-start img)
    (set! currentselection (car(gimp-selection-save img))) ; these two lines are new in version 0.6a
    (gimp-selection-none img)
    (if (= expand? TRUE) (gimp-layer-resize-to-image-size layer))


;begin
    (layer_effects_common1 img layer color angle offset-radius radius blur-radius
                           opacity layer-mode "Inner Shadow" 1  link?)
;end



    (gimp-context-set-background old-bg)
    (gimp-selection-load currentselection) ; these two lines are new in version 0.6a
    (gimp-image-remove-channel img currentselection)
    (if (= link? TRUE)(gimp-drawable-set-linked layer TRUE)) ; added in version 0.6b
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script_fu_layer_effects_inner_shadow"
  "<Image>/Filters/GimpBox/Script-Fu-中文/图层样式/内阴影..."
  "为图层alpha通达创建内阴影"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "Aug, 2001"
  "RGBA"
  SF-IMAGE      "Image"               0
  SF-DRAWABLE   "Drawable"            0
  SF-COLOR      "阴影颜色"        '(0 0 0)
  SF-ADJUSTMENT "Lighting (degrees)"  '(120 0 360 1 15 0 0)
  SF-ADJUSTMENT "偏移半径 (=距离)"       '(5 0 100 1 10 0 1)
  SF-ADJUSTMENT "阴影半径 (阻塞)"       '(0 0 100 1 10 0 1)
  SF-ADJUSTMENT "阴影模糊半径 (=size)"  '(5 0 100 1 10 0 1)
  SF-ADJUSTMENT "阴影图层不透明度" '(75 0 100 1 10 0 0)
  SF-OPTION     "阴影图层模式"   '("默认 (相乘)" "溶解" "正常"
                                        "相乘" "掩蔽" "覆盖" "差值"
                                        "相加" "减去" "仅变暗" "仅变亮"
                                        "色调" "饱和度" "Color" "亮度" "相除")
  SF-TOGGLE     "套索图层?"           TRUE
  SF-TOGGLE     "通常是,图层适应图像大小! "	TRUE
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                  Outer Glow script                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (script_fu_layer_effects_outer_glow
                   img           ; 
                   layer         ; 
                   color         ; 
                   radius        ; 
                   blur-radius   ; 
                   opacity       ; 
                   layer-mode    ; 
		   link?	 ;
                   expand?       ; 
        )

  (let* (
         (old-bg (car (gimp-context-get-background)))
         (layer-mode (cond ((= layer-mode 0) 4)
                           ((= layer-mode 2) 0)
                           (layer-mode)))
	 (currentselection)
        )

    (gimp-image-undo-group-start img)
    (set! currentselection (car(gimp-selection-save img))) ; these two lines are new in version 0.6a
    (gimp-selection-none img)
    (if (= expand? TRUE) (gimp-layer-resize-to-image-size layer))


;begin
    (layer_effects_common1 img layer color 0 0 radius blur-radius
                           opacity layer-mode "Outer Glow" 0  link?)
;end

    (gimp-selection-load currentselection) ; these two lines are new in version 0.6a
    (gimp-image-remove-channel img currentselection)
    (if (= link? TRUE)(gimp-drawable-set-linked layer TRUE)) ; added in version 0.6b
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script_fu_layer_effects_outer_glow"
  "<Image>/Filters/GimpBox/Script-Fu-中文/图层样式/外发光..."
  "为图层alpha通道创建外发光"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "Aug, 2001"
  "RGBA"
  SF-IMAGE      "Image"               0
  SF-DRAWABLE   "Drawable"            0
  SF-COLOR      "发光颜色"          '(255 255 191)
  SF-ADJUSTMENT "发光半径 (size/2)"         '(2 0 100 1 10 0 1)
  SF-ADJUSTMENT "模糊半径 (size*2)"         '(10 0 100 1 10 0 1)
  SF-ADJUSTMENT "不透明度"             '(75 0 100 1 10 0 0)
  SF-OPTION     "发光图层模式"     '("默认 (掩蔽)" "融化" "正常"
                                        "相乘" "掩蔽" "覆盖" "差值"
                                        "相加" "相减" "仅变暗" "仅变亮"
                                        "色调" "饱和度" "Color" "亮度" "相除")
  SF-TOGGLE     "套索图层?"           TRUE
  SF-TOGGLE     "通常是,图层适应图像大小! "	TRUE
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                  Inner Glow script                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (script_fu_layer_effects_inner_glow
                   img           ; 
                   layer         ; 
                   color         ; 
                   radius        ; 
                   blur-radius   ; 
                   opacity       ; 
                   layer-mode    ; 
                   glow-type     ; Edge(0) or Inside(1)
		   link?	 ;
                   expand?       ; 
        )

  (let* (
         (old-bg (car (gimp-context-get-background)))
         (layer-mode (cond ((= layer-mode 0) 4)
                           ((= layer-mode 2) 0)
                           (layer-mode)))
         (glow-type (+ glow-type 1))
	 (currentselection)
        )

    (gimp-image-undo-group-start img)
    (set! currentselection (car(gimp-selection-save img))) ; these two lines are new in version 0.6a
    (gimp-selection-none img)
    (if (= expand? TRUE) (gimp-layer-resize-to-image-size layer))


;begin
    (layer_effects_common1 img layer color 0 0 radius blur-radius
                           opacity layer-mode "Inner Glow" glow-type  link?)
;end


    (gimp-selection-load currentselection) ; these two lines are new in version 0.6a
    (gimp-image-remove-channel img currentselection)
    (if (= link? TRUE)(gimp-drawable-set-linked layer TRUE)) ; added in version 0.6b
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script_fu_layer_effects_inner_glow"
  "<Image>/Filters/GimpBox/Script-Fu-中文/图层样式/内发光..."
  "为图层alpha通道创建内发光"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "Aug, 2001"
  "RGBA"
  SF-IMAGE      "Image"               0
  SF-DRAWABLE   "Drawable"            0
  SF-COLOR      "发光颜色"          '(255 255 191)
  SF-ADJUSTMENT "发光半径 (阻塞)"         '(0 0 100 1 10 0 1)
  SF-ADJUSTMENT "模糊半径 (size*2)"         '(10 0 100 1 10 0 1)
  SF-ADJUSTMENT "不透明度"             '(75 0 100 1 10 0 0)
  SF-OPTION     "发光图层模式"     '("默认 (掩蔽)" "融化" "正常"
                                        "相乘" "掩蔽" "覆盖" "差值"
                                        "相加" "相减" "仅变暗" "仅变亮"
                                        "色调" "饱和度" "Color" "亮度" "相除")
  SF-OPTION     "发光类型"           '("边缘" "内部")
  SF-TOGGLE     "套索图层?"           TRUE
  SF-TOGGLE     "通常是,图层适应图像大小! "	TRUE
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Bevel and Emboss script                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (script_fu_layer_effects_bevel_and_emboss
                   img           ; 
                   layer         ; 
                   effect-style  ; Outer Bevel(0) Inner Bevel(1)
                                 ; Emboss(2) Pillow Emboss(3)
                   angle         ; 
                   depth         ; 
                   blur-radius   ; 
                   light-color   ; 
                   light-opacity ; 
                   light-mode    ; 
                   shadow-color  ; 
                   shadow-opacity; 
                   shadow-mode   ; 
		   link?	 ;
                   expand?       ; 
        )

  (let* (
         (old-bg (car (gimp-context-get-background)))
         (light-mode (cond ((= light-mode 0) 4)
                           ((= light-mode 2) 0)
                           (light-mode)))
         (shadow-mode (cond ((= shadow-mode 0) 3)
                            ((= shadow-mode 2) 0)
                            (shadow-mode)))
	 (currentselection)
        )

    (gimp-image-undo-group-start img)
    (set! currentselection (car(gimp-selection-save img))) ; these two lines are new in version 0.6a
    (gimp-selection-none img)
    (if (= expand? TRUE) (gimp-layer-resize-to-image-size layer))


;begin
    (cond
      ((= effect-style 0)     ; Inner Bevel
          (layer_effects_common1 img layer shadow-color angle depth 0 blur-radius
                                 shadow-opacity shadow-mode "Bevel Shadow" 0  link?)
          (layer_effects_common1 img layer light-color (+ angle 180) depth 0 blur-radius
                                 light-opacity light-mode "Bevel Light" 0  link?)
      )
      ((= effect-style 1)     ; Outer Bevel
          (layer_effects_common1 img layer shadow-color (+ angle 180) depth 0 blur-radius
                                 shadow-opacity shadow-mode "Bevel Shadow" 1  link?)
          (layer_effects_common1 img layer light-color angle depth 0 blur-radius
                                 light-opacity light-mode "Bevel Light" 1  link?)
      )
      ((= effect-style 2)     ; Emboss
          (layer_effects_common1 img layer shadow-color angle (/ depth 2) 0 blur-radius
                                 shadow-opacity shadow-mode "Emboss Outer Shadow" 0  link?)
          (layer_effects_common1 img layer light-color (+ angle 180) (/ depth 2) 0 blur-radius
                                 light-opacity light-mode "Emboss Outer Light" 0  link?)
          (layer_effects_common1 img layer shadow-color (+ angle 180) (/ depth 2) 0 blur-radius
                                 shadow-opacity shadow-mode "Emboss Inner Shadow" 1  link?)
          (layer_effects_common1 img layer light-color angle (/ depth 2) 0 blur-radius
                               light-opacity light-mode "Emboss Inner Light" 1  link?)
      )
      ((= effect-style 3)     ; Pillow Emboss
          (layer_effects_common1 img layer shadow-color (+ angle 180) (* depth 0.75) 0 blur-radius
                                 shadow-opacity shadow-mode "Emboss Outer Shadow" 0  link?)
          (layer_effects_common1 img layer light-color angle (* depth 0.75) 0 blur-radius
                                 light-opacity light-mode "Emboss Outer Light" 0  link?)
          (layer_effects_common1 img layer shadow-color (+ angle 180) (* depth 0.75) 0 blur-radius
                                 shadow-opacity shadow-mode "Emboss Inner Shadow" 1  link?)
          (layer_effects_common1 img layer light-color angle (* depth 0.75) 0 blur-radius
                                 light-opacity light-mode "Emboss Inner Light" 1  link?)
      )
    ) ; end of cond
;end


    (gimp-selection-load currentselection) ; these two lines are new in version 0.6a
    (gimp-image-remove-channel img currentselection)
    (if (= link? TRUE)(gimp-drawable-set-linked layer TRUE)) ; added in version 0.6b
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script_fu_layer_effects_bevel_and_emboss"
  "<Image>/Filters/GimpBox/Script-Fu-中文/图层样式/斜面和浮雕..."
  "为图层alpha通道添加斜面和浮雕效果"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "Aug, 2001"
  "RGBA"
  SF-IMAGE      "Image"               0
  SF-DRAWABLE   "Drawable"            0
  SF-OPTION     "效果风格"        '("外斜面" "内斜面"
                                        "浮雕" "平台凸")
  SF-ADJUSTMENT "Lighting (degrees)"  '(120 0 360 1 15 0 0)
  SF-ADJUSTMENT "深度 (=size)"               '(5 0 100 1 10 0 1)
  SF-ADJUSTMENT "模糊半径 (size/2)"         '(3 0 100 1 10 0 1)
  SF-COLOR      "加亮颜色"     '(255 255 255)
  SF-ADJUSTMENT "加亮不透明度"   '(60 0 100 1 10 0 0)
  SF-OPTION     "加亮图层模式"  '("默认 (掩蔽)" "融化" "正常"
                                        "相乘" "掩蔽" "覆盖" "差值"
                                        "相加" "相减" "仅变暗" "仅变亮"
                                        "色调" "饱和度" "Color" "亮度" "相除")
  SF-COLOR      "阴影颜色"        '(0 0 0)
  SF-ADJUSTMENT "阴影不透明度"      '(60 0 100 1 10 0 0)
  SF-OPTION     "阴影图层模式"   '("默认 (相乘)" "溶解" "正常"
                                        "相乘" "掩蔽" "覆盖" "差值"
                                        "相加" "减去" "仅变暗" "仅变亮"
                                        "色调" "饱和度" "Color" "亮度" "相除")
  SF-TOGGLE     "套索图层?"           TRUE
  SF-TOGGLE     "通常是,图层适应图像大小! "	TRUE
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Satin Effect script                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (script_fu_layer_effects_satin
                   img           ; 
                   layer         ; 
                   color         ; 
                   angle         ; 
                   offset-radius ; 
                   blur-radius   ; 
                   opacity       ; 
                   layer-mode    ; 
                   invert?       ; 
		   link?	 ;
                   expand?       ; 
         )

  (let* (
         (old-bg (car (gimp-context-get-background)))
;         (width (car (gimp-drawable-width layer)))
;         (height (car (gimp-drawable-height layer)))
         (width (car (cond ((= expand? TRUE)(gimp-image-width img)) ((gimp-drawable-width layer)))))
         (height (car (cond ((= expand? TRUE)(gimp-image-height img)) ((gimp-drawable-height layer)))))
;version 0.6b angle 0° moved from top to right
         (radians (/ (* 2 *pi* (- angle 90)) 360))
         (x-offset (* offset-radius (sin radians)))
         (y-offset (* offset-radius (cos radians)))
         (layer-mode (cond ((= layer-mode 0) 3)
                           ((= layer-mode 2) 0)
                           (layer-mode)))
         (satin-layer1 (car (gimp-layer-new img width height RGBA-IMAGE
                                  "Satin Effect" 100 NORMAL-MODE)))
         (satin-layer2 (car (gimp-layer-new img width height RGBA-IMAGE
                                  "Satin Effect" 100 DIFFERENCE-MODE)))
	 (currentselection)
	 (satin-layer)
	 (satin-mask1)
	 (satin-mask2)
	 (satin-mask3)
        )

    (gimp-image-undo-group-start img)
    (set! currentselection (car(gimp-selection-save img))) ; these two lines are new in version 0.6a
    (gimp-selection-none img)
    (if (= expand? TRUE) (gimp-layer-resize-to-image-size layer))


;begin
    (gimp-image-add-layer img satin-layer1 -1)
    (gimp-image-add-layer img satin-layer2 -1)
    (gimp-drawable-fill satin-layer1 WHITE-IMAGE-FILL)
    (gimp-drawable-fill satin-layer2 WHITE-IMAGE-FILL)
    (gimp-selection-layer-alpha layer)
    (gimp-context-set-background '(0 0 0))
    (gimp-edit-fill satin-layer1 BG-IMAGE-FILL)
    (gimp-edit-fill satin-layer2 BG-IMAGE-FILL)
    (gimp-drawable-offset satin-layer1 FALSE OFFSET-BACKGROUND x-offset y-offset)
    (gimp-drawable-offset satin-layer2 FALSE OFFSET-BACKGROUND (- x-offset) (- y-offset))

    (set! satin-layer (car (gimp-image-merge-down img satin-layer2 EXPAND-AS-NECESSARY)))
    (set! satin-mask1 (car (gimp-layer-create-mask satin-layer BLACK-MASK)))
;replaced 2005-11-13
;    (gimp-image-add-layer-mask img satin-layer satin-mask1)
    (gimp-layer-add-mask satin-layer satin-mask1)
    (gimp-edit-fill satin-mask1 WHITE-IMAGE-FILL)
    (gimp-selection-none img)
    ;(plug-in-colortoalpha 1 img satin-layer '(255 255 255))
    (if (eqv? invert? TRUE)
        (gimp-invert satin-layer))
    (gimp-edit-copy satin-layer)
    (set! satin-mask2 (car (gimp-floating-sel-anchor
                                 (car (gimp-edit-paste satin-mask1 0)))))
;replaced 2005-11-13
;    (gimp-image-remove-layer-mask img satin-layer APPLY)
    (gimp-layer-remove-mask satin-layer APPLY)
    (set! satin-mask3 (car (gimp-layer-create-mask satin-layer BLACK-MASK)))
;replaced 2005-11-13
;    (gimp-image-add-layer-mask img satin-layer satin-mask3)
    (gimp-layer-add-mask satin-layer satin-mask3)
    (gimp-selection-layer-alpha layer)
    (gimp-edit-fill satin-mask3 WHITE-IMAGE-FILL)

    (gimp-selection-layer-alpha satin-layer)
    (gimp-context-set-background color)
    (gimp-edit-fill satin-layer BG-IMAGE-FILL)
    (gimp-selection-none img)
    (if (< 0 blur-radius)
        (plug-in-gauss-iir2 1 img satin-layer blur-radius blur-radius))
    (gimp-layer-set-opacity satin-layer opacity)
    (gimp-layer-set-mode satin-layer layer-mode)

    (gimp-image-set-active-layer img layer)
    (gimp-context-set-background old-bg)
;end


    (gimp-selection-load currentselection) ; these two lines are new in version 0.6a
    (gimp-image-remove-channel img currentselection)
    (if (= link? TRUE)(gimp-drawable-set-linked satin-layer TRUE)) ; added in version 0.6b
    (if (= link? TRUE)(gimp-drawable-set-linked layer TRUE)) ; added in version 0.6b
    (gimp-layer-set-edit-mask satin-layer FALSE) ; added in version 0.6b beacause mask can't be linked, therefore it's put inactive.
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (list satin-layer)
  )
)

(script-fu-register
  "script_fu_layer_effects_satin"
  "<Image>/Filters/GimpBox/Script-Fu-中文/图层样式/光泽..."
  "为图层alpha通道创建光泽效果"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "Aug, 2001"
  "RGBA"
  SF-IMAGE      "Image"               0
  SF-DRAWABLE   "Drawable"            0
  SF-COLOR      "光泽颜色"         '(0 0 0)
  SF-ADJUSTMENT "Angle"               '(120 0 360 1 15 0 0)
  SF-ADJUSTMENT "光泽半径"        '(10 0 100 1 10 0 1)
  SF-ADJUSTMENT "模糊半径"         '(10 0 100 1 10 0 1)
  SF-ADJUSTMENT "Opacity"             '(50 0 100 1 10 0 0)
  SF-OPTION     "光泽图层模式"    '("默认 (相乘)" "溶解" "正常"
                                        "相乘" "掩蔽" "覆盖" "差值"
                                        "相加" "减去" "仅变暗" "仅变亮"
                                        "色调" "饱和度" "Color" "亮度" "相除")
  SF-TOGGLE     "Invert"              TRUE
  SF-TOGGLE     "套索图层?"           TRUE
  SF-TOGGLE     "通常是,图层适应图像大小! "	TRUE
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Color Overlay script                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (script_fu_layer_effects_color_overlay
                   img           ; 
                   layer         ; 
                   color         ; 
                   opacity       ; 
                   layer-mode    ; 
		   link?	 ;
                   expand?       ; 
         )

  (let* (
         (old-bg (car (gimp-context-get-background)))
;         (width (car (gimp-drawable-width layer)))
;         (height (car (gimp-drawable-height layer)))
         (width (car (cond ((= expand? TRUE)(gimp-image-width img)) ((gimp-drawable-width layer)))))
         (height (car (cond ((= expand? TRUE)(gimp-image-height img)) ((gimp-drawable-height layer)))))
         (layer-mode (cond ((= layer-mode 0) 0)
                           ((= layer-mode 2) 0)
                           (layer-mode)))
         (color-layer (car (gimp-layer-new img width height RGBA-IMAGE
                                 "Color Fill Layer" opacity layer-mode)))
	 (currentselection)
        )

    (gimp-image-undo-group-start img)
    (set! currentselection (car(gimp-selection-save img))) ; these two lines are new in version 0.6a
    (gimp-selection-none img)
    (if (= expand? TRUE) (gimp-layer-resize-to-image-size layer))


;begin
    (gimp-image-add-layer img color-layer -1)
    (gimp-drawable-fill color-layer TRANS-IMAGE-FILL)
    (gimp-selection-layer-alpha layer)
    (gimp-context-set-background color)
    (gimp-edit-fill color-layer BG-IMAGE-FILL)
    (gimp-selection-none img)

    (gimp-image-set-active-layer img layer)
;end


    (gimp-context-set-background old-bg)
    (gimp-selection-load currentselection) ; these two lines are new in version 0.6a
    (gimp-image-remove-channel img currentselection)
    (if (= link? TRUE)(gimp-drawable-set-linked color-layer TRUE)) ; added in version 0.6b
    (if (= link? TRUE)(gimp-drawable-set-linked layer TRUE)) ; added in version 0.6b
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (list color-layer)
  )
)

(script-fu-register
  "script_fu_layer_effects_color_overlay"
  "<Image>/Filters/GimpBox/Script-Fu-中文/图层样式/颜色覆盖..."
  "为图层alpha通道创建颜色覆盖效果"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "Aug, 2001"
  "RGBA"
  SF-IMAGE      "Image"               0
  SF-DRAWABLE   "Drawable"            0
  SF-COLOR      "Color"               '(0 0 0)
  SF-ADJUSTMENT "Opacity"             '(100 0 100 1 10 0 0)
  SF-OPTION     "颜色覆盖模式"     '("默认 (相乘)" "溶解" "正常"
                                        "相乘" "掩蔽" "覆盖" "差值"
                                        "相加" "减去" "仅变暗" "仅变亮"
                                        "色调" "饱和度" "Color" "亮度" "相除")
  SF-TOGGLE     "套索图层?"           TRUE
  SF-TOGGLE     "通常是,图层适应图像大小! "	TRUE
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Gradient Overlay script                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (script_fu_layer_effects_gradient_overlay
                   img           ; 
                   layer         ; 
                   fg-color      ; 
                   bg-color      ; 
                   blend-mode    ; 
                   gradient      ; 
                   angle         ; 
                   scale         ; 
                   opacity       ; 
                   layer-mode    ; 
                   style         ; 
                   repeat        ; 
		   link?	 ;
                   expand?       ; 
         )

  (let* (
         (old-fg (car (gimp-context-get-foreground)))
         (old-bg (car (gimp-context-get-background)))
         (old-gradient (car (gimp-context-get-gradient)))
;         (width (car (gimp-drawable-width layer)))
;         (height (car (gimp-drawable-height layer)))
         (width (car (cond ((= expand? TRUE)(gimp-image-width img)) ((gimp-drawable-width layer)))))
         (height (car (cond ((= expand? TRUE)(gimp-image-height img)) ((gimp-drawable-height layer)))))
         (layer-mode (cond ((= layer-mode 0) 0)
                           ((= layer-mode 2) 0)
                           (layer-mode)))
;version 0.6b angle 0° moved from top to right
         (radians (/ (* 2 *pi* (- angle 90)) 360))
         (x-distance (* 0.5 scale width (sin radians)))
         (y-distance (* 0.5 scale height (cos radians)))
         (x-center (/ width 2))
         (y-center (/ height 2))
         (x1 (- x-center x-distance))
         (y1 (- y-center y-distance))
         (x2 (+ x-center x-distance))
         (y2 (+ y-center y-distance))
         (gradient-layer (car (gimp-layer-new img width height RGBA-IMAGE
                                    "Gradient Fill Layer" opacity layer-mode)))
	 (currentselection)
        )

    (gimp-image-undo-group-start img)
    (set! currentselection (car(gimp-selection-save img))) ; these two lines are new in version 0.6a
    (gimp-selection-none img)
    (if (= expand? TRUE) (gimp-layer-resize-to-image-size layer))


;begin
    (gimp-image-add-layer img gradient-layer -1)
    (gimp-drawable-fill gradient-layer TRANS-IMAGE-FILL)
    (gimp-selection-layer-alpha layer)
    (gimp-context-set-foreground fg-color)
    (gimp-context-set-background bg-color)
    (gimp-context-set-gradient gradient)
;
;hier werden 14 Parameter übergeben, 16 sind aber gefordert
;da der Programmierer wie es scheint supersampling nicht beachtet hat,
;setze ich das auf FALSE und den fehlenden supersamling threshold auf 0
;(sollte durch das FALSE egal sein, welchen Wert das hat)
;ausserdem hab' ich auch hier die deprecated procedure ersetzt
;
;	(gimp-edit-blend gradient-layer blend-mode NORMAL-MODE style 100 0 repeat
;                               FALSE 0 0 x1 y1 x2 y2)
;                               
    (gimp-edit-blend gradient-layer blend-mode NORMAL-MODE style 100 0 repeat
                               FALSE FALSE 0 0 0 x1 y1 x2 y2)
    (gimp-selection-none img)

    (gimp-image-set-active-layer img layer)
    (gimp-context-set-foreground old-fg)
    (gimp-context-set-background old-bg)
    (gimp-context-set-gradient old-gradient)
;end


    (gimp-selection-load currentselection) ; these two lines are new in version 0.6a
    (gimp-image-remove-channel img currentselection)
    (if (= link? TRUE)(gimp-drawable-set-linked gradient-layer TRUE)) ; added in version 0.6b
    (if (= link? TRUE)(gimp-drawable-set-linked layer TRUE)) ; added in version 0.6b
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (list gradient-layer)
  )
)

(script-fu-register
  "script_fu_layer_effects_gradient_overlay"
  "<Image>/Filters/GimpBox/Script-Fu-中文/图层样式/渐变覆盖..."
  "为图层alpha通道创建渐变覆盖效果"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "Aug, 2001"
  "RGBA"
  SF-IMAGE      "Image"               0
  SF-DRAWABLE   "Drawable"            0
  SF-COLOR      "前景颜色"    '(127 255 255)
  SF-COLOR      "背景颜色"    '(127 255 127)
  SF-OPTION     "渐变模式"          '("前景-背景 RGB" "前景-背景 HSV" "前景-透明" "定制")
  SF-GRADIENT   "Gradient"            "Sunrise"
  SF-ADJUSTMENT "Angle"               '(120 0 360 1 15 0 0)
  SF-ADJUSTMENT "比例"               '(1.00 0.05 5 0.05 0.1 2 0)
  SF-ADJUSTMENT "Opacity"             '(100 0 100 1 10 0 0)
  SF-OPTION     "渐变填充模式"  '("默认 (相乘)" "溶解" "正常"
                                        "相乘" "掩蔽" "覆盖" "差值"
                                        "相加" "减去" "仅变暗" "仅变亮"
                                        "色调" "饱和度" "Color" "亮度" "相除")
  SF-OPTION     "渐变样式"      '("线性" "对称线性" "径向" "正方"
                                        "对称圆锥" "非对称圆锥"
                                        "尖角形状" "球状形状"
                                        "涟漪形状" "顺时针螺旋"
                                        "逆时针螺旋")
  SF-OPTION     "重复"              '("从不" "锯齿波" "三角波")
  SF-TOGGLE     "套索图层?"           TRUE
  SF-TOGGLE     "通常是,图层适应图像大小! "	TRUE
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Pattern Overlay script                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (script_fu_layer_effects_pattern_overlay
                   img           ; 
                   layer         ; 
                   pattern       ; 
                   opacity       ; 
                   layer-mode    ; 
		   link?	 ;
                   expand?       ; 
         )

  (let* (
         (old-pattern (car (gimp-context-get-pattern)))
;         (width (car (gimp-drawable-width layer)))
;         (height (car (gimp-drawable-height layer)))
         (width (car (cond ((= expand? TRUE)(gimp-image-width img)) ((gimp-drawable-width layer)))))
         (height (car (cond ((= expand? TRUE)(gimp-image-height img)) ( (gimp-drawable-height layer)))))
         (layer-mode (cond ((= layer-mode 0) 0)
                           ((= layer-mode 2) 0)
                           (layer-mode)))
         (pattern-layer (car (gimp-layer-new img width height RGBA-IMAGE
                                   "Pattern Fill Layer" opacity layer-mode)))
	 (currentselection)
        )

    (gimp-image-undo-group-start img)
    (set! currentselection (car(gimp-selection-save img))) ; these two lines are new in version 0.6a
    (gimp-selection-none img)
    (if (= expand? TRUE) (gimp-layer-resize-to-image-size layer))


;begin
    (gimp-image-add-layer img pattern-layer -1)
    (gimp-drawable-fill pattern-layer TRANS-IMAGE-FILL)
    (gimp-selection-layer-alpha layer)
    (gimp-context-set-pattern pattern)
    (gimp-edit-bucket-fill pattern-layer PATTERN-BUCKET-FILL NORMAL-MODE 100 0 FALSE 0 0)
    (gimp-selection-none img)

    (gimp-image-set-active-layer img layer)
    (gimp-context-set-pattern old-pattern)
;end


    (gimp-selection-load currentselection) ; these two lines are new in version 0.6a
    (gimp-image-remove-channel img currentselection)
    (if (= link? TRUE)(gimp-drawable-set-linked pattern-layer TRUE)) ; added in version 0.6b
    (if (= link? TRUE)(gimp-drawable-set-linked layer TRUE)) ; added in version 0.6b
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (list pattern-layer)
  )
)

(script-fu-register
  "script_fu_layer_effects_pattern_overlay"
  "<Image>/Filters/GimpBox/Script-Fu-中文/图层样式/图案覆盖..."
  "为图层alpha通道创建图案覆盖效果"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "Aug, 2001"
  "RGBA"
  SF-IMAGE      "Image"               0
  SF-DRAWABLE   "Drawable"            0
  SF-PATTERN    "Pattern"             "Pine?"
  SF-ADJUSTMENT "Opacity"             '(100 0 100 1 10 0 0)
  SF-OPTION     "图案覆盖模式"   '("默认 (相乘)" "溶解" "正常"
                                        "相乘" "掩蔽" "覆盖" "差值"
                                        "相加" "减去" "仅变暗" "仅变亮"
                                        "色调" "饱和度" "Color" "亮度" "相除")
  SF-TOGGLE     "套索图层?"           TRUE
  SF-TOGGLE     "通常是,图层适应图像大小! "	TRUE
)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Add Border script                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (script_fu_layer_effects_add_border
                   img           ; 
                   layer         ; 
                   type          ; Color(0) Gradient(1) Pattern(2)
                   size          ;
		   choise	 ; user's choise, inner, outer or center
                   freeposition  ; 
                   opacity       ; 
                   layer-mode    ; 
                   color         ; 
                   fg-color      ; 
                   bg-color      ; 
                   blend-mode    ; 
                   gradient      ; 
                   angle         ; 
                   scale         ; 
                   style         ; 
                   repeat        ; 
                   pattern       ; 
		   link?	 ;
                   expand?       ; 
         )

  (let* (
; EV: next two lines dropped and replaced by the following two
;         (width (car (gimp-drawable-width layer)))
;         (height (car (gimp-drawable-height layer)))
         (width (car (cond ((= expand? TRUE)(gimp-image-width img)) ( (gimp-drawable-width layer)))))
         (height (car (cond ((= expand? TRUE)(gimp-image-height img)) ( (gimp-drawable-height layer)))))
         (border-layer (car (gimp-layer-new img width height RGBA-IMAGE
                                  "Border Line" opacity layer-mode)))
	 (currentselectionAB)
	 (selectionalpha)
	 (wl)
	 (wr)
	 (position)
	 (selectioninner)
	 (result-layer)
        )

    (gimp-image-undo-group-start img)
    (set! currentselectionAB (car(gimp-selection-save img))) ; these two lines are new in version 0.6a
    (gimp-selection-none img)
    (if (= expand? TRUE) (gimp-layer-resize-to-image-size layer))


;begin
    (gimp-image-add-layer img border-layer -1)
    (gimp-drawable-fill border-layer TRANS-IMAGE-FILL)
    (gimp-selection-layer-alpha layer)

; *******  Eddy Verlinden : this part - the makeing of the border is totally different in version 0.6a
    (set! selectionalpha (car(gimp-selection-save img)))
    (set! wl (- (/ size 2) (fmod (/ size 2) 1))); left width
    (set! wr (+ (/ size 2) (fmod (/ size 2) 1))); right width = biggest if uneven
    (cond 
       ((= choise 0) (set! position freeposition))
       ((= choise 1) (set! position (- 0 wr)))
       ((= choise 2) (set! position (+ 0 wl)))
       ((= choise 3) (set! position 0))
    )
    (cond
       (
       (and (< position 0) (<= wr (- position)) ) ; inner border
          (begin
             (gimp-selection-shrink img (+ (- position) wl))
             (set! selectioninner (car (gimp-selection-save img)))	
             (gimp-selection-load selectionalpha)
             (gimp-selection-shrink img (- (- position) wr))
             (gimp-selection-combine selectioninner 1)  
          ) ; end of begin
       ) ; end of comp 1
       ( 
       (and (< position 0) (> wr (- position)) ) ; shift to left
          (begin
             (gimp-selection-shrink img (+ (- position) wl))
             (set! selectioninner (car (gimp-selection-save img)))	
             (gimp-selection-load selectionalpha)
             (gimp-selection-grow img (+ position wr))
             (gimp-selection-combine selectioninner 1)  
          ) ; end of begin
       ) ; end of comp 2
       (
       (and (>= position 0) (>= wl position )) ; shift to right, or CENTER
          (begin
             (gimp-selection-shrink img (- wl position))
             (set! selectioninner (car (gimp-selection-save img)))	
             (gimp-selection-load selectionalpha)
             (gimp-selection-grow img (+ position wr))
             (gimp-selection-combine selectioninner 1)  
          ) ; end of begin
       ) ; end of comp 3
       (
       (and (>= position 0) (< wl position ) ) ; outer border
          (begin
             (gimp-selection-grow img (- position wl))
             (set! selectioninner (car (gimp-selection-save img)))	
             (gimp-selection-load selectionalpha)
             (gimp-selection-grow img (+ position wr))
             (gimp-selection-combine selectioninner 1)  
          ) ; end of begin
       ) ; end of comp 4
    ) ; end of cond

; ********** end of the new part in version 0.6a

    (if (< (car (gimp-selection-is-empty img)) 0)
        (gimp-message "The selection is empty. Abort.")
        (begin
          (gimp-edit-fill border-layer WHITE-IMAGE-FILL)
          (set! result-layer (car 
            (cond
              ((= type 0)
                 (script_fu_layer_effects_color_overlay
                            img border-layer color opacity layer-mode link? expand?))
              ((= type 1)
                 (script_fu_layer_effects_gradient_overlay
                            img border-layer fg-color bg-color blend-mode gradient
                            angle scale opacity layer-mode style repeat link? expand?))
              ((= type 2)
                 (script_fu_layer_effects_pattern_overlay
                            img border-layer pattern opacity layer-mode link? expand?))
              ) ; end of cond
          )) ; end of set! and car
          (gimp-drawable-fill border-layer TRANS-IMAGE-FILL)
          (set! border-layer (car (gimp-image-merge-down
                                        img result-layer EXPAND-AS-NECESSARY)))
        ) ; end of begin
    ) ; end of if

    (gimp-image-remove-channel img selectioninner); these four lines are new in version 0.6a
    (gimp-image-remove-channel img selectionalpha)


;end
    (gimp-selection-load currentselectionAB) 
    (gimp-image-remove-channel img currentselectionAB)
    (if (= link? TRUE)(gimp-drawable-set-linked border-layer TRUE)) ; added in version 0.6b
    (if (= link? TRUE)(gimp-drawable-set-linked layer TRUE)) ; added in version 0.6b
    (gimp-image-undo-group-end img)
    (gimp-image-set-active-layer img layer)
    (gimp-displays-flush)
    (list border-layer)
  )
)

(script-fu-register
  "script_fu_layer_effects_add_border"
  "<Image>/Filters/GimpBox/Script-Fu-中文/图层样式/添加边界 (勾画)..."
  "为图层alpha通道创建边界效果"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "Aug, 2001"
  "RGBA"
  SF-IMAGE      "Image"               0
  SF-DRAWABLE   "Drawable"            0
  SF-OPTION     "边界填充模式"    '("Color" "Gradient" "Pattern")
  SF-ADJUSTMENT "边界大小"         '(1 1 100 1 5 0 1)
  SF-OPTION     "边界位置"     '("自由" "内边界" "外边界" "中心边界")
  SF-ADJUSTMENT "边界位置 (如果为自由)"     '(0 -10 10 1 5 0 0)
  SF-ADJUSTMENT "Opacity"             '(100 0 100 1 10 0 0)
  SF-OPTION     "边界填充模式"    '("默认 (相乘)" "溶解" "正常"
                                        "相乘" "掩蔽" "覆盖" "差值"
                                        "相加" "减去" "仅变暗" "仅变亮"
                                        "色调" "饱和度" "Color" "亮度" "相除")
  SF-COLOR      "Color"               '(0 0 0)
  SF-COLOR      "前景颜色"    '(127 255 255)
  SF-COLOR      "背景颜色"    '(127 255 127)
  SF-OPTION     "渐变模式"          '("前景-背景 RGB" "前景-背景 HSV" "前景-透明" "定制")
  SF-GRADIENT   "Gradient"            "Sunrise"
  SF-ADJUSTMENT "Angle"               '(120 0 360 1 15 0 0)
  SF-ADJUSTMENT "比例"               '(1.00 0.05 5 0.05 0.1 2 0)
  SF-OPTION     "渐变样式"      '("线性" "对称线性" "径向" "正方"
                                        "对称圆锥" "非对称圆锥"
                                        "尖角形状" "球状形状"
                                        "涟漪形状" "顺时针螺旋"
                                        "逆时针螺旋")
  SF-OPTION     "重复"              '("从不" "锯齿波" "三角波")
  SF-PATTERN    "Pattern"             "Pine?"
  SF-TOGGLE     "套索图层?"           TRUE
  SF-TOGGLE     "通常是,图层适应图像大小!"	TRUE
)
