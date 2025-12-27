#include <sys/inotify.h>
#include <poll.h>
#include <unistd.h>
#include <sys/stat.h>
#include <errno.h>
#include <string.h>
#include <libgen.h>
#include <stdlib.h>

/**
 * @brief Waits for a new file to be created or moved into a directory, or for the directory itself to be created.
 *
 * This function uses inotify to monitor a specified directory. If the directory
 * does not exist, it monitors the parent directory for the creation of the
 * target directory. Otherwise, it monitors the target directory for new files.
 *
 * @param dir_path The path to the directory to watch.
 * @param timeout_ms The maximum time to wait in milliseconds.
 * @return 2 if new directory creation is detected within timeout,
 *         1 if new file creation is detected within timeout,
 *         0 if timeout occurs,
 *         -1 if inotify initialization or memory allocation fails,
 *         -2 if inotify_add_watch fails (e.g., parent directory doesn't exist for watch).
 */
int wait_for_new_file(const char* dir_path, int timeout_ms) {
  // Initialize inotify instance
  int fd = inotify_init1(IN_NONBLOCK);
  if (fd == -1) return -1; // Failed to initialize inotify

  int wd; // Watch descriptor
  char *parent_dir = NULL;
  char *child_name = NULL;
  int watch_for_dir_creation = 0; // Flag to indicate if we are watching for directory creation

  struct stat st;
  // Check if the target directory exists
  if (stat(dir_path, &st) != 0 && errno == ENOENT) {
    // Directory does not exist, so we need to watch its parent for its creation
    watch_for_dir_creation = 1;

    // Duplicate dir_path for dirname() as it might modify its argument
    char *dir_path_d1 = strdup(dir_path);
    if (!dir_path_d1) { close(fd); return -1; }
    parent_dir = strdup(dirname(dir_path_d1)); // Get parent directory path
    free(dir_path_d1);
    if (!parent_dir) { close(fd); return -1; }

    // Duplicate dir_path for basename() as it might modify its argument
    char *dir_path_d2 = strdup(dir_path);
    if (!dir_path_d2) { free(parent_dir); close(fd); return -1; }
    child_name = strdup(basename(dir_path_d2)); // Get the name of the directory to be created
    free(dir_path_d2);
    if (!child_name) { free(parent_dir); close(fd); return -1; }

    // Add a watch on the parent directory for IN_CREATE events
    wd = inotify_add_watch(fd, parent_dir, IN_CREATE);
  } else {
    // Directory exists, add a watch on it for new file creation or moving
    wd = inotify_add_watch(fd, dir_path, IN_CREATE | IN_MOVED_TO);
  }

  // Check if adding the watch was successful
  if (wd == -1) {
    // Free allocated memory if any
    if (watch_for_dir_creation) {
      free(parent_dir);
      free(child_name);
    }
    close(fd);
    return -2; // Failed to add inotify watch
  }

  // Set up poll to wait for inotify events
  struct pollfd pfd;
  pfd.fd = fd;
  pfd.events = POLLIN;

  // Wait for an event or timeout
  int ret = poll(&pfd, 1, timeout_ms);
  int result = 0;

  // If an event occurred
  if (ret > 0 && (pfd.revents & POLLIN)) {
    if (watch_for_dir_creation) {
      // If we were watching for directory creation, read the event to confirm it's our target directory
      char buf[4096] __attribute__ ((aligned(__alignof__(struct inotify_event))));
      ssize_t len = read(fd, buf, sizeof(buf));
      if (len > 0) { // Check if any bytes were read
        const struct inotify_event *event;
        // Iterate through all events in the buffer
        for (char *ptr = buf; ptr < buf + len; ptr += sizeof(struct inotify_event) + event->len) {
          event = (const struct inotify_event *) ptr;
          // If a creation event for our target child directory is found
          if ((event->mask & IN_CREATE) && event->len > 0 && strcmp(event->name, child_name) == 0) {
            result = 2; // Our directory was created
            break;
          }
        }
      }
    } else {
      // If we were watching for new files, any event means success
      result = 1;
    }
  }

  // Free allocated memory
  if (watch_for_dir_creation) {
    free(parent_dir);
    free(child_name);
  }

  // Remove the watch and close the inotify instance
  inotify_rm_watch(fd, wd);
  close(fd);

  return result;
}
