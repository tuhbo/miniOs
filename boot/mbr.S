;------------------------------------------------------------
%include "boot.inc"
SECTION MBR vstart=0x7c00         
   mov ax,cs      
   mov ds,ax
   mov es,ax
   mov ss,ax
   mov fs,ax
   mov sp,0x7c00
   mov ax,0xb800
   mov gs,ax

;------------------------------------------------------------
;INT 0x10    功能号:0x13    功能描述:打印字符串
;------------------------------------------------------------
;输入:
;AH 子功能号=13H
;BH = 页码
;BL = 属性(若AL=00H或01H)
;CX＝字符串长度
;(DH、DL)＝坐标(行、列)
;ES:BP＝字符串地址 
;AL＝显示输出方式
;   0——字符串中只含显示字符，其显示属性在BL中。显示后，光标位置不变
;   1——字符串中只含显示字符，其显示属性在BL中。显示后，光标位置改变
;   2——字符串中含显示字符和显示属性。显示后，光标位置不变
;   3——字符串中含显示字符和显示属性。显示后，光标位置改变
;无返回值
   mov     ax, 0600h
   mov     bx, 0700h
   mov     cx, 0                   
   mov     dx, 184fh		   
   int     10h                     ; int 10h

   mov byte [gs:0x00],'h'
   mov byte [gs:0x01],0xA4

   mov byte [gs:0x02],'e'
   mov byte [gs:0x03],0xA4

   mov byte [gs:0x04],'l'
   mov byte [gs:0x05],0xA4	   

   mov byte [gs:0x06],'l'
   mov byte [gs:0x07],0xA4

   mov byte [gs:0x08],'o'
   mov byte [gs:0x09],0xA4
	 
   mov eax,LOADER_START_SECTOR	 
   mov bx,LOADER_BASE_ADDR       
   mov cx,4			 
   call rd_disk_m_16		 
  
   jmp LOADER_BASE_ADDR + 0x300
       
;-------------------------------------------------------------------------------
;功能:读取硬盘n个扇区
rd_disk_m_16:	   
;-------------------------------------------------------------------------------
				       ; eax=LBA扇区号
				       ; ebx=将数据写入的内存地址
				       ; ecx=读入的扇区数
      mov esi,eax	  
      mov di,cx		  
;读取硬盘:
;第1步:设置要读取的扇区数
      mov dx,0x1f2
      mov al,cl
      out dx,al            ;

      mov eax,esi	   

;第2步:将LBA地址存入0x1f3 ~ 0x1f6
      mov dx,0x1f3                       
      out dx,al                          


      mov cl,8
      shr eax,cl
      mov dx,0x1f4
      out dx,al


      shr eax,cl
      mov dx,0x1f5
      out dx,al

      shr eax,cl
      and al,0x0f	   
      or al,0xe0	   
      mov dx,0x1f6
      out dx,al

;第3步:向0x1f7端口写入读命令,0x20
      mov dx,0x1f7
      mov al,0x20                        
      out dx,al

;第4步:检查硬盘状态
  .not_ready:
      nop
      in al,dx
      and al,0x88	   
      cmp al,0x08
      jnz .not_ready	   

;第5步:从0x1f0端口读数据
      mov ax, di
      mov dx, 256
      mul dx
      mov cx, ax	   

      mov dx, 0x1f0
  .go_on_read:
      in ax,dx
      mov [bx],ax
      add bx,2		  
      loop .go_on_read
      ret

   times 510-($-$$) db 0
   db 0x55,0xaa
