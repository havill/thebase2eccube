# THE BASE → EC-CUBE 4.x Product CSV list converter
# Copyright 2020, Eido Inoue
#
# An AWK program that will read CSV exported by THE BASE (an ASP hosted e-Commerce solution for Japan)
# to EC-CUBE (an open source as well as hosted e-Commerce solution primarily used in Japan)
#
# ## NOTES:
#
# - CSV INPUT FILE MUST BE UTF-8 ENCODING AND THE UNICODE CHARACTER SET WITH NO BYTE ORDER MARK.
#    NOTE THAT THE DEFAULT OUTPUT FORMAT FOR EXPORTED JAPANESE CSV FILES IS USUALLY SHIFT-JIS,
#    SO YOU WILL NEED TO PRE-CONVERT THE FILE USING ICONV.
# - THE DEFAULT OUTPUT ENCODING IS UTF-8 WITH NO BOM (BYTE ORDER MARK). JAPANESE SAAS
#    SYSTEMS, EVEN ONES THAT WORK IN UNICODE NORMALLY, OFTEN EXPECT SHIFT-JIS FOR CSV IMPORT
# - CSV FILES USUALLY HAVE A CRLF FOR THE NEWLINE, EVEN ON LINUX SYSTEMS. IF YOU ARE RUNNING
#    AWK/GAWK ON A WINDOWS SYSTEM, YOU MAY NEED TO SET THE SPECIAL BINMODE VARIABLE TO "3" ON
#    THE COMMAND LINE TO KEEP WINDOWS FROM ATTEMPTING TO SILENTLY CONVERT THE END-OF-LINES CHARS.
#
# ## PREREQUISITES:
#
# - You will need wget on the system to pull the files. You can change this in the variables below
#   to curl or something else if you prefer
# - This script uses GNU specific AWK extensions. It probably won't won't on POSIX or lesser AWK
# - The script assumes that THE BASE stores all images in the cloud in the same place. Tweak the
#   variable below if the images are elsewhere.
# - The EC-CUBE mapping for 公開ステータス mapping should be "1" for 公開 (public), in order to match
#   THE BASE's idea of a publicly listed item. This is not a problem if you're using the default/demo
#   mappings for EC-CUBE (ex. the demo "GELATO" site)
#
# ## LIMITATIONS:
# 
# - AWK and even GAWK cannot process files that are both separated by newlines and have newlines
#   within fields. You will need to use a separate utility to convert or edit (valid) CSV files
#   that have embedded CR or LF or NL in the fields.
#
# ### LICENSE & WARRANTY
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

function set_mandatory(array_2d, csv, sentinel) {
    if (csv == "the_base") {
        # these first four fields are mandatory in THE BASE as of 2020-Jul-24
        array_2d[csv, "商品ID"] = sentinel
        array_2d[csv, "商品"] = sentinel
        array_2d[csv, "種類ID"] = sentinel
        array_2d[csv, "種類名"] = sentinel
    }
    else if (csv == "ec_cube") {
        # these fields are mandatory (必項) for EC-CUBE 4.0.4 商品CSV登録/一括登録
        array_2d[csv, "公開ステータス(ID)"] = sentinel
        array_2d[csv, "商品名"] = sentinel
        array_2d[csv, "販売種別(ID)"] = sentinel
        array_2d[csv, "販売価格"] = sentinel
    }
    return
}

function is_empty_array(matrix) {
    empty = "true"     # empty or NULL string in awk is "false"; anything else evals to true
    for (z in array_2d) {
        print "WARNING: this is missing from the CSV header: " z > "/dev/stderr"  #DEBUG
        empty = ""
    }
    return empty;
}

BEGIN {
    # This field pattern separator feature requires GNU not POSIX or plain awk
    # for processing RFC 4180 CSV escape patterns (quoted fields and embedded commas)
    FPAT = "([^,]*)|(\"[^\"]+\")"   # change of first + to * allows fields to be empty

    has_header["the_base"] = 1      # CSV files exported from THE BASE CSV商品管理 App will always have this
    has_header["ec_cube"] = 1       # CSV files imported with EC-CUBE 4.x 商品管理 function MUST have this

    download = "wget --quiet -N"    # you could also use something like curl here too
    comma = ","                     # some tools may need TAB or some other delimiter besides comma
    crlf = "\r\n"                   # RFC 4180 says strict CSV files should be CRLF, even in Unix and Mac
    max_img = 20                    # THE BASE currently supports up to twenty images per product item

    

    FS = comma
    RS = crlf                       # CSV files are supposed to have CRLF NLs regardless of platform
    BINMODE = rw                    # on Windows, you may need to set BINMODE variable to "rw" or "3"

    # presently THE BASE stores all store their image files at this URI
    # the suffix may possibly .jpeg, .png, .webp, .heic extension or a http query parameters and/or a fragment
    cdn_prefix = "https://base-ec2.akamaized.net/images/item/origin/"
    cdn_suffix = ""

    set_mandatory(required_output, "ec_cube", "CHANGEME")

    # this long string is the first line output by 雛形ファイルダウンロード in EC-CUBE 4.x 商品CSV登録商品管理
    eccube_header = "商品ID,公開ステータス(ID),商品名,ショップ用メモ欄,商品説明(一覧),商品説明(詳細),検索ワード,フリーエリア,商品削除フラグ,商品画像,商品カテゴリ(ID),タグ(ID),販売種別(ID),規格分類1(ID),規格分類2(ID),発送日目安(ID),商品コード,在庫数,在庫数無制限フラグ,販売制限数,通常価格,販売価格,送料,税率"

    # learn the order of the fields and what fields are present
    split(eccube_header, field, comma)

    if (has_header["ec_cube"]) {
       for (i = 1; field[i] != ""; i++) {
           if (i > 1)
               printf "%s", comma
           printf "%s", field[i]
           delete required_output["ec_cube",field[i]]
       }
       printf crlf
    }

    if (!is_empty_array(required_output)) {
        print "ERROR: some required fields for EC-CUBE 4.x are missing." > "/dev/stderr"
        exit 1
    }
}

