# thebase2eccube

Converts THE BASE product CSV export output to EC-CUBE 4 CSV for import

THE BASE → EC-CUBE 4.x Product CSV list converter
Copyright 2020, Eido Inoue

An AWK program that will read CSV exported by THE BASE (an ASP hosted e-Commerce solution for Japan)
to EC-CUBE (an open source as well as hosted e-Commerce solution primarily used in Japan)

## NOTES:

- CSV input file must be utf-8 encoding and the unicode character set with no byte order mark.
  Note that the default output format for exported japanese CSV files is usually shift-jis,
  So you will need to pre-convert the file using iconv.
- The default output encoding is utf-8 with no bom (byte order mark). Japanese ASP/SAAS
  systems, even ones that work in Unicode normally, often expect shift-jis for CSV import
- CSV files usually have a crlf for the newline, even on linux systems. If you are running
  AWK/GAWK on a Windows system, you may need to set the special BINMODE variable to "3" on
  The command line to keep windows from attempting to silently convert the end-of-lines chars.

## PREREQUISITES:

- You will need wget on the system to pull the files. You can change this in the variables below
  to curl or something else if you prefer
- This script uses GNU specific AWK extensions. It probably won't won't on POSIX or lesser AWK
- The script assumes that THE BASE stores all images in the cloud in the same place. Tweak the
  global AWK variable if the images are elsewhere.
- The EC-CUBE mapping for 公開ステータス mapping should be "1" for 公開 (public), in order to match
  THE BASE's idea of a publicly listed item. This is not a problem if you're using the default/demo
  mappings for EC-CUBE (ex. the demo "GELATO" site)

## LIMITATIONS:
 
- AWK and even GAWK cannot process files that are both separated by newlines and have newlines
  within fields. You will need to use a separate utility to convert or edit (valid) CSV files
  that have embedded CR or LF or NL in the fields.
