// Simulator-only test aid. Inject into the test app with DYLD_INSERT_LIBRARIES.
// Fail every Internet socket at creation, including calls from native app code.
// This file is never linked into Runner or distributed with the application.
#include <sys/socket.h>
#include <errno.h>

static int offline_socket(int domain, int type, int protocol) {
    if (domain == AF_INET || domain == AF_INET6) {
        errno = EACCES;
        return -1;
    }
    return socket(domain, type, protocol);
}
__attribute__((used)) static struct {
    const void *replacement;
    const void *original;
} interpose_socket __attribute__((section("__DATA,__interpose"))) = {
    (const void *)offline_socket, (const void *)socket
};
