-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Objects of this class hold access rights to persistent roots
--

class ROOT_RIGHTS

inherit
	
	POBJECT
		redefine
			make_transient
		end

creation
	
	make

feature
	
	root_name: STRING
			-- Name of the root to which these rights
			-- apply (could be a pattern with wild-cards)
	
	set_root_name (nroot_name : STRING) is
		require
			name_ok: nroot_name /= Void
		do
			root_name := nroot_name.twin
		end


	read: BOOLEAN;
			-- Allowed to read an object
	
	set_read (nread: BOOLEAN) is
		do
			read := nread
			make_stamp
		end

	write: BOOLEAN;
			-- Allowed to write an object

	set_write (nwrite: BOOLEAN) is
		do
			write := nwrite
			make_stamp
		end
	
	add: BOOLEAN;
			-- Allowed to add item to a ROOT
	
	set_add (nadd: BOOLEAN) is
		do
			add := nadd
			make_stamp
		end

	delete: BOOLEAN;
			-- Allowed to delete an item from a root
	
	set_delete (ndelete : BOOLEAN) is
		do
			delete := ndelete
			make_stamp
		end
	
	display: BOOLEAN
			-- allow to display this object in the UI
	
	set_display (ndisplay : BOOLEAN) is
		do
			display := ndisplay
		end
	
	priority : INTEGER
			-- prioroty determines the order in which
			-- rights will be matched. Smaller priority
			-- will be considered first
	
	set_priority (npriority: INTEGER) is
		do
			priority := npriority
		end
	
	
feature {ROOT_RIGHTS_SET}	

	root_rights_stamp: INTEGER


feature --G{DISPATCHER}
	
	
	make (new_root_name: STRING; nread, nwrite, nadd, ndelete, ndisplay: BOOLEAN; npriority: INTEGER) is
		require
			valid_root_name: new_root_name /= Void
		do
			read := nread;
			write := nwrite;
			add := nadd;
			delete := ndelete;
			priority := npriority;
			display := ndisplay;
			make_stamp
			root_name := clone (new_root_name);
		end

	

	make_stamp is
			-- Conver boolean flags into a "rights_stamp".
			-- Individual bits represent the corresponding rights:
			-- bit 0:  read
			-- bit 1:  write
			-- bit 2:  add
			-- bit 3:  delete
		do
			root_rights_stamp := 0;
			if read then
				root_rights_stamp := root_rights_stamp + 1
			end
			if write then
				root_rights_stamp := root_rights_stamp + 2
			end
			if add then
				root_rights_stamp := root_rights_stamp + 4
			end
			if delete then
				root_rights_stamp := root_rights_stamp + 8
			end
			if display then
				root_rights_stamp := root_rights_stamp + 16
			end
		end
	
	make_transient is
		do
			make_stamp
		end


invariant

end -- ROOT_RIGHTS
