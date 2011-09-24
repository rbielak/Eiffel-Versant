-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SINGLE_TUPLE_EXTRACTOR

inherit

	ATTRIBUTE_EXTRACTOR
		export
			{NONE} build_extractors, build_paths
		end

creation

	make_for_class 

feature

	make_for_class (class_name: STRING; attribute_names: ARRAY [STRING]) is
		require
			class_name_ok: class_name /= Void
			attributes_ok: attribute_names /= Void 
			attributes_there: attribute_names.count > 0
		do
			build_paths (attribute_names)
			build_extractors (class_name, attribute_names)
			!!last_tuple.make (1, attribute_names.count)
		end

end
