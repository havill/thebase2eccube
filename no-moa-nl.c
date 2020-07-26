/* # NO MOA NL v1.0 2020-07-24
   ## (no more newlines)
   ## Copyright 2020, Eido Inoue
 
   - converts newlines embedded in CSV fields into HTML-ish <br/>.
   - Also respects and understands RFC 4180 concepts of double-quote escaping
     of entire fields and single characters.
   - Will output CRLF, rather than Unix style LF,
     for the newline as this is RFC 4180 compliant
    created this when I realized that it was impossible to properly process
    CSV files using AWK or GAWK, so this can be used as a pre-processor
    if you know the fields will be used in web markup.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
    FILE *input = stdin, *output = stdout;
    int escaped = 0, c = -1, prev = -1, i = 0;
    char *filename = argv[i++];

    do {
        if (argc > 1) {
            filename = argv[i];
            input = fopen(filename, "rb");
            if (input == NULL) {
                perror(argv[i]);
                exit(EXIT_FAILURE);
            }
        }

        while ((c = fgetc(input)) >= 0) {
            switch (c) {
            case '\r': break;
            case '\n':
                if (fputs(escaped ? "<br/>" : "\r\n", output) < 0) {
                    perror(NULL);
                    exit(EXIT_FAILURE);
                }
                break;
            case '"':
                if (prev != '"') escaped = !escaped;
                /*FALLTHRU*/
            default:
                if (fputc(c, output) < 0) {
                    perror(NULL);
                    exit(EXIT_FAILURE);
                }
            }
            prev = c;
        }
        if (ferror(input)) {
            perror(filename);
            exit(EXIT_FAILURE);
        }
        if (argc > 1 && (fclose(input) < 0)) {
            perror(filename);
            exit(EXIT_FAILURE);
        }
    } while (++i < argc);
    return 0;
}
