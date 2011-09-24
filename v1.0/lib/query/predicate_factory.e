-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Class to create correct type pf query predicate
--

class PREDICATE_FACTORY

inherit
	
	DB_CONSTANTS


feature
	
	make_from_descriptor (pdesc: PREDICATE_DESC): DB_QUERY_PREDICATE [ANY] is
			-- Make a query predicate from a predicate
			-- descriptor. The descriptor is created
			-- during parsing of query strings
		require
			valid_descriptor: pdesc /= Void
			has_pattributes: pdesc.feature_access.pattribute /= Void
		local
			predicate: DB_QUERY_PREDICATE [ANY]
			pattribute: PATTRIBUTE
			constant_value: ANY
			except: expanded EXCEPTIONS
		do
			predicate := pdesc.predicate
			if predicate /= Void then
				constant_value := predicate.value
			end
			-- Now based on type of the attribute create the predicate term
			pattribute := last_pattribute (pdesc.feature_access)
			
			inspect pattribute.eiffel_type_code
			when Eiffel_string then
				!DB_STRING_PREDICATE!predicate.make_empty
			when Eiffel_object then
				!DB_OBJECT_PREDICATE!predicate.make_empty
			when Eiffel_integer then
				!DB_INTEGER_PREDICATE!predicate.make_empty
			when Eiffel_char then
				!DB_CHARACTER_PREDICATE!predicate.make_empty
			when Eiffel_boolean then
				!DB_BOOLEAN_PREDICATE!predicate.make_empty
			else
				except.raise ("Unexpected type in query")
			end -- inspect
			
			predicate.set_attribute_access (pdesc.feature_access)
			predicate.set_operation (pdesc.operation)
			if constant_value /= Void then
				predicate.set_value (constant_value)
			end
			Result := predicate
		end

feature {NONE}
	
	
	last_pattribute (feature_access: FEATURE_ACCESS) : PATTRIBUTE is
			-- Get the last PATTRIBUTE in the path
		require
			feat_access_ok: feature_access /= Void
		local
			fa: FEATURE_ACCESS
		do
			from 
				fa := feature_access
			until
				fa.next = Void
			loop
				fa := fa.next
			end
			Result := fa.pattribute
		end

	
end -- PREDICATE_FACTORY
