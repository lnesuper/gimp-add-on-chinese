# GIMP中文化平台 #
## gimp-add-on-chinese是GIMP中文化的附加组件 ##
> ### **GIMP滤镜的位置** ###
GIMP滤镜通常指的是以scm结尾的文件.通常称为脚本,她依靠现有的程序进行特效的运算.程序自带的滤镜位于
  * Windows XP/VISTA/7
x:\Program Files\GIMP-2.0\share\gimp\2.0\scripts\
用户自定义滤镜位于

2.4的

`C:\Documents and Settings\Administrator\.gimp-2.4\scripts\`

2.6的

`C:\Documents and Settings\Administrator\.gimp-2.6\scripts\`

  * Linux下略.
> ### **GIMP滤镜安装** ###
将下载的scm(注意是后缀是scm的文件,请注意适应版本.)文件放入如下文件夹中(Linux中称为目录)

  * Windows XP/VISTA/7
x:\Program Files\GIMP-2.0\share\gimp\2.0\scripts\
推荐放入自定义滤镜文件夹中.

2.4的

`C:\Documents and Settings\Administrator\.gimp-2.4\scripts\`

2.6的

`C:\Documents and Settings\Administrator\.gimp-2.6\scripts\`

2.8的

`C:\Documents and Settings\Administrator\.gimp-2.8\scripts\`

  * Linux下.
2.x版(默认安装一个版本)
`/home/user/.gimp-2.x/scripts`

  * 自定义安装.
    1. 2.4版本.工具箱->文件->首选项->文件夹->脚本->选择目录,确定,重启.
    1. 2.6版本.菜单->编辑->首选项->文件夹->脚本->选择目录,确定,重启.

![http://gimp-add-on-chinese.googlecode.com/files/toolbox.png](http://gimp-add-on-chinese.googlecode.com/files/toolbox.png)
  * 滤镜从哪里找到. 通常都可以在菜单-滤镜中找到.其他的可以在编辑,颜色,图层,等这些菜单中找到.
    1. 2.4版本.菜单->滤镜
    1. 2.6版本.菜单->滤镜
> ### **关于GIMP插件** ###
GIMP插件是GIMP中较为复杂的功能,她扩展了GIMP的图片处理能力,比如增加或加强了某种操作,未安装之前不能进行类似的操作.GIMP插件至少可以分为三类(C语言|后缀为" .c ",win编译|后缀为".exe",python语言|后缀为".py")
  * Windows XP/VISTA/7,通常是exe结尾的文件.
x:\Program Files\GIMP-2.0\share\gimp\2.0\plug-ins\
用户自定义滤镜位于

2.4的

`C:\Documents and Settings\Administrator\.gimp-2.4\plug-ins\`

2.6的

`C:\Documents and Settings\Administrator\.gimp-2.6\plug-ins\`

2.8的

`C:\Documents and Settings\Administrator\.gimp-2.8\plug-ins\`
  * inux下:
2.x版(默认安装一个版本)

`/home/user/.gimp-2.x/plug-ins`

power by ![http://code.google.com/images/code_sm.png](http://code.google.com/images/code_sm.png)