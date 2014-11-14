format binary as 'bmp'

; some basic definitions
width equ 400
height equ 400
bytesperpixel=4
foreground=dword 0x00FF00FF
background=dword 0xFF00FF00
rule=byte 149

;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start image data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db "BM"
dd filesize, 0, pixeladdr

dibheader: dd pixeladdr - dibheader, width, height
dw 1, 32
dd 6 dup 0



pixeladdr: rept width{rept height\{dd background\}}
filesize: ; official end of pixel data in the file
scratchrow: rept width{dd background}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End image data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Macros ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
macro getoffset x,y,base,index{index = base+(y*width*bytesperpixel)+(x*bytesperpixel)}
macro paint x,y,value{store dword value at pixeladdr+(y*width*bytesperpixel)+(x*bytesperpixel)}
macro paintscratch x,v{store dword v at scratchrow+(x*bytesperpixel)}
macro pixelcolor x,y,value{load value dword from pixeladdr+(y*width*bytesperpixel)+(x*bytesperpixel)}

macro copyscratchtorow y
{
 local sroff, pixoff, i
 i=0
 while i < width
  load c dword from scratchrow+(i*bytesperpixel)
  store dword c at pixeladdr+(y*width*bytesperpixel)+(i*bytesperpixel)
  i=i+1
 end while
}

macro getnewpixelcolor x,y,val
{
 local xp,xm,xn,xpaddr,xnaddr,match,color
 xp=0
 xm=0
 xn=0
 match=0
 xpaddr=x-1
 xnaddr=x+1
 if x=0
  xpaddr=width
 else if x=width
  xnaddr=0
 end if
 pixelcolor xpaddr,y,xp
 if xp=foreground
  match=match+4
 end if
 pixelcolor x,y,xm
 if xm=foreground
  match=match+2
 end if
 pixelcolor xnaddr,y,xn
 if xn=foreground
  match=match+1
 end if
 color=background
 if 1=(rule and (1 shl match)) shr match
  color=foreground
 end if
 val=color
}

macro wolframcel
{
 macro scanrow y
 \{
  local i,match,newpix
  i=0
  match=dword 0
  newpix=0
  repeat width-1
   getnewpixelcolor %,y,match
   paintscratch %,match
   i=i+1
  end repeat
 \}
 local j
 j=0
 while j<height
  scanrow j
  j=j+1
  copyscratchtorow j
 end while
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Macros ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Et Cetera ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
paint width/2, 0, foreground ; paint a single seed pixel foreground

wolframcel



