-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class HELP_COMMAND

inherit

	PRIORITY_ARG_COMMAND

creation

	make

feature

	make (new_priority: INTEGER) is
		do 
			priority := new_priority
		end

	execute is
		do		
			io.putstring ("Usage :%N")
			io.putstring ("%T-d <database name1> [..<db_name2>..] %N")
			io.putstring ("%T-newclass <class name> [<parent name1> ..<parent name2>..] %N")
			io.putstring ("%T-dropclass <class name>%N")
			io.putstring ("%T-class <class name>%N")
			io.putstring ("%T-renameclass <old name> <new name>%N")
			io.putstring ("%T-newattr  <class name> <%
                          %attribute name> <type>%N")
			io.putstring ("%T-dropattr <class name> <attr name>%N")
			io.putstring ("%T-renameattr <class name> <old attribute name> <new attribute name>%N")
			io.putstring ("%T-redefine <class name> <attribute name> <%
                          %new type>%N")
			io.putstring ("%T-free : db free space%N")
			io.putstring ("%T-migrate <Loid> <destination dbase>%N")
			io.putstring ("%T-L <Loid>%N")
			io.putstring ("%TNO arguments brings up menu.%N")
		end


end --class

