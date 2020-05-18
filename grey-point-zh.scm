; Grey point is a script for The GIMP
;
; Description: flexible white balance correction tool
;
; Version 2.2
; Last changed: 11.06.2009
;
; Copyright (C) 2004 Dr. Martin Rogge <marogge@onlinehome.de>
;
; based on:
;
; White/Black balance script  for GIMP 1.2
; Copyright (C) 2002 Iccii <iccii@hotmail.com>
;
; convert something into Chinese by lnesuper@gmail.com
; --------------------------------------------------------------------
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

(define (script-mr-grey-point image drawable mode )

  (define (round x) (trunc (+ x 0.5)))

  (define (interpolate source target i)
    (if (= source 0) target (max (min (round (* (/ target source) i))  255) 0)))

  (let* ((fg           (car (gimp-context-get-foreground)))
         (bg           (car (gimp-context-get-background)))

         (source_red   (car   fg))
         (source_green (cadr  fg))
         (source_blue  (caddr fg))

         (average      (round (/ (+ source_red source_green source_blue) 3)))

         (target_red   (cond ((= mode 0) average)
                             ((= mode 1) 255)
                             ((= mode 2) (car bg))
                        ))
         (target_green (cond ((= mode 0) average)
                             ((= mode 1) 255)
                             ((= mode 2) (cadr bg))
                        ))
         (target_blue  (cond ((= mode 0) average)
                             ((= mode 1) 255)
                             ((= mode 2) (caddr bg))
                        ))

         (i             0)

         (num_bytes     256)

         (red-curve    (cons-array num_bytes 'byte))
         (green-curve  (cons-array num_bytes 'byte))
         (blue-curve   (cons-array num_bytes 'byte))
    )

    (gimp-image-undo-group-start image)

    (while (< i num_bytes)
      (aset red-curve   i (interpolate source_red   target_red   i))
      (aset green-curve i (interpolate source_green target_green i))
      (aset blue-curve  i (interpolate source_blue  target_blue  i))
      (set! i (+ i 1))
    )

    (gimp-curves-explicit drawable RED-LUT   num_bytes red-curve  )
    (gimp-curves-explicit drawable GREEN-LUT num_bytes green-curve)
    (gimp-curves-explicit drawable BLUE-LUT  num_bytes blue-curve )

    (gimp-image-undo-group-end image)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-mr-grey-point"
  "<Image>/Tools/灰点(_G)"
  "线性转换的RGB色彩空间.\n\n这个脚本的作用是依据前景色(即工具箱前景色)转换当前层颜色. 
整个RGB色彩空间是线性转换,以达到预期的前景颜色映射.有三种颜色的目标可能的选择:\n(a) 前景颜色相同密度灰度(减饱和)\n(b) 泛白\n(c) 背景颜色 (即工具性背景色)\n\n这个脚本的主要应用领域可能是数字图像色温校正.为此您可能还想要检查卢Luca de Alfaro的白平衡和Colortemp脚本.\n\nY我们欢迎你的反馈. ;^)"
  "Dr. Martin Rogge <marogge@onlinehome.de>"
  "Dr. Martin Rogge"
  "29/09/2004 to 11/06/2009"
  "RGB*"
  SF-IMAGE    "Image"         0
  SF-DRAWABLE "Drawable"      0
  SF-OPTION   "前景转换"  '("减饱和" "泛白" "背景颜色")
)

