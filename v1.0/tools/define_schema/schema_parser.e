-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- -- Parse the schema definifiton and create list of classes.  --

class SCHEMA_PARSER

creation
	
	make

feature
	
	
	classes : INDEXED_LIST [SCHEMA_CLASS, STRING]
			-- classes found in this schema
	
	parse is
			-- Parse the schema file
		require
			schema_file.is_open_read
		local
			current_line : WORD_STRING;
			keyword : STRING;
			one_class : SCHEMA_CLASS
		do
			!!current_line.make (80)
			current_line.set_delimiters (" %T()");;
			classes.clear_all
			from schema_file.readline
			until schema_file.end_of_file
			loop
				if schema_file.laststring.count > 0 then
					current_line.set_word_string (schema_file.laststring);
					keyword := current_line.remove_word;
					keyword.to_upper;
					if equal (keyword, "CLASS") then
						new_class (current_line);
					elseif equal (keyword, "INHERIT") then
						new_parent (current_line)
					elseif equal (keyword, "RENAME") then
						new_rename (current_line)
					elseif equal (keyword, "ATTRIBUTE") then
						new_attribute (current_line)
					elseif equal (keyword, "KEY_ATTRIBUTE") then
						new_key_attribute (current_line)
					elseif equal (keyword, "END") then
						end_of_class
				    elseif equal (keyword, "--") then	
					        -- Comment in file
				    else
					    io.putstring ("*****Invalid keyword***-->");
					    io.putstring ("  Keyword=<");
						io.putstring (keyword);
						io.putstring (">%N");
						io.putstring ("  Line=  ");
						io.putstring (current_line);
						io.new_line;
						except.raise ("Bad input line");
					end;
				end
				schema_file.readline
			end -- loop
			-- Check that the last class was complete
			if (current_class /= Void) then
				if not classes.has_key (current_class.name) then
					io.putstring ("ERROR: missing END in last class....%N");
					except.raise ("END missing");
				end;
			end
		end;
	
	
	schema_file : PLAIN_TEXT_FILE;
	
	dump_list is
		do
			from classes.start
			until classes.off
			loop
				classes.item.dump
				classes.forth
			end
		end
	

feature {NONE}	
	
	current_class : SCHEMA_CLASS
			-- class we are working on
	
	new_class (line : WORD_STRING) is
			-- new class
		require
			current_class = Void
		local
			class_name : STRING;
		do
			class_name := line.remove_word;
			if class_name = Void then
				report_error_and_die (line, "class parse error");
			end
			class_name.to_lower;
			-- Check to make sure the class is not a duplicate
			if classes.has_key (class_name) then
				io.putstring ("*** ERROR -> duplicate class in schema:  <");
				io.putstring (class_name);
				io.putstring ("> Aborting...%N");
				except.raise ("Duplicate class");
			end
			if current_class /= Void then
				io.putstring ("*** ERROR -> missing END in class: <"); 
				io.putstring (current_class.name);
				io.putstring (class_name);
				io.putstring ("> Aborting...%N");
				except.raise ("missing end");
			end
			io.putstring ("--> Parsing class: ");
			io.putstring (class_name);
			io.new_line;
			!!current_class.make (class_name);
		end
	
	new_parent (line: WORD_STRING) is
		require
			current_class /= Void
		local
			parent_name : STRING
		do
			parent_name := line.remove_word;
			if parent_name = Void then
				report_error_and_die (line, "inherit parse error");
			end
			parent_name.to_lower;
			current_class.parents.extend (parent_name);
		end
	
	end_of_class is
		require
			current_class /= Void
		do
			classes.put_key (current_class, current_class.name);
			current_class := Void;
		end
	
	
	new_attribute (line : WORD_STRING) is
		require
			current_class /= Void
		local
			attr : SCHEMA_ATTR;
			attr_name : STRING;
			attr_type : STRING;
--			attr_man_name: STRING
			is_a_list : BOOLEAN;
		do
			attr_name := line.remove_word;
			attr_type := line.remove_word;
			if (attr_type = Void) or (attr_name = Void) then
				report_error_and_die (line, "attribute parse error");
			end
			attr_type.to_lower;
			if attr_type.is_equal ("list") then
				is_a_list := True;
				attr_type := line.remove_word
			end
			-- Check for "weak" links
--			attr_man_name := line.remove_word
--			if (attr_man_name /= Void) then
--				attr_man_name.to_lower
--				if attr_man_name.is_equal ("from") then
--					attr_man_name := line.remove_word
--				else
--					attr_man_name := Void
--				end
--				if attr_man_name = Void then
--					report_error_and_die (line, "attribute parse error");
--				end
--				!!attr.make_as_key_link (attr_name, attr_type, attr_man_name, 
--							  is_a_list)
--			else
			!!attr.make (attr_name, attr_type, is_a_list);
--			end
			current_class.attributes.extend (attr)
		end
	
	new_key_attribute (line: WORD_STRING) is
		require
			current_class /= Void
		local
			attr : SCHEMA_ATTR;
			attr_name : STRING;
			attr_type : STRING;
			attr_aux_info: STRING
		do
			attr_name := line.remove_word
			attr_type := line.remove_word
			if (attr_type = Void) or (attr_name = Void) then
				report_error_and_die (line, "attribute parse error");
			end
			attr_type.to_lower
			if attr_type.is_equal ("list") then
				report_error_and_die (line, "list not allowed in KEY_ATTRIBUTE")
			end
			attr_aux_info := line.remove_word
			if attr_aux_info /= Void then
				attr_aux_info.to_lower
			end
			if attr_aux_info = Void then
				attr_aux_info := attr_name
			elseif attr_aux_info.is_equal ("path") then
				attr_aux_info := line.remove_word
			else
				report_error_and_die (line, "syntax error in KEY_ATTRIBUTE")
			end
			!!attr.make_as_key_link (attr_name, attr_type, attr_aux_info)
			current_class.attributes.extend (attr)
		end
	
	new_rename (line : WORD_STRING) is
		require
			current_class /= Void
		local
			new_nm, old_nm : STRING;
			rename_desc : SCHEMA_RENAME;
		do
			old_nm := line.remove_word;
			new_nm := line.remove_word;
			if (old_nm = Void) or (new_nm = Void) then
				report_error_and_die (line, "rename parse error");
			end
			!!rename_desc.make (new_nm, old_nm);
			current_class.renames.extend (rename_desc);
		end

	make (f : PLAIN_TEXT_FILE) is
		require
			f /= Void and then f.is_open_read
		do
			schema_file := f;
			!!classes.make (300);
		end
	
	except : expanded EXCEPTIONS
	
	report_error_and_die (line : STRING; msg : STRING) is
		require
			msg /= Void
		do
			if line /= Void then
				io.putstring ("*****ERROR: died in line: <");
				io.putstring (line);
				io.putstring (">");
			end
			except.raise (msg);
		end

invariant

end -- SCHEMA_PARSER
