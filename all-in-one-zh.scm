; This is a script for The GIMP
;
; Description: all sorts of convenient wrappers for personal use
;
; Runtime requirements: triple-border.scm, scale-to-size.scm
;
; Version 1.0
; Last changed: 11.06.2009
;
; Copyright (C) 2009 Dr. Martin Rogge <marogge@onlinehome.de>
;
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
; Chinese localization:lnesuper,Oct 17,LuoYang,CN.
; 注意一定要安装scale-to-size和triple-border滤镜

(define (script-mr-all-in-one-black img draw)
  (script-mr-scale-to-size img draw 540)
  (script-mr-border img draw 1 '(255 255 255) 47 '(0 0 0) 0 '(255 255 255))
)

(script-fu-register 
  "script-mr-all-in-one-black"
  "<Image>/Tools/All-in-one/All-in-one 黑色边框"
  "我个人all-in-one工作流程:\n缩放图像到 540xN, 适应web浏览unsharp蒙板, 创建一个1+47 pix 黑色边框. 逐步取消可用."
  "Dr. Martin Rogge <marogge@onlinehome.de>"
  "Dr. Martin Rogge"
  "11/06/2009"
  "RGB* GRAY*"
  SF-IMAGE    "Image"         0
  SF-DRAWABLE "Drawable"      0
)

(define (script-mr-all-in-one-white img draw)
  (script-mr-scale-to-size img draw 540)
  (script-mr-border img draw 1 '(0 0 0) 47 '(255 255 255) 0 '(0 0 0))
)

(script-fu-register 
  "script-mr-all-in-one-white"
  "<Image>/Tools/All-in-one/All-in-one 白色边框"
  "我个人all-in-one工作流程:\n缩放图像到 540xN, 适应web浏览unsharp蒙板, 创建一个1+47 pix 黑色边框. 逐步取消可用."
  "Dr. Martin Rogge <marogge@onlinehome.de>"
  "Dr. Martin Rogge"
  "11/06/2009"
  "RGB* GRAY*"
  SF-IMAGE    "Image"         0
  SF-DRAWABLE "Drawable"      0
)

(define (script-mr-border-black img draw)
  (script-mr-border img draw 1 '(255 255 255) 47 '(0 0 0) 0 '(255 255 255))
)

(script-fu-register 
  "script-mr-border-black"
  "<Image>/Tools/All-in-one/边缘黑色"
  "创建一个1+47 pix 黑色边框."
  "Dr. Martin Rogge <marogge@onlinehome.de>"
  "Dr. Martin Rogge"
  "21/12/2004 to 11/06/2009"
  "RGB* GRAY* INDEXED*"
  SF-IMAGE    "Image"         0
  SF-DRAWABLE "Drawable"      0
)

(define (script-mr-border-white img draw)
  (script-mr-border img draw 1 '(0 0 0) 47 '(255 255 255) 0 '(0 0 0))
)

(script-fu-register 
  "script-mr-border-white"
  "<Image>/Tools/All-in-one/边缘白色"
  "创建一个1+47 pix 白色边框"
  "Dr. Martin Rogge <marogge@onlinehome.de>"
  "Dr. Martin Rogge"
  "11/06/2009"
  "RGB* GRAY* INDEXED*"
  SF-IMAGE    "Image"         0
  SF-DRAWABLE "Drawable"      0
)

