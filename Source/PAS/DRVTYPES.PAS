{ --------------------------------------------------------------------------- }
{ DRVTYPES.PAS  Drive type detection unit.			 Version 1.30 }
{                                                                             }
{ *** PUBLIC DOMAIN ***                                                       }
{ *** NO WARRANTIES PROVIDED AND AS-IS BASIS IS ASSUMED ***                   }
{                                                                             }
{ Initially written and placed in public domain by Mr. Byte.                  }
{ Network drive detection fix, Stacker , DoubleDisk and                       }
{  Bernoully drive detection by Bobby Z.                                      }
{ RAM drive detection by Janis Smits.                                         }
{ --------------------------------------------------------------------------- }
{ History:

	mid November, 1994  -  initially released
         29 November, 1994  -  fixed network drive detection and added 
			       Stacker drive detection
         10 December, 1994  -  added Janis's RAM drive detection method
	 16 January,  1995  -  added Vertisoft DoubleDisk 2.6+ drive detection
	 31 January,  1995  -  added Bernoully drive detection
         24 August,   1995  -  v1.21: fixed a bug with CD-ROM drive detection
	 04 December, 1995  -  v1.30: changed Stacker detection, now detects
			       all versions of Stacker and is more convenient;
			       fixed Bernoulli drive detection	
}

(**** General notes: ****

  This code can be easily ported to C/C++, because most of it is written in
  inline assembler. Just convert @@-style labels to __ and add "asm"s where
  needed. Note, that the call to checkStacker cannot be made in C/C++ the way
  it is done here (at least in Borland C++), you should do it like this:

  unsigned char getDriveType( unsigned char Drive )
  {
  register unsigned char temp;
  ...
  mov	temp,Drive		// passing the parameter
    }
  checkStacker(temp);
asm {
  ...
  }


 **** end of General notes ****)

{$S-,R-,I-,X+}
{ disable stack, I/O and range checking, enable extended syntax }

unit DrvTypes;
{ drive types }

interface

