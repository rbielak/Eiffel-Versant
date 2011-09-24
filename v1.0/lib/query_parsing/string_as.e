-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Node for string constants

class STRING_AS

inherit

	LIKEABLE_AS

	CONSTANT_AS
		redefine
			is_string
		end

creation

	make

feature

	value: STRING
			-- String value

feature -- Initilization

	make (lval: like value) is
		do
			value := lval
		ensure then
			value_exists: not (value = Void or else value.empty)
		end

	out: STRING is
		do
			Result := value.twin
			Result.prepend ("%"")
			Result.append ("%"")
		end

	is_string : BOOLEAN is True;

feature
		-- Building the interpreter

   build_byte_code (bc: BYTE_CODE_GENERATOR) is
      do
         bc.bcode.extend (STR_BC)
         bc.bcode.extend (bc.add_string_value (value))
      end

end
