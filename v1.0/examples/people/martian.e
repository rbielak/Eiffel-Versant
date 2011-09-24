-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class MARTIAN

inherit
	
	PERSON
		rename
			make as person_make
		end

creation
	
	make

feature

	make (nm: STRING; a: INTEGER) is
		do
			person_make (nm, a)
			!!wives.make ("SEGMENTED_PLIST [MARTIAN]", 500)
			!!offsprings.make ("PLIST[MARTIAN]")
		end
	
	home_canal: INTEGER

	wives: SEGMENTED_PLIST [MARTIAN]

	offsprings: PLIST [MARTIAN]

end -- MARTIAN
