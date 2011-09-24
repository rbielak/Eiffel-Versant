#
VERSANT_REL = 5_0_8
CC = cl
RM = del
CFLAGS = -Ox -c -nologo -DWINISS -DWIN32 -I. -I$(ISS_BASE)\spec\$(PLATFORM)\include -I$(VERSANT_ROOT)\$(VERSANT_REL)\NT\h


SRCS = ..\..\_versant.c ..\..\_vstr.c ..\..\_versant_pointer.c ..\..\_db_list.c \
	 ..\..\_eiffel.c ..\..\_eif_vers.c ..\..\_match.c ..\..\_stamp_ops.c \
	 ..\..\_schema_ext.c ..\..\_peif_id_ops.c 
OBJS = _versant.obj _vstr.obj _versant_pointer.obj _db_list.obj _eiffel.obj \
	_eif_vers.obj _match.obj _stamp_ops.obj _schema_ext.obj _peif_id_ops.obj 

all:
	nmake bench
	nmake final

bench:
	$(CC) -c $(CFLAGS) -DWORKBENCH $(SRCS)
	lib/out:versant_bench.lib $(OBJS)

final:
	$(CC) -c $(CFLAGS) $(SRCS)
	lib/out:versant_final.lib $(OBJS)

clean:
	$(RM) *.obj *.lib

