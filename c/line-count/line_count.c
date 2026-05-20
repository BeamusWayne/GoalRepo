#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    long lines;
    long words;
    long chars;
    long bytes;
} Counts;

static Counts count_file(const char *path) {
    Counts c = {0, 0, 0, 0};
    FILE *f = strcmp(path, "-") == 0 ? stdin : fopen(path, "rb");
    if (!f) {
        fprintf(stderr, "Error: cannot open '%s'\n", path);
        return c;
    }

    int ch, prev = ' ';
    while ((ch = fgetc(f)) != EOF) {
        c.bytes++;
        c.chars++;
        if (ch == '\n') c.lines++;
        if ((ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') && prev != ' '
            && prev != '\t' && prev != '\n' && prev != '\r') {
            c.words++;
        }
        prev = ch;
    }
    if (prev != ' ' && prev != '\t' && prev != '\n' && prev != '\r' && prev != EOF) {
        c.words++;
    }

    if (f != stdin) fclose(f);
    return c;
}

int main(int argc, char *argv[]) {
    int show_lines = 1, show_words = 0, show_chars = 0, show_bytes = 0;
    int file_count = 0;
    int file_start = -1;

    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-') {
            for (size_t j = 1; j < strlen(argv[i]); j++) {
                switch (argv[i][j]) {
                    case 'l': show_lines = 1; break;
                    case 'w': show_words = 1; break;
                    case 'c': show_chars = 1; break;
                    case 'b': show_bytes = 1; break;
                    case 'h':
                        printf("Usage: line_count [-l] [-w] [-c] [-b] [file...]\n");
                        return 0;
                }
            }
        } else {
            if (file_start < 0) file_start = i;
            file_count++;
        }
    }

    if (file_start < 0) {
        Counts c = count_file("-");
        if (show_lines) printf("%8ld", c.lines);
        if (show_words) printf("%8ld", c.words);
        if (show_chars) printf("%8ld", c.chars);
        if (show_bytes) printf("%8ld", c.bytes);
        printf("\n");
        return 0;
    }

    Counts total = {0, 0, 0, 0};
    for (int i = file_start; i < argc; i++) {
        if (argv[i][0] == '-') continue;
        Counts c = count_file(argv[i]);
        if (show_lines) printf("%8ld", c.lines);
        if (show_words) printf("%8ld", c.words);
        if (show_chars) printf("%8ld", c.chars);
        if (show_bytes) printf("%8ld", c.bytes);
        printf(" %s\n", argv[i]);
        total.lines += c.lines;
        total.words += c.words;
        total.chars += c.chars;
        total.bytes += c.bytes;
    }

    if (file_count > 1) {
        if (show_lines) printf("%8ld", total.lines);
        if (show_words) printf("%8ld", total.words);
        if (show_chars) printf("%8ld", total.chars);
        if (show_bytes) printf("%8ld", total.bytes);
        printf(" total\n");
    }

    return 0;
}
