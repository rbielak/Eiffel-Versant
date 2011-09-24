-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class FEATURE_CALL_AS

inherit

	FEATURE_AS

creation

	make

feature -- Attribute
	-- expr1.expr2.expr3

	expressions: ARRAY [ACCESSIBLE_FEATURE]

feature -- Initialization

	make (lexpressions: like expressions) is
		do
			expressions := lexpressions
		end

	out: STRING is
		local
			count,i: INTEGER
		do
			from
				i := 1
				count := expressions.count
				!!Result.make (0)
			until
				i > count
			loop
				Result.append (expressions.item (i).out)
				if i < count then
					Result.append (".")
				end
				i := i + 1
			end
		end

	build_feature_access: FEATURE_ACCESS is
		local
			i: INTEGER
			feat_access, last: FEATURE_ACCESS
		do
			from
				i := 1
			until
				i > expressions.count
			loop
				feat_access := expressions.item (i).build_feature_access
				if last = Void then
					Result := feat_access
					last := feat_access
				else
					last.set_next (feat_access)
					last := feat_access
				end
				i := i + 1
			end
		end

feature
		-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		local
			i: INTEGER
		do
			bc.bcode.extend (FEATCALL_BC)
			bc.bcode.extend (expressions.count)
			from
				i := 1
			until
				i > expressions.count
			loop
				expressions.item (i).build_byte_code (bc)
				i := i + 1
			end
		end

end
