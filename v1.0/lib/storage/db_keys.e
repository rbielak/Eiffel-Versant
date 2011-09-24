-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DB_KEYS

inherit

	ARRAY[ANY]
		rename
			make_from_array as basic_make_from_array
		redefine
			is_equal
		end

	HASHABLE
		undefine
			is_equal, copy, consistent, setup
		end

creation

	make_from_array

feature

	make_from_array (a: ARRAY [ANY]) is
		do
			basic_make_from_array (a)
			compute_string_form
		end

	compute_string_form is
		local
			i: INTEGER
			s: STRING
			o: POBJECT
			it: ANY
		do
			from
				i := 1
				!!s.make (0)
			until
				i > count
			loop
				it := item (i)
				if it /= void then
					o ?= it
					if o /= void then
						-- For object others than string, `out' is not
						-- constant, since objects move in memory.
						s.append (o.object_id.out)
					else
						s.append (it.out)
					end
				else
					s.append ("00000000")
				end
				i := i + 1
			end
			string_form := s
		end

	is_equal (other: like Current): BOOLEAN is
		do
			Result := string_form.is_equal (other.string_form)
		end

	string_form: STRING

	hash_code: INTEGER is
			do
				Result := string_form.hash_code
			end

end