function dequote(string) {
    if (substr(string, 1, 1) == "\"") {     # remove quotes when they occur
        len = length(string)
        string = substr(string, 2, len - 2) # Get text within the two quotes
    }
    return string
}

# special do-once rule for processing the CSV line #1 header (if marked as present)
NR == 1 && has_header["the_base"] {
    set_mandatory(required_input, "the_base", "CHANGEME")

    # learn the order of the fields and what fields are present
    for (i = 1; i <= NF; i++) {
        thebase_field[i] = dequote($i)          # init element from CSV column/string/index with a null/empty value
        delete required_input["the_base", thebase_field[i]]
    }

    if (!is_empty_array(required_input)) {
        print "WARNING: some required fields for THE BASE were missing." > "/dev/stderr"
        # exit 1 #DEBUG
    }
}

# join an array into a string: arnold@gnu.org, public domain, May 1993
function join(array, start, end, sep, result, i) {
    if (sep == "")
        sep = " "
    else if (sep == SUBSEP) # magic value
        sep = ""
    result = array[start]
    for (i = start + 1; i <= end; i++)
        result = result sep array[i]
    return result
}

NR > 1 {
    # variables are persistant and global (except in functions) in awk, so we need to manually
    # clean the garbage in the arrays from the previous record
    for (x in product) delete product[x]
    for (x in filename) delete filename[x]
   
    # put each merchandise item (record) attribute (field) in the appropriate array index
    # we know the field order, as well as what fields are available, from the CSV first line header
    for (i = 1; i <= NF; i++) {
        product[thebase_field[i]] = dequote($i)
    }

    # an item in THE BASE has anywhere from 0 to 20 images associated with it. see how many
    # images are associated with this item and download each one from THE BASE's static image
    # content distribution network
    url_count = 0
    for (i = 1; i < max_img; i++) {
        img_count++
        image = "画像" i
        if (image in product) {
            filename[i] = product[image]
            if (length(filename[i]) > 0) {
                # FIXME: probably more efficient to pass all the URLs at once to the http resource getter
                cmd = download " " cdn_prefix filename[i] cdn_suffix
                if (system(cmd) != 0) {
                    print "ERROR: this command failed: " cmd > "/dev/stderr"
                    exit 1
                }
            }
        }
    }

    raw_img_list = join(filename, 1, img_count, comma, list, i)
    gsub(/,+$/, "", raw_img_list)                       # remove all the trailing commas (unused THE BASE image fields)
    quoted_img_list = "\"" raw_img_list "\""

    value["商品ID"]             = ""                    # null/empty string to create new item, otherwise valid existing ID to update
    value["公開ステータス(ID)"]  = product["公開状態"]    # REQUIRED: 公開ステータス(名称) / 1 = 公開
    value["商品名"]             = product["商品名"]      # REQUIRED: product name
    value["ショップ用メモ欄"]    = "JAN/GTIN = " product["JAN/GTIN"]
    value["商品説明(一覧)"]      = ""
    value["商品説明(詳細)"]      = product["説明"]
    value["検索ワード"]          = product["種類名"]
    value["フリーエリア"]        = "THE BASE→CSV商品管理App→CSVダウンロード→登録済み商品の情報を編集するためのCSVファイル"
    value["商品削除フラグ"]      = "0"                  # "0" or empty string to register, "1" to delete
    value["商品画像"]           = quoted_img_list       # comma separated list of filenames surrounded by double quotes
    value["商品カテゴリ(ID)"]    = ""
    value["タグ(ID)"]           = ""
    value["販売種別(ID)"]       = "1"                     # REQUIRED / 1 = "販売種別A" in the demo GELATO site
    value["規格分類1(ID)"]      = ""
    value["規格分類2(ID)"]      = ""
    value["発送日目安(ID)"]     = ""
    value["商品コード"]         = product["商品コード"]
    value["在庫数"]             = product["在庫数"]        # REQUIRED IF: must be greater than 0 if the "unlimited supply" flag is zero
    value["在庫数無制限フラグ"]  = "0"                      # "0" = limited inventory (see above). "1" = unlimited
    value["販売制限数"]         = "1"                      # must be "1" or higher
    value["通常価格"]           = product["価格"]          # must be "0" or higher
    value["販売価格"]           = product["価格"]          # REQUIRED: must be zero or higher
    value["送料"]               = ""                      # REQUIRED IF: per-product shipping fees setting is enabled. "0" or greater
    value["税率"]               = product["税率"]         # REQUIRED IF: per-product tax rate setting is enabled. "0" or greater

    set_mandatory(required_output, "ec_cube", "CHANGEME")
    for (i = 1; field[i] != ""; i++) {
        if (i > 1)
            printf "%s", comma
        printf "%s", value[field[i]]
        if (length(value[field[i]]) > 0)
            delete required_output["ec_cube", field[i]]
    }
    printf "%s", crlf

    if (!is_empty_array(required_output)) {
        print "ERROR: some required fields for EC-CUBE 4.x are missing." > "/dev/stderr"
        exit 1
    }
 }