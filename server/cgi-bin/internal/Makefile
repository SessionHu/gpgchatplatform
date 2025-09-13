CC := $(shell command -v gcc || command -v clang)
DC := $(shell command -v ldc2 || command -v gdc || command -v dmd)

TARGET = watch/watch
SRC_D = watch/watch.d utils.d
SRC_C = watch/watcher.c
OBJ_D = $(SRC_D:.d=.o)
OBJ_C = $(SRC_C:.c=.o)
OBJS = $(OBJ_D) $(OBJ_C)

DFLAGS = -I..

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(DC) $(OBJS) -of=$(TARGET)

%.o: %.d
	$(DC) $(DFLAGS) -c $< -of=$@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)
