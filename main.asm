.text               # section declaration

			        # we must export the entry point to the ELF linker or
    .global _start  # loader. They conventionally recognize _start as their
					# entry point. Use ld -e foo to override the default.

_start:

	call	mygetnum

	addq	%rax,%rax			# add it to itself. Now rax = rax*2!
	addq	$48, %rax			# add the ascii vals required!

	movq	$yournumis,%rbx		# put our message in b
	addq	$yournumislen,%rbx	# mov b to point to to the end
	subq	$offset,%rbx 		# and now back to the ?
	mov		%al,(%rbx)			# now change that point in memory (al -- just a byte!)

	movq    $yournumislen,%rdx	# third argument: message length
	movq    $yournumis,%rsi		# second argument: pointer to message to write
	movq    $1,%rdi				# first argument: file handle (stdout)
	movq    $1,%rax				# system call number (sys_write)
	syscall

						# and exit

	movq    $0,%rdi     # first argument: exit code
	movq    $60,%rax    # system call number (sys_exit)
	syscall

##
# function mygetnum
##
mygetnum:
	pushq	%rbx		# setup!
	pushq	%rcx
	pushq	%rdx
	subq	$2,%rsp		# alloc 1 byte

doask:

	movq    $askmsglen,%rdx	# third argument: message length
	movq    $askmsg,%rsi	# second argument: pointer to message to write
	movq    $1,%rdi			# first argument: file handle (stdout)
	movq    $1,%rax			# system call number (sys_write)
	syscall

	movq	$2,%rdx		# syscall arg 3: read two bytes (char+nl)
	movq	%rsp,%rsi	# syscall arg 2: read data into rsp
	movq	$0,%rdi		# syscall arg 1: file handle 0 (stdin)
	movq	$0,%rax		# syscall number 0 (sys_read)
	syscall

	mov		(%rsp),%rax	# store result in rax (we'll only us al though)
	and		$0xff,%rax	# remove the newline the user entered
	cmp		$48,%rax	# if its less than (ascii val of) 0 we have to bail out!
	jl		err
	sub		$48,%rax	# change ascii to num
	cmp		$4,%rax		# if its greater than (ascii val of) 4 we have to bail out!
	jg		err

	addq	$2,%rsp		# dealloc 1 byte
	popq	%rdx		# cleanup!
	popq	%rcx
	popq	%rbx
	ret					# done

err:
	movq    $errmsglen,%rdx	# third argument: message length
	movq    $errmsg,%rsi	# second argument: pointer to message to write
	movq    $1,%rdi     	# first argument: file handle (stdout)
	movq    $1,%rax     	# system call number (sys_write)
	syscall

	jmp 	doask			# ask again

.data                   	# section declaration

yournumis:
	.ascii    "Your awesome number is  !\n"  # An extra space for inserting our number
	yournumislen = . - yournumis             # length of our string

errmsg:
	.ascii    "Sorry, please enter a number less than 5, as we can't fit 5*2 in a single character!\n"  # our error message
	errmsglen = . - errmsg                   # length of our error message

askmsg:
	.ascii    "enter a number between 0 and 4\n"  # our q message
	askmsglen = . - askmsg                   # length of our q message

offset = 3
num = 4
