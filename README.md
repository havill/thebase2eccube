# thebase2eccube

Converts THE BASE product CSV export output to EC-CUBE 4 CSV for import

THE BASE → EC-CUBE 4.x Product CSV list converter
Copyright 2020, Eido Inoue

An AWK program that will read CSV exported by THE BASE (an ASP hosted e-Commerce solution for Japan)
to EC-CUBE (an open source as well as hosted e-Commerce solution primarily used in Japan)

## NOTES:

- CSV input file must be UTF-8 encoding and the unicode character set with no byte order mark.
  Note that the default output format for exported japanese CSV files is usually shift-jis,
  So you will need to pre-convert the file using iconv.
- The default output encoding is UTF-8 with no BOM (byte order mark U+FEFF). Japanese ASP/SAAS
  systems, even ones that work in Unicode normally, often expect Shift-JIS for CSV import
- CSV files usually have a CRLF for the newline, even on Linux systems. If you are running
  AWK/GAWK on a Windows system, you may need to set the special BINMODE variable to "3" on
  The command line to keep windows from attempting to silently convert the end-of-lines chars.

## PREREQUISITES:

- This script uses GNU specific AWK extensions. It probably won't won't on POSIX or other AWKs
- The script assumes that THE BASE stores all images in the cloud in the same place. Tweak the
  global AWK variable if the images are elsewhere.
- The EC-CUBE mapping for 公開ステータス mapping should be "1" for 公開 (public), in order to match
  THE BASE's idea of a publicly listed item. This is not a problem if you're using the default/demo
  mappings for EC-CUBE (ex. EC-CUBE 4.x's demo "GELATO" site)
- You will need a Linux environment with standard development tools (GNU make, gcc, iconv, wget, etc).

## USAGE:

- From the base directory of the bash script, run the bash script with two arguments:
  1. the first argument is the path to the base directory of your EC-CUBE 4 installation. The
     subdirectories `/html/upload/save_image` should be present underneath it.
  2. The second argument is the Shift-JIS CRLF encoded CSV file output by THE BASE App
     Apps一覧 / CSV商品管理App / CSVダウンロード / 登録済み商品の情報を編集するためのCSVファイル / ダウンロードする
     
  Example:
  
  ```
  $ ./thebase2eccube.bash　/mnt/c/xampp/htdocs shop-example-com-19701231235959.csv
  ```
