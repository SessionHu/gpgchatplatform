#include <sys/inotify.h>
#include <poll.h>
#include <unistd.h>

int wait_for_new_file(const char* dir_path, int timeout_ms) {
  int fd = inotify_init1(IN_NONBLOCK);
  if (fd == -1) return -1;

  int wd = inotify_add_watch(fd, dir_path, IN_CREATE | IN_MOVED_TO);
  if (wd == -1) {
    close(fd);
    return -2;
  }

  struct pollfd pfd;
  pfd.fd = fd;
  pfd.events = POLLIN;

  int ret = poll(&pfd, 1, timeout_ms);

  inotify_rm_watch(fd, wd);
  close(fd);

  if (ret > 0 && (pfd.revents & POLLIN)) {
    return 1;
  }

  return 0;
}
