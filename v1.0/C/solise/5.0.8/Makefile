#
SHELL = /bin/sh
AR = ar rc
CC = gcc
MAKE = make
MV = mv
RM = rm -f
CFLAGS = -g -I. -I$(EIFFEL4)/bench/spec/solaris/include -I$(VERSANT_ROOT)/$(VERSANT_REL)/sun4/h -DISE


SRCS = ../../_versant.c ../../_vstr.c ../../_versant_pointer.c ../../_db_list.c \
	 ../../_eiffel.c ../../_eif_vers.c ../../_match.c ../../_stamp_ops.c \
	 ../../_schema_ext.c ../../_peif_id_ops.c 
OBJS = _versant.o _vstr.o _versant_pointer.o _db_list.o _eiffel.o \
	_eif_vers.o _match.o _stamp_ops.o _schema_ext.o _peif_id_ops.o 

all:
	make bench
	make final

bench:
	$(CC) -c $(CFLAGS) -DWORKBENCH $(SRCS)
	$(AR) versant_bench.a $(OBJS)

final:
	$(CC) -c $(CFLAGS) -O3 $(SRCS)
	$(AR) versant_final.a $(OBJS)

clean:
	$(RM) *.o *~ core *.a

