-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class PERSON

inherit

	NAMED_MANAGEABLE

creation
	make

feature


	age : INTEGER;
	
	set_age (n : INTEGER) is
		do
			age := n;
		end;

	spouse : like Current
	
	married : BOOLEAN;

	children : CONCURRENT_PLIST [PERSON];
	
	numbers : PLIST_DOUBLE;
	
	relatives : PARRAY [PERSON];
	
--	friends : PLIST_OBJ[PERSON];
	friends : SEGMENTED_PLIST[PERSON];
	
	names : PLIST_STRING;
	
	best_friend : PERSON
	
	set_best_friend (bfriend : PERSON) is
		require
			bfriend /= Void
			
		do
			best_friend := bfriend
		end

	junk_attribute : INTEGER;

	password : STRING;

	make (new_name : STRING; new_age : INTEGER) is
		require
			new_name /= Void;
		local
			i : INTEGER
		do
			name := clone (new_name);
			age := new_age;
			!!relatives.make (1,2);
			!!names.make;
			!!friends.make ("SEGMENTED_PLIST[PERSON]", 3);
			!!flags.make (1,10);
			from i := 1
			until i > flags.count 
			loop
				flags.put (True, i);
				i := i + 1
			end
		--	password := "";
		end
	
	fiddle_flags is
		do
			if flags = Void then
				!!flags.make (1,10);				
			end
			flags.put (False, 3);
		end
	
	set_password (new_pass : STRING) is
		do
			password := clone (new_pass);
		end;
	
	set_spouse (sp : like Current) is
		require
			(sp /= Void)
		do
			spouse := sp;
			if sp.spouse /= Current then
				sp.set_spouse (Current);
			end;
			married := True
		end;
	
	
	set_lucky_numbers (n1, n2, n3 : DOUBLE) is
		do
			if numbers = Void then
				!!numbers.make;
			end;
			numbers.append (n1);
			numbers.append (n2);
			numbers.append (n3);
		end

	add_child (child : PERSON; index : INTEGER) is
		require
			child /= Void
		local
			last : INTEGER;
		do
			if children = Void then
				!!children.make ("concurrent_plist[person]");
			end;
			children.insert_i_th(child, index);
		ensure
			children /= Void and then children.has (child);
		end; -- add_child

	add_children (cs: ARRAY [PERSON]) is
		do
			if children = Void then
				!!children.make ("concurrent_plist[person]")
			end
			children.append_array (cs)
		end

	divorce is 
		do
			Married := False;
			spouse := Void;
		end;
	
	flags : PARRAY_BOOLEAN
	
	display, dump is
		local
			i : INTEGER;
		do
			io.putstring ("--> From db:");
			io.putstring (pobject_class.db.name);
			io.new_line;
			io.putstring ("Name: ");
			io.putstring (name);
			io.new_line;
			io.putstring ("Age : ");
			io.putint (age);
			io.new_line;
			if spouse /= Void then
				io.putstring ("Married to ");
				io.putstring (spouse.name);
			else
				io.putstring ("Not married.");
			end;
			io.new_line;
			if best_friend /= Void then
				io.putstring ("Best friend: ")
				io.putstring (best_friend.name)
			end
			io.new_line;
			if names.count > 0 then
				io.putstring ("Other names: ");
				from i := 1
				until i > names.count
				loop
					io.putstring (names.i_th(i));
					io.putstring (", ");
					i := i + 1
				end;
				io.new_line;
			end;
			if numbers /= Void then
				io.putstring ("Lucky numbers: ");
				from i := 1
				until i > numbers.count
				loop
					io.putdouble (numbers.i_th(i));
					io.putstring (", ");
					i := i + 1
				end;
				io.new_line;
			end;
			if password = Void then
				io.putstring ("Password is Void. %N");
			else
				io.putstring ("Password: <");
				io.putstring (password);
				io.putstring (">%N");
			end;
			if children /= Void then
				io.putstring ("...Has ");
				io.putint(children.count);
				io.putstring (" children...%N");
				from i := 1
				until i > children.count
				loop
					io.putstring (children.i_th(i).name);
					io.putstring (", ");
					i := i + 1
				end;
				io.new_line;
			end;
			if friends /= Void then
				io.putstring ("...Has ");
				io.putint (friends.count);
				io.putstring (" friends...%N");
			end;
			io.putstring ("%N------------------------%N");
		end;

	db_name : STRING is
		do
			Result := pobject_class.db.name;
		end
	
	write_lock_twice is
			-- Just to see what versant does
		do
			io.putstring ("Locked you once....%N")
			db_interface.lock_object (pobject_id, db_interface.db_write_lock);
			io.putstring ("Locked you twice....%N")
			db_interface.lock_object (pobject_id, db_interface.db_read_lock); 
			io.putstring ("Little.......%N")			
		end

invariant

end -- PERSON
