# thebase2eccube

Converts THE BASE product CSV export output to EC-CUBE 4 CSV for import

THE BASE → EC-CUBE 4.x Product CSV list converter
Copyright 2020, Eido Inoue

An AWK program that will read CSV exported by THE BASE (an ASP hosted e-Commerce solution for Japan)
to EC-CUBE (an open source as well as hosted e-Commerce solution primarily used in Japan)

## NOTES:

- CSV INPUT FILE MUST BE UTF-8 ENCODING AND THE UNICODE CHARACTER SET WITH NO BYTE ORDER MARK.
  NOTE THAT THE DEFAULT OUTPUT FORMAT FOR EXPORTED JAPANESE CSV FILES IS USUALLY SHIFT-JIS,
  SO YOU WILL NEED TO PRE-CONVERT THE FILE USING ICONV.
- THE DEFAULT OUTPUT ENCODING IS UTF-8 WITH NO BOM (BYTE ORDER MARK). JAPANESE SAAS
  SYSTEMS, EVEN ONES THAT WORK IN UNICODE NORMALLY, OFTEN EXPECT SHIFT-JIS FOR CSV IMPORT
- CSV FILES USUALLY HAVE A CRLF FOR THE NEWLINE, EVEN ON LINUX SYSTEMS. IF YOU ARE RUNNING
  AWK/GAWK ON A WINDOWS SYSTEM, YOU MAY NEED TO SET THE SPECIAL BINMODE VARIABLE TO "3" ON
  THE COMMAND LINE TO KEEP WINDOWS FROM ATTEMPTING TO SILENTLY CONVERT THE END-OF-LINES CHARS.

## PREREQUISITES:

- You will need wget on the system to pull the files. You can change this in the variables below
  to curl or something else if you prefer
- This script uses GNU specific AWK extensions. It probably won't won't on POSIX or lesser AWK
- The script assumes that THE BASE stores all images in the cloud in the same place. Tweak the
  variable below if the images are elsewhere.
- The EC-CUBE mapping for 公開ステータス mapping should be "1" for 公開 (public), in order to match
  THE BASE's idea of a publicly listed item. This is not a problem if you're using the default/demo
  mappings for EC-CUBE (ex. the demo "GELATO" site)

## LIMITATIONS:
 
- AWK and even GAWK cannot process files that are both separated by newlines and have newlines
  within fields. You will need to use a separate utility to convert or edit (valid) CSV files
  that have embedded CR or LF or NL in the fields.