const
  dtError      = $00; { Invalid drive, letter not assigned }
  dtFixed      = $01; { Fixed drive }
  dtRemovable  = $02; { Removeable (floppy, etc.) drive }
  dtRemote     = $03; { Remote (network) drive }
  dtCDROM      = $04; { MSCDEX V2.00+ driven CD-ROM drive }
  dtDblSpace   = $05; { DoubleSpace compressed drive }
  dtSUBST      = $06; { SUBST'ed drive }
  dtStacker    = $07; { Stacker compressed drive }
  dtRAMDrive   = $08; { RAM drive }
  dtDublDisk   = $09; { Vertisoft DoubleDisk 2.6+ compressed drive }
  dtBernoully  = $0A; { IOmega Bernoully drive }

function getDriveType(Drive : Byte) : Byte;

function countValidDrives : Byte;

implementation

function checkStacker( Drive : Byte ) : Boolean; assembler;
{ returns True if Drive is Stacker compressed volume, False otherwise. }

var
	StackerDriver : Pointer;
asm
	mov	word ptr StackerDriver,0
	mov	word ptr StackerDriver[2],0
	mov	ax,4404h
	mov	bl,Drive
	mov	cx,4
	lea	dx,StackerDriver
	push	ds
	push	ss
	pop	ds
	int	21h		{ get Stacker driver address }
	pop	ds
	mov	ax,word ptr StackerDriver
	or	ax,word ptr StackerDriver[2]
	jz	@@Q		{ address was set? }
	mov	al,1
@@Q:
end; { checkStacker }

function getDriveType; assembler;
{ Detects the type for a specified drive. Drive is a drive number to detect the
  type for (0=detect current (default) drive, 1=A, 2=B, 3=C...)

  Returns: One of the dtXXX-constants.

  Note: Function will work under DOS version 3.1 or later
        Also should work under DPMI and Windows.
}

asm
	cmp	Drive,0
	jne	@@1
	mov	ah,19h    { get active drive number in al }
	int	21h
	mov	Drive,al
	inc	Drive
@@1:
	mov	ax,1500h  { check for CD-ROM v2.00+ }
	sub	bx,bx
	int	2Fh
	or	bx,bx
	jz	@@2
	mov	ax,150Bh
	sub	ch,ch
	mov	cl,Drive
	dec	cl	  { !!! 1.21 - drive mapping is 0-based }
	int	2Fh
	cmp	bx,0ADADh
	jne	@@2
	or	ax,ax
	jz	@@2
	mov	bl,dtCDROM
	jmp	@@7
@@2:
	mov	ax,4409h { check for SUBST'ed drive }
	mov	bl,Drive
	int	21h
	jc	@s
	test	dh,80h
	jz	@s
	mov	bl,dtSUBST
	jmp	@@7
@s:
	mov	ax,4A11h  { check for DoubleSpace drive }
	mov	bx,1
	mov	dl,Drive
	dec	dl
	int	2Fh
	or	ax,ax     { is DoubleSpace loaded? }
	jnz	@@3
	cmp	dl,bl     { if a host drive equal to compressed, then get out... }
	je	@@3
	test	bl,80h    { bit 7=1: DL=compressed,BL=host
                                 =0: DL=host,BL=compressed }
	jz	@@3       { so avoid host drives, assume host=fixed :) }
	inc	dl
	cmp	Drive,dl
	jne	@@3
	mov	bl,dtDblSpace
	jmp	@@7
@@3:
	mov	ax,4409h     { check for remote drive }
	mov	bl,Drive
	int	21h
	jc	@@5
	and	dh,10h
	jz	@@4
	mov	bl,dtRemote
	jmp	@@7
@@4:
	mov	al,Drive     { check for Stacker volume }
@@goStac:
	push	ax
	call	checkStacker
	test	al,al
	jz	@@8
	mov	bl,dtStacker
	jmp	@@7
@@8:
        mov     ax,4408h     { check for fixed (hard) drive }
        mov     bl,Drive
        int     21h
        jc      @@5
	test	al,al	     { 0 means removable media }
	jz	@@check_Bernoulli
	push	ds           { check for RAM drive }
	push	ss
	pop	ds
        mov     si,sp
        sub     sp,28h	     { allocate 28h bytes in stack }
        mov     dx,sp
        mov     ax,440Dh     { generic IOCTL }
        mov     cx,860h      { get device parameters }
        int     21h          { RAMDrive and VDISK don't support this command }
	jc	@@cleanup
	pushf
	mov	di,dx
	cmp	byte ptr ds:[di+6],0F8h	{ DoubleDisk returns 0F8h in media type}
	jz	@@dubldsk		{ field of BPB if drive in question is }
					{ compressed }
	popf				
	jmp	@@cleanup
@@dubldsk:
	popf
	mov	bl,dtDublDisk
	mov	sp,si
	pop	ds
	jmp	@@7
@@cleanup:
        mov     sp,si
        pop     ds
        mov     bl,dtRAMDrive
        jc      @@7
	jmp	@@fixed			{ if we get here - it's fixed drive }
@@check_Bernoulli:
	cmp	Drive,2
	jbe	@@6			{ drives A: and B: are floppies }
	push	ds
	mov	ah,1Ch			{ this function works _really_ slowly }
	mov	dl,Drive		{ get media descriptor pointer }
	int	21h
	cmp	byte ptr ds:[bx],0FDh	{ 360K diskette? }
	pop	ds
	jnz	@@6			{ just a removable drive }
	push	ds
	mov	ah,32h			{ get BPB pointer }
	mov	dl,Drive
	int	21h
	cmp	byte ptr ds:[bx+0Bh],2	{ Sectors per FAT is more than 2 for }
	pop	ds			{ Bernoully drives }
	jz	@@6
	mov	bl,dtBernoully
	jmp	@@7
@@fixed:
        mov     bl,dtFixed
        jmp     @@7
@@5:
	sub	bl,bl        { mov bl,dtError cuz dtError=0 }
	jmp	@@7
@@6:
	mov	bl,dtRemovable   { else - removeable media }
@@7:
	mov	al,bl
end; { getDriveType }

function countValidDrives;
{ - returns number of assigned letters in system }
 var i : Byte;
     C : Byte;
 begin
  C := 0;
  for i := 1 to 26 do
   if GetDriveType(i) <> dtError then
    Inc(C);
  countValidDrives := C;
 end; { countValidDrives }

end.
